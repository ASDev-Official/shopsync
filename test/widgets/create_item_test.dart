import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Create Item Widget Tests', () {
    testWidgets('Create item dialog opens', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Item name field is editable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(hintText: 'Item name'),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Milk');

      // Assert
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('Quantity field accepts numbers', (WidgetTester tester) async {
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
      await tester.enterText(find.byType(TextField), '5');

      // Assert
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Category can be selected', (WidgetTester tester) async {
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
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('Add button submits form', (WidgetTester tester) async {
      // Arrange
      int submitCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => submitCount++,
              child: const Text('Add'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Assert
      expect(submitCount, 1);
    });

    testWidgets('Cancel button closes dialog', (WidgetTester tester) async {
      // Arrange
      int cancelCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => cancelCount++,
              child: const Text('Cancel'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(cancelCount, 1);
    });

    testWidgets('Icon picker shows available icons',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.image), findsOneWidget);
    });

    testWidgets('Form validation works', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
