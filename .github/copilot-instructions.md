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

### File Organization

- `lib/screens/` - full-page UI (e.g., `home.dart`, `list_view.dart`)
- `lib/widgets/` - reusable components (e.g., `expandable_list_group_widget.dart`)
- `lib/services/` - business logic & Firebase interactions
- `lib/wear/screens/` - WearOS-specific UI (circular layouts, rotary support)
- Naming: `snake_case` for files, `PascalCase` for classes, `camelCase` for variables

### Common Patterns

1. **StreamBuilder for Firestore**:

   ```dart
   StreamBuilder<QuerySnapshot>(
     stream: _firestore.collection('lists').doc(listId).collection('items').snapshots(),
     builder: (context, snapshot) { /* ... */ }
   )
   ```

2. **Sentry error tracking** (include context):

   ```dart
   await Sentry.captureException(error, stackTrace: stackTrace,
     hint: Hint.withMap({'action': 'create_list', 'list_name': name}));
   ```

3. **Firebase timestamps**: Use `FieldValue.serverTimestamp()` for `createdAt`/`updatedAt`

4. **Animations**: Prefer `SingleTickerProviderStateMixin` + `AnimationController` (see `list_view.dart`)

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
- **Crowdin**: Translation management (not in code, contributor workflow)

### Platform-Specific

- **Android Home Widget**: Uses `HomeWidgetService.updateWidget()` to sync data to launcher widget
- **WearOS**: Rotary scroll support via `rotary_scrollbar` package, ambient mode via `wear_plus`
- **In-app updates**: `UpdateService.checkForUpdate()` triggers Android Play update flow

## Critical Gotchas

- **Don't use Provider**: Theme state management code is commented out; rebuild MaterialApp manually
- **WearOS requires explicit target**: Always specify `--target lib/wear/wear_main.dart` for wear builds
- **List groups vs. lists**: Groups are organizational only; lists are the actual data containers
- **Offline handling**: `ConnectivityService` shows dialog but app must handle Firestore offline persistence
- **Smart suggestions cache**: Service trains asynchronously; UI shows cached results immediately

## Testing & Debugging

- No automated tests currently (only manual device testing)
- Use `kDebugMode` checks for debug prints (see `main.dart` ConnectivityService init)
- Sentry captures all unhandled errors in production builds
- Test both flavors separately to catch platform-specific issues

## AI Agent Guidelines

- **DO NOT create README files**: Never create summary documents, README files, or markdown documentation files after completing tasks unless explicitly requested by the user.
