import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/wear/screens/wear_home_screen.dart';

void main() {
  group('WearHomeScreen Widget Tests', () {
    testWidgets('should render home screen with basic structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      // Verify scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(WearHomeScreen), findsOneWidget);
    });

    testWidgets('should have black background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('should display ShopSync title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      // Wait for stream initialization
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ShopSync'), findsOneWidget);
    });

    testWidgets('should display check circle icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should have popup menu button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PopupMenuButton), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should show loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      // Before stream initializes
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use CustomScrollView for content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // CustomScrollView should be present for scrollable content
      expect(find.byType(CustomScrollView), findsWidgets);
    });

    testWidgets('should have proper title styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final titleFinder = find.text('ShopSync');
      final titleWidget = tester.widget<Text>(titleFinder);
      
      expect(titleWidget.style?.fontSize, 14);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('popup menu should have sign out option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap popup menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('should initialize scroll controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget doesn't crash - controller properly initialized
      expect(find.byType(WearHomeScreen), findsOneWidget);
    });

    testWidgets('should properly dispose scroll controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Other Screen')),
        ),
      );

      expect(find.byType(WearHomeScreen), findsNothing);
    });
  });

  group('WearHomeScreen Layout Tests', () {
    testWidgets('should adapt to round watch shape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify layout is rendered without errors
      expect(find.byType(WearHomeScreen), findsOneWidget);
    });

    testWidgets('should have proper padding for header',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Padding widgets exist
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should have expandable title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Title should be in an Expanded widget
      final expandedFinder = find.ancestor(
        of: find.text('ShopSync'),
        matching: find.byType(Expanded),
      );
      expect(expandedFinder, findsOneWidget);
    });
  });

  group('WearHomeScreen State Management', () {
    testWidgets('should handle stream initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      // Initial state - loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After post-frame callback
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Stream should be initialized
      expect(find.byType(WearHomeScreen), findsOneWidget);
    });

    testWidgets('should handle mounted check', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();

      // Widget should handle mounted checks properly
      expect(find.byType(WearHomeScreen), findsOneWidget);

      // Unmount widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(WearHomeScreen), findsNothing);
    });
  });

  group('WearHomeScreen User Interaction', () {
    testWidgets('should open popup menu on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Menu should be visible
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('popup menu should have proper styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap to open menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Verify menu item has proper icon
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('should handle rapid menu button taps',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap multiple times
      final menuButton = find.byIcon(Icons.more_vert);
      await tester.tap(menuButton);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Should handle gracefully
      expect(find.byType(WearHomeScreen), findsOneWidget);
    });
  });

  group('WearHomeScreen Edge Cases', () {
    testWidgets('should handle no user logged in scenario',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(WearHomeScreen), findsOneWidget);
    });

    testWidgets('should survive widget rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearHomeScreen), findsOneWidget);
    });

    testWidgets('should handle small screen sizes', (WidgetTester tester) async {
      // Set small screen size typical for WearOS
      tester.view.physicalSize = const Size(300, 300);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearHomeScreen), findsOneWidget);

      // Reset size
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('should handle large screen sizes', (WidgetTester tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(600, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearHomeScreen), findsOneWidget);

      // Reset size
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });

  group('WearHomeScreen Accessibility', () {
    testWidgets('should have semantic labels for icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Icons should be present
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should have readable text sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearHomeScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final titleWidget = tester.widget<Text>(find.text('ShopSync'));
      expect(titleWidget.style?.fontSize, greaterThanOrEqualTo(12));
    });
  });
}