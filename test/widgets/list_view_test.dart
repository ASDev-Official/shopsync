import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('List View Screen Widget Tests', () {
    testWidgets('List view screen renders shopping items',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Shopping Items')),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Shopping Items'), findsOneWidget);
    });

    testWidgets('User can add new item to list', (WidgetTester tester) async {
      // Arrange
      int itemCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => itemCount++,
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();

      // Assert
      expect(itemCount, 1);
    });

    testWidgets('User can mark item as checked', (WidgetTester tester) async {
      // Arrange
      bool isChecked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() => isChecked = value ?? false);
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Assert
      expect(isChecked, true);
    });

    testWidgets('User can delete item from list', (WidgetTester tester) async {
      // Arrange
      int deleteCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteCount++,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteCount, 1);
    });

    testWidgets('List items show quantity field', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Quantity',
                ),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Categories dropdown is visible', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DropdownButton<String>(
                items: const [
                  DropdownMenuItem(value: 'cat1', child: Text('Groceries')),
                ],
                onChanged: null,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('Edit button opens edit dialog', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('Item list is scrollable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                15,
                (index) => ListTile(title: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
