# ShopSync AI Coding Agent Instructions

## Project Overview

ShopSync is a Flutter app for collaborative shopping list management with Firebase backend. It supports **three platforms**: phone (`lib/main.dart`) and WearOS (`lib/wear/wear_main.dart`) with **separate build flavors**. The web version does not have a flavor, however it is actively maintained with the rest of the app.

## Architecture & Key Patterns

### Dual-Target Architecture

- **Phone app**: `flutter run --release --flavor phone -d <device>`
- **WearOS app**: `flutter run --release --flavor wear -d <device> --target lib/wear/wear_main.dart`
- Flavors defined in `android/app/build.gradle` with dimension "platform"
- Separate entry points but shared services, models, and Firebase configuration

### Firebase Data Structure

```
list_groups/ (top-level grouping)
  └─ {groupId}
     ├─ name, createdBy, members[], position, isExpanded, listIds[]
     └─ lists/ (subcollection references by listIds[])

lists/ (shopping lists)
  └─ {listId}
     ├─ name, createdBy, members[], color, place, isRecycleBin
     ├─ items/ (subcollection)
     │  └─ {itemId}: name, checked, quantity, categoryId, deleted, etc.
     └─ categories/ (subcollection)
        └─ {categoryId}: name, iconIdentifier, order
```

**Critical**: Lists can be grouped but also exist standalone. Use `ListGroupsService` for group operations, direct Firestore queries for list/item CRUD.

### State Management

- **No Provider/ChangeNotifier** for global state (commented out in codebase)
- Uses `StreamBuilder<QuerySnapshot>` and `StreamBuilder<DocumentSnapshot>` for real-time Firebase sync
- `FutureBuilder` for one-time async operations (e.g., checking update status)
- Local state via `setState()` and `StatefulWidget`

### Services Layer Pattern

All services are static utility classes (no singletons/instances):

- `ListGroupsService` - group CRUD, reordering, list-group associations
- `CategoriesService` - per-list categories with order management
- `GoogleAuthService` - handles Credential Manager (Android) + web auth flows
- `SmartSuggestionsService` - on-device ML for item suggestions (trains from user history)
- `ConnectivityService` - monitors network state, shows offline dialog
- `HomeWidgetService` - Android home widget updates via `home_widget` package

**Error handling**: All service methods wrap errors with `Sentry.captureException()` including contextual hints.

## Development Workflows

### Building & Running

```bash
# Phone flavor (default target)
flutter run --release --flavor phone -d emulator-5554

# WearOS flavor (custom target required)
flutter run --release --flavor wear -d emulator-5556 --target lib/wear/wear_main.dart

# CI checks (what GitHub Actions runs)
flutter analyze --no-fatal-infos
flutter pub get
```

**Linting**: Uses `flutter_lints` with `use_build_context_synchronously: ignore` (see `analysis_options.yaml`).

### Localization

- ARB files in `lib/l10n/`, generated via `l10n.yaml` config
- Run `./extract_strings.sh` to auto-generate `app_en.arb` from code (extracts `Text()`, `title:`, `return` strings)
- Currently translations are not being added inside app. Hardcode strings as normal.

### Release Process

- **Phone**: CD workflow builds `--flavor phone --target=lib/main.dart` → `app-phone-release.aab`
- **WearOS**: Separate CD workflow for wear builds
- Version code format: `XXYYYYYYY` where XX=platform (30=phone,40=wear), YYYYYYY=versionCode.
- Requires `key.properties` (keystore config) and `sentry.properties` (debug symbols upload)

## Code Conventions

### Localization

**CRITICAL**: All user-facing strings in UI elements MUST be localized.

- **Never** use hardcoded strings in UI components (Text, labels, titles, messages, etc.)
- **Always** use `AppLocalizations.of(context)!` to access localized strings
- **Always** add new strings to `lib/l10n/app_en.arb` when creating UI elements
- String keys should be camelCase and descriptive (e.g., `aiFeatures`, `enableSmartSuggestions`)
- Include context in key names when needed (e.g., `aiFeaturesEnabled` vs `aiFeaturesDisabledMessage`)

**Example**:

```dart
// ❌ WRONG - Hardcoded string
Text('AI Features')

// ✅ CORRECT - Localized string
Text(AppLocalizations.of(context)!.aiFeatures)
```

**Adding new strings**:

1. Add the string to `lib/l10n/app_en.arb`:
   ```json
   "aiFeatures": "AI Features",
   "enableSmartSuggestions": "Enable Smart Suggestions"
   ```
2. Use it in code:
   ```dart
   final l10n = AppLocalizations.of(context)!;
   Text(l10n.aiFeatures)
   ```

**Note**: Currently, translations are not being added to other locale files. Only `app_en.arb` needs to be updated with English strings.

### File Organization

- `lib/screens/` - full-page UI (e.g., `home.dart`, `list_view.dart`)
- `lib/widgets/` - reusable components (e.g., `expandable_list_group_widget.dart`)
- `lib/services/` - business logic & Firebase interactions
- `lib/wear/screens/` - WearOS-specific UI (circular layouts, rotary support)
- Naming: `snake_case` for files, `PascalCase` for classes, `camelCase` for variables

### Common Patterns

1. **Loading Indicators**:
   - **Phone/Web**: Use `CustomLoadingSpinner()` from `/widgets/loading_spinner.dart`
   - **WearOS**: Use standard `CircularProgressIndicator()`

   ```dart
   // Phone/Web
   Center(child: CustomLoadingSpinner())

   // WearOS
   Center(child: CircularProgressIndicator())
   ```

2. **StreamBuilder for Firestore**:

   ```dart
   StreamBuilder<QuerySnapshot>(
     stream: _firestore.collection('lists').doc(listId).collection('items').snapshots(),
     builder: (context, snapshot) { /* ... */ }
   )
   ```

3. **Sentry error tracking** (include context):

   ```dart
   await Sentry.captureException(error, stackTrace: stackTrace,
     hint: Hint.withMap({'action': 'create_list', 'list_name': name}));
   ```

4. **Firebase timestamps**: Use `FieldValue.serverTimestamp()` for `createdAt`/`updatedAt`

5. **Animations**: Prefer `SingleTickerProviderStateMixin` + `AnimationController` (see `list_view.dart`)

### Authentication

- Google Sign-In uses **Credential Manager** on Android (v2.0.0 API) for passkey support
- Web uses `GoogleSignIn` with client ID from `GoogleAuthService._webClientId`
- Check `currentUser.providerData` to detect linked providers (Google, email/password)

## Integration Points

### External Services

- **Firebase**: Auth, Firestore, deployed via `firebase.json` (hosting config)
- **Sentry**: Error tracking with 100% trace/profile sample rate (see `main.dart`)
- **Google Mobile Ads**: Initialized with `unawaited(MobileAds.instance.initialize())`
- **TFLite**: Local ML model for smart suggestions (`SmartSuggestionsService`)
- **Weblate**: Translation management (not in code, contributor workflow)
- **Atlassian Statuspage**: Outage status via public API (`StatuspageService`)

### Statuspage Outage Integration

- Service: `lib/services/platform/statuspage_service.dart` (static API, Sentry-wrapped)
- Config: `lib/config/statuspage_config.dart` → set `baseApiUrl` to your Statuspage domain (e.g., `https://yourpage.statuspage.io/api/v2`)
- Model: `lib/models/status_outage.dart`
- UI (Phone/Web):
  - Fullscreen closable dialog: `lib/screens/status/outage_dialog.dart` (shown once per app run when outage is active)
  - Global top banner: `lib/widgets/status/outage_banner.dart` rendered across all screens via `MaterialApp.builder` overlay; polls every 1 minute
- UI (WearOS):
  - Fullscreen closable dialog: `lib/wear/screens/wear_outage_screen.dart`
  - Header replacement: In `lib/wear/screens/wear_list_groups_screen.dart` the ShopSync logo is replaced with a red exclamation indicator + short status after the dialog is dismissed. Tapping it reopens the fullscreen dialog.
- Polling: `StatuspageService.startPolling()` is called on app startup (phone and wear). Poll interval is 1 minute to avoid rate limits.
- Short statuses: `'outage'`, `'fixed'`, `'none'` mapped from unresolved incidents and summary indicator.
- Error handling: All fetch errors captured via `Sentry.captureException()` with contextual hints.

### Platform-Specific

- **Android Home Widget**: Uses `HomeWidgetService.updateWidget()` to sync data to launcher widget
- **WearOS**: Rotary scroll support via `rotary_scrollbar` package, ambient mode via `wear_plus`
- **In-app updates**: `UpdateService.checkForUpdate()` triggers Android Play update flow

#### WearOS Language Selection Flow

- The language selector screen lists options and, on tap, navigates to a separate confirmation screen.
- The confirmation screen is minimal and scrollable with extra bottom space; it displays:
  - Title: "Confirm Language"
  - Selected language name (lowercase)
  - "OK" and "Cancel" buttons only.
- The selector no longer shows a bottom "OK" button; confirmation happens on the next screen to avoid UI clipping issues on round displays.

## Critical Gotchas

- **Don't use Provider**: Theme state management code is commented out; rebuild MaterialApp manually
- **WearOS requires explicit target**: Always specify `--target lib/wear/wear_main.dart` for wear builds
- **List groups vs. lists**: Groups are organizational only; lists are the actual data containers
- **Offline handling**: `ConnectivityService` shows dialog but app must handle Firestore offline persistence
- **Smart suggestions cache**: Service trains asynchronously; UI shows cached results immediately

## Testing & Debugging

### Automated Testing Framework

ShopSync has **automated testing with GitHub Actions CI** integrated:

- **Test Types**: Unit tests, Widget tests, Integration tests (framework in place)
- **Test Framework**: Flutter Test + Mockito
- **CI/CD**: GitHub Actions runs tests automatically on push and PR
- **Coverage**: Codecov integration for coverage tracking
- **Execution**: Parallel test execution enabled (faster CI feedback)

### Running Tests Locally

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run specific test file
flutter test test/unit/models/item_suggestion_test.dart

# Generate coverage summary (after flutter test --coverage)
lcov --summary coverage/lcov.info

# Use provided helper script
bash run_tests.sh

# Verify setup
bash verify_setup.sh
```

### Test Structure

```
test/
├── test_utils.dart                          # Shared test utilities, Firebase mocks
├── unit/
│   ├── models/
│   │   └── item_suggestion_test.dart       # Model serialization/deserialization tests
│   ├── services/
│   │   └── services_test.dart              # Service layer tests (expand as needed)
│   └── utils/                              # Utility function tests
├── widgets/
│   ├── basic_widget_test.dart              # Widget rendering & interaction tests
│   └── screens/                            # Screen-level widget tests
└── integration/                            # End-to-end flow tests (reserved)
```

### Writing Unit Tests

When adding new services or models, add tests following this pattern:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/services/my_service.dart';

void main() {
  group('MyService', () {
    test('performs action correctly', () {
      // Arrange: Set up test data
      final service = MyService();

      // Act: Perform the action
      final result = service.doSomething();

      // Assert: Verify the result
      expect(result, expectedValue);
    });

    test('handles error gracefully', () {
      // Test error handling
      expect(
        () => service.failingMethod(),
        throwsException,
      );
    });
  });
}
```

### Writing Widget Tests

Test UI components and interactions:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('MyWidget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyWidget()));
      expect(find.byType(MyWidget), findsOneWidget);
    });

    testWidgets('handles user interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyWidget()));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsOneWidget);
    });
  });
}
```

### Test Dependencies

Added to `pubspec.yaml` dev_dependencies:

- `mockito: ^5.4.4` - Mocking framework
- `fake_cloud_firestore: ^2.5.0` - Firestore mocking
- `firebase_auth_mocks: ^0.14.0` - Firebase Auth mocking
- `coverage: ^7.0.0` - Coverage reporting

### GitHub Actions Workflows (CI/CD & Maintenance)

- `.github/workflows/CI.yml` — Full CI matrix.
  - Triggers: push to `main`/`master`, PR open/edit/sync.
  - Jobs: `lint` (flutter analyze), `test` (flutter test --coverage → Codecov), `build-phone` (debug APK, flavor phone), `build-wear` (debug APK, flavor wear), `build-web` (flutter build web --wasm). Heavy caching for pub, Flutter, Gradle; artifacts: coverage and web build.

- `.github/workflows/build-verification.yml` — Parallel build-only verification.
  - Triggers: push/PR affecting Dart, pubspec, android/ ios/ web/.
  - Jobs: phone debug APK, wear debug APK, web WASM build. Publishes APKs + web build artifacts. Final summary aggregates all three.

- `.github/workflows/lint.yml` — Fast lint/format gate.
  - Triggers: push/PR touching Dart or analysis/pubspect files.
  - Jobs: dart format check, flutter analyze; uses pub cache; fails fast with summary.

- `.github/workflows/CD-Prod-Play-Phone.yml` — Phone release to Play.
  - Trigger: manual `workflow_dispatch`.
  - Steps: checkout, Java 17 (cached Gradle), Flutter 3.38.5 (cached), pub cache, Android build cache, decode keystore + key.properties, sentry.properties, `flutter build appbundle --release --flavor phone --target=lib/main.dart`, upload via `r0adkll/upload-google-play` to production.

- `.github/workflows/CD-Prod-Play-WearOS.yml` — WearOS release to Play.
  - Trigger: manual `workflow_dispatch`.
  - Steps mirror phone CD but `flutter build appbundle --release --flavor wear --target=lib/wear/wear_main.dart`, uploaded to `wear:production` track.

- `.github/workflows/auto-assign-issue.yml` — Maintenance.
  - Trigger: issues opened.
  - Action: auto-assign configured maintainers.

- `.github/workflows/stale.yml` — Maintenance.
  - Trigger: scheduled.
  - Action: marks inactive issues/PRs as stale per config.

### Coverage Goals

- **Services Layer**: Target 70%+
- **Models**: Target 80%+
- **Utilities**: Target 75%+
- **Widgets**: Target 60%+ (UI testing is more challenging)

Coverage reports available at Codecov dashboard.

### Testing Best Practices

1. **Test in isolation**: Mock external dependencies (Firebase, networking)
2. **Use descriptive names**: `test('creates list with correct name', ...)` not `test('works')`
3. **Follow AAA pattern**: Arrange → Act → Assert
4. **Keep tests focused**: One behavior per test
5. **Mock Firebase**: Use `test_utils.dart` helpers for Firebase mocking
6. **Handle async**: Use `await` and `pumpAndSettle()` for async operations
7. **Test error cases**: Include tests for error handling and edge cases

### Expanding Test Coverage

Key areas to add tests:

- `ListGroupsService` - group CRUD, reordering, list associations
- `CategoriesService` - category management per list
- `SmartSuggestionsService` - ML suggestion logic
- `GoogleAuthService` - authentication flows
- `ConnectivityService` - network state handling
- Screen widgets - home.dart, list_view.dart, create_item.dart
- Integration tests - full user flows (login → create → collaborate)

### Test Documentation

- **`TESTING.md`**: Complete testing guide with examples
- **`MANUAL_STEPS.md`**: Manual setup for CI/CD (Codecov, branch protection)
- **`QUICK_REFERENCE.md`**: Quick reference for manual steps
- **`IMPLEMENTATION_SUMMARY.md`**: What was implemented and next steps

### Debugging Failed Tests

```bash
# Verbose output
flutter test --verbose

# Single test
flutter test -k "test_name"

# Stop on first failure
flutter test --fail-fast

# Watch mode (re-run on changes)
flutter test --watch
```

If tests pass locally but fail in CI:

1. Check Flutter version matches: `flutter --version` (should be 3.38.5)
2. Clear cache: `flutter clean && flutter pub get`
3. Check for timing issues in async tests
4. Verify test dependencies installed correctly

- Use `kDebugMode` checks for debug prints (see `main.dart` ConnectivityService init)
- Sentry captures all unhandled errors in production builds
- Test both flavors separately to catch platform-specific issues

## AI Agent Guidelines

- **DO NOT create README files**: Never create summary documents, README files, or markdown documentation files after completing tasks unless explicitly requested by the user.

- **UPDATE COPILOT INSTRUCTIONS**: For any new feature, architectural pattern, or important convention that deserves documentation, add it to this copilot-instructions.md file. Keep instructions clear, concise, and actionable for future AI agents.

### AI Features & User Preferences

**AI Preference System:**

ShopSync includes on-device AI features (primarily Smart Suggestions) that some users may prefer to disable. The AI preference is stored in Firestore and controlled via:

- **Service**: `lib/services/data/ai_preference_service.dart` (class: `AIPreferenceService`)
- **Setup Screen**: `lib/screens/settings/ai_preference_setup.dart` (class: `AIPreferenceSetupScreen`)
  - Mandatory screen shown to new users or existing users without preference set
  - User must choose to enable or disable AI features (cannot skip)
  - Navigation: Shown automatically in AuthWrapper if preference not set
- **Profile Settings**: Users can change preference later in `lib/screens/settings/profile.dart`
  - Toggle switch in "AI Features" card
  - Changes take effect immediately

**Firestore Field:**

- Collection: `users/{userId}`
- Field: `aiEnabled` (boolean) - indicates if user has enabled AI features
- Field: `aiPreferenceUpdatedAt` (timestamp) - last time preference was changed

**Implementation Flow:**

1. New user signs up → `aiEnabled` field NOT set in user document
2. User logs in → `AuthWrapper` checks `AIPreferenceService.hasAIPreference()`
3. If preference not set → Show `AIPreferenceSetupScreen` (mandatory, cannot skip)
4. User chooses enable/disable → Preference saved to Firestore
5. User navigates to home screen
6. Existing users can toggle preference in Profile settings

**AI Features Affected:**

- Smart Suggestions in create item screen (`lib/screens/lists/create_item.dart`)
- Smart Suggestions in item templates (`lib/screens/lists/list_options.dart`)
- Both screens check `AIPreferenceService.isAIEnabled()` before loading suggestions
- If AI disabled, suggestions array is empty and widget not shown

**Important Notes:**

- **Phone/Web Only**: AI preference feature is NOT implemented for WearOS
- **On-Device ML**: Smart suggestions use `SmartSuggestionsService` with local TFLite model
- **Privacy-Focused**: When disabled, no shopping pattern analysis occurs
- **Service Methods**:
  - `hasAIPreference()` - Check if user has set preference
  - `getAIPreference()` - Get current preference (null if not set)
  - `setAIPreference(bool)` - Update preference
  - `isAIEnabled()` - Quick check, returns false if not set

**Testing Responsibilities:**
When modifying AI features:

- Ensure AI preference check is respected
- Test with AI enabled and disabled states
- Add unit tests for `AIPreferenceService`
- Verify setup screen cannot be skipped

### Analytics & Insights Architecture

**Dual-Level Insights System:**

- **User-Level Insights**: Accessible from home drawer, shows aggregate stats across all user's lists
  - File: `lib/screens/user_insights.dart` (class: `UserInsightsScreen`)
  - Service: `lib/services/analytics_service.dart` (class: `AnalyticsService`)
  - Navigation: Home → Drawer → "User Insights"

- **List-Level Insights**: Accessible from individual list navigation, shows per-list statistics
  - File: `lib/screens/list_insights.dart` (class: `ListInsightsScreen`)
  - Service: `lib/services/list_analytics_service.dart` (class: `ListAnalyticsService`)
  - Navigation: List → Insights Tab (between Items and Options tabs)
  - Tab Order: **Items → Insights → Options**

**Important Field Names for Analytics:**

- Items use `'completed'` field (NOT `'checked'`)
- Items use `'addedAt'` timestamp (NOT `'createdAt'`)
- **Items do NOT have a `'completedAt'` field** - use `'addedAt'` as proxy for time-based queries
- **Items do NOT have a `'deleted'` field** - deleted items are moved to `recycled_items` subcollection, not filtered
- Lists use `'addedAt'` timestamp (NOT `'createdAt'`)
- Categories are fetched from `lists/{listId}/categories` subcollection
- Category names must be resolved from category IDs

**Navigation Tab Order:**
When creating or modifying list navigation:

- Index 0: Items (bouncy animation)
- Index 1: Insights (donut spin animation with `Icons.donut_small` → `Icons.donut_large`)
- Index 2: Options (settings spin animation)

### Testing Responsibilities

When implementing features or fixes:

1. **Write tests alongside code**: Add unit tests for new services, models, and utilities
2. **Test before merge**: Ensure `flutter test` passes locally
3. **Follow test patterns**: Use AAA pattern (Arrange → Act → Assert)
4. **Mock Firebase**: Use `test_utils.dart` for Firebase mocking, don't make real Firestore calls
5. **Update existing tests**: If modifying existing code, update relevant tests
6. **Add widget tests**: For new screens/widgets, add corresponding widget tests
7. **Statuspage tests**: Unit tests for `StatusOutage` model live in `test/unit/services/statuspage_service_test.dart`
8. **Check coverage**: Run `flutter test --coverage` to verify no major coverage drops

### Test Writing Quick Rules

- Service tests: Mock Firestore, Firebase Auth, external dependencies
- Widget tests: Test rendering, interactions, state changes
- Use `expect(condition, matcher)` for assertions
- Name tests clearly: `test('creates item with correct name and quantity', ...)`
- One assertion per test when possible
- Handle async properly: `await`, `pumpAndSettle()`

### When Tests Fail in CI

1. Check locally first: `flutter test`
2. Look at CI logs in GitHub Actions
3. Verify Flutter version matches CI (3.38.5)
4. Check for timing/race conditions in async tests
5. Ensure mocks are set up correctly in test setup
