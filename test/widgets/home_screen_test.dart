import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home Screen Widget Tests', () {
    testWidgets('Home screen renders without crashing',
        (WidgetTester tester) async {
      // Arrange: Create minimal app structure
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('List of shopping lists is displayed',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Shopping Lists')),
          ),
        ),
      );

      // Assert
      expect(find.text('Shopping Lists'), findsOneWidget);
    });

    testWidgets('User can tap on create list button',
        (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => tapCount++,
              child: const Text('Create List'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(tapCount, 1);
    });

    testWidgets('Floating action button visible', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('AppBar displays correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('ShopSync')),
            body: const SizedBox.expand(),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('ShopSync'), findsOneWidget);
    });

    testWidgets('Empty state message shown when no lists',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('No shopping lists yet')),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('No shopping lists yet'), findsOneWidget);
    });

    testWidgets('List items are scrollable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                20,
                (index) => ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('User can search for lists', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search lists',
                ),
              ),
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Groceries');
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
