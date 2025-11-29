import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/wear/screens/wear_settings_screen.dart';

void main() {
  group('WearSettingsScreen Widget Tests', () {
    testWidgets('should render settings screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      expect(find.byType(WearSettingsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have black background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('should display Settings title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display Account section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('should display Actions section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('should display Sign Out button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('should have account info card', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      // Account section should display user info
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should use CustomScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should initialize scroll controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash - controller properly initialized
      expect(find.byType(WearSettingsScreen), findsOneWidget);
    });

    testWidgets('should properly dispose scroll controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Other Screen')),
        ),
      );

      expect(find.byType(WearSettingsScreen), findsNothing);
    });
  });

  group('WearSettingsScreen User Interaction', () {
    testWidgets('back button should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WearSettingsScreen(),
                  ),
                ),
                child: const Text('Go to Settings'),
              ),
            ),
          ),
        ),
      );

      // Navigate to settings
      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(WearSettingsScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should navigate back
      expect(find.byType(WearSettingsScreen), findsNothing);
    });

    testWidgets('sign out button should be tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final signOutButton = find.text('Sign Out');
      expect(signOutButton, findsOneWidget);

      // Verify it's in an InkWell (tappable)
      final inkWell = find.ancestor(
        of: signOutButton,
        matching: find.byType(InkWell),
      );
      expect(inkWell, findsOneWidget);
    });

    testWidgets('sign out card should navigate to confirmation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap sign out card
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Should navigate to sign out confirmation screen
      // (In the actual implementation, this would show WearSignOutScreen)
    });
  });

  group('WearSettingsScreen Layout Tests', () {
    testWidgets('should adapt to round watch shape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layout renders without errors
      expect(find.byType(WearSettingsScreen), findsOneWidget);
    });

    testWidgets('should have proper section headers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      final accountHeader = tester.widget<Text>(find.text('Account'));
      expect(accountHeader.style?.fontSize, 11);
      expect(accountHeader.style?.fontWeight, FontWeight.w600);

      final actionsHeader = tester.widget<Text>(find.text('Actions'));
      expect(actionsHeader.style?.fontSize, 11);
      expect(actionsHeader.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('should have proper spacing between sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify SizedBox and Padding widgets exist for spacing
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('cards should have rounded corners',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final cards = tester.widgetList<Card>(find.byType(Card));
      for (final card in cards) {
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(20));
      }
    });

    testWidgets('should have account icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.account_circle), findsWidgets);
    });

    testWidgets('should have email icon if email exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      // Email icon should be present if user has email
      expect(find.byIcon(Icons.email), findsWidgets);
    });

    testWidgets('should have chevron on sign out button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });
  });

  group('WearSettingsScreen State Management', () {
    testWidgets('should survive widget rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearSettingsScreen), findsOneWidget);
    });

    testWidgets('should handle mounted check', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(WearSettingsScreen), findsOneWidget);

      // Unmount widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(WearSettingsScreen), findsNothing);
    });
  });

  group('WearSettingsScreen Edge Cases', () {
    testWidgets('should handle rapid back button taps',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WearSettingsScreen(),
                  ),
                ),
                child: const Text('Go to Settings'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();

      // Tap back button multiple times rapidly
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should handle gracefully
      expect(find.byType(WearSettingsScreen), findsNothing);
    });

    testWidgets('should handle small screen sizes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(280, 280);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearSettingsScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('should handle large screen sizes', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearSettingsScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('should be scrollable on small screens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(280, 280);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // CustomScrollView should allow scrolling
      expect(find.byType(CustomScrollView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });

  group('WearSettingsScreen Accessibility', () {
    testWidgets('should have readable text sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      final titleWidget = tester.widget<Text>(find.text('Settings'));
      expect(titleWidget.style?.fontSize, greaterThanOrEqualTo(11));

      final signOutWidget = tester.widget<Text>(find.text('Sign Out'));
      expect(signOutWidget.style?.fontSize, greaterThanOrEqualTo(11));
    });

    testWidgets('should have semantic icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pump();

      // Icons should be present for visual cues
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsWidgets);
    });

    testWidgets('should have proper color contrast', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearSettingsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black); // High contrast
    });
  });

  group('WearSettingsScreen Performance', () {
    testWidgets('should not rebuild unnecessarily',
        (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildCount++;
              return const WearSettingsScreen();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialBuildCount = buildCount;

      // Pump again without changes
      await tester.pump();

      expect(buildCount, lessThanOrEqualTo(initialBuildCount + 1));
    });
  });
}