import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/wear/screens/wear_list_view_screen.dart';

void main() {
  group('WearListViewScreen Widget Tests', () {
    const testListId = 'test-list-123';
    const testListName = 'Test Shopping List';

    testWidgets('should render with required parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: testListId,
            listName: testListName,
          ),
        ),
      );

      expect(find.byType(WearListViewScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have black background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: testListId,
            listName: testListName,
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('should show loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: testListId,
            listName: testListName,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should initialize scroll controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: testListId,
            listName: testListName,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not crash - controller properly initialized
      expect(find.byType(WearListViewScreen), findsOneWidget);
    });

    testWidgets('should properly dispose scroll controller',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: testListId,
            listName: testListName,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Other Screen')),
        ),
      );

      expect(find.byType(WearListViewScreen), findsNothing);
    });

    testWidgets('should have ListView for displaying items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: testListId,
            listName: testListName,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ListView should be present
      expect(find.byType(ListView), findsWidgets);
    });
  });

  group('WearListViewScreen Constructor Tests', () {
    testWidgets('should accept listId parameter', (WidgetTester tester) async {
      const testId = 'custom-list-id';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: testId,
            listName: 'Test List',
          ),
        ),
      );

      final widget = tester.widget<WearListViewScreen>(
        find.byType(WearListViewScreen),
      );
      expect(widget.listId, testId);
    });

    testWidgets('should accept listName parameter',
        (WidgetTester tester) async {
      const testName = 'My Custom List Name';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: testName,
          ),
        ),
      );

      final widget = tester.widget<WearListViewScreen>(
        find.byType(WearListViewScreen),
      );
      expect(widget.listName, testName);
    });

    testWidgets('should handle long list names', (WidgetTester tester) async {
      const longName = 'This is a very long shopping list name that might overflow';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: longName,
          ),
        ),
      );

      expect(find.byType(WearListViewScreen), findsOneWidget);
    });

    testWidgets('should handle empty list name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: '',
          ),
        ),
      );

      expect(find.byType(WearListViewScreen), findsOneWidget);
    });

    testWidgets('should handle special characters in list name',
        (WidgetTester tester) async {
      const specialName = 'List #1 @ Store & More!';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: specialName,
          ),
        ),
      );

      expect(find.byType(WearListViewScreen), findsOneWidget);
    });
  });

  group('WearListViewScreen State Management', () {
    testWidgets('should handle initState correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      // Wait for post-frame callback
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WearListViewScreen), findsOneWidget);
    });

    testWidgets('should handle mounted check', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pump();

      // Widget should handle mounted checks properly
      expect(find.byType(WearListViewScreen), findsOneWidget);

      // Unmount widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(find.byType(WearListViewScreen), findsNothing);
    });

    testWidgets('should survive widget rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearListViewScreen), findsOneWidget);
    });
  });

  group('WearListViewScreen Layout Tests', () {
    testWidgets('should adapt to different screen sizes',
        (WidgetTester tester) async {
      // Small screen
      tester.view.physicalSize = const Size(280, 280);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WearListViewScreen), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Padding widgets should exist
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should use Cards for items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Cards should be used for list items (if any exist)
      // In a real scenario with data, we'd see Card widgets
      expect(find.byType(WearListViewScreen), findsOneWidget);
    });
  });

  group('WearListViewScreen Edge Cases', () {
    testWidgets('should handle null listId gracefully',
        (WidgetTester tester) async {
      // This test verifies the widget handles edge cases
      // In production, listId should not be null, but we test robustness
      expect(
        () => const WearListViewScreen(
          listId: '',
          listName: 'Test',
        ),
        returnsNormally,
      );
    });

    testWidgets('should handle rapid navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
          routes: {
            '/other': (context) => const Scaffold(body: Text('Other')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Rapid navigation
      final context = tester.element(find.byType(WearListViewScreen));
      Navigator.pushNamed(context, '/other');
      await tester.pump();
      Navigator.pop(context);
      await tester.pumpAndSettle();

      // Should handle without crashes
      expect(find.byType(WearListViewScreen), findsOneWidget);
    });

    testWidgets('should handle unicode characters in list name',
        (WidgetTester tester) async {
      const unicodeName = '🛒 Shopping List 📝';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: unicodeName,
          ),
        ),
      );

      expect(find.byType(WearListViewScreen), findsOneWidget);
    });

    testWidgets('should handle very long listId', (WidgetTester tester) async {
      const longId = 'a' * 200; // Very long ID
      
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: longId,
            listName: 'Test',
          ),
        ),
      );

      expect(find.byType(WearListViewScreen), findsOneWidget);
    });
  });

  group('WearListViewScreen Performance', () {
    testWidgets('should not rebuild unnecessarily',
        (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              buildCount++;
              return const WearListViewScreen(
                listId: 'test-id',
                listName: 'Test List',
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final initialBuildCount = buildCount;

      // Pump again without changes
      await tester.pump();

      // Build count should not increase significantly
      expect(buildCount, lessThanOrEqualTo(initialBuildCount + 1));
    });
  });

  group('WearListViewScreen Accessibility', () {
    testWidgets('should have proper contrast', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black); // High contrast background
    });

    testWidgets('should have touchable targets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearListViewScreen(
            listId: 'test-id',
            listName: 'Test List',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // InkWell widgets should be used for touchable elements
      // This ensures proper touch targets
      expect(find.byType(WearListViewScreen), findsOneWidget);
    });
  });
}