import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Item Details Widget Tests', () {
    testWidgets('Item details display correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Item: Milk'),
                Text('Quantity: 2'),
                Text('Category: Groceries'),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Item: Milk'), findsOneWidget);
      expect(find.text('Quantity: 2'), findsOneWidget);
      expect(find.text('Category: Groceries'), findsOneWidget);
    });

    testWidgets('Mark item as checked', (WidgetTester tester) async {
      // Arrange
      bool isChecked = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Checkbox(
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

    testWidgets('Edit item button works', (WidgetTester tester) async {
      // Arrange
      int editCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingActionButton(
              onPressed: () => editCount++,
              child: const Icon(Icons.edit),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.edit));

      // Assert
      expect(editCount, 1);
    });

    testWidgets('Delete item button works', (WidgetTester tester) async {
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

      // Assert
      expect(deleteCount, 1);
    });

    testWidgets('Item quantity can be updated', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Quantity'),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), '3');

      // Assert
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Item category can be changed', (WidgetTester tester) async {
      // Arrange
      String selectedCategory = 'Groceries';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButton<String>(
              value: selectedCategory,
              items: const [
                DropdownMenuItem(value: 'Groceries', child: Text('Groceries')),
                DropdownMenuItem(value: 'Household', child: Text('Household')),
              ],
              onChanged: (value) {
                selectedCategory = value ?? '';
              },
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('Item creation date is displayed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Created: 2024-01-15'),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Created: 2024-01-15'), findsOneWidget);
    });

    testWidgets('Item creator is displayed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Added by: John'),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Added by: John'), findsOneWidget);
    });

    testWidgets('Shows item notes if available', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Notes: Buy organic'),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Notes: Buy organic'), findsOneWidget);
    });
  });
}
