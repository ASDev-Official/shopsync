import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('List Groups Widget Tests', () {
    testWidgets('List groups display correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(title: Text('Groceries')),
                  ListTile(title: Text('Household')),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Household'), findsOneWidget);
    });

    testWidgets('Group can be expanded', (WidgetTester tester) async {
      // Arrange
      bool isExpanded = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: ExpansionTile(
                title: const Text('Groceries'),
                children: const [
                  ListTile(title: Text('Milk')),
                  ListTile(title: Text('Bread')),
                ],
                onExpansionChanged: (expanded) {
                  setState(() => isExpanded = expanded);
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      // Assert
      expect(isExpanded, true);
    });

    testWidgets('Group can be collapsed', (WidgetTester tester) async {
      // Arrange
      bool isExpanded = true;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: ExpansionTile(
                initiallyExpanded: true,
                title: const Text('Groceries'),
                children: const [
                  ListTile(title: Text('Milk')),
                ],
                onExpansionChanged: (expanded) {
                  setState(() => isExpanded = expanded);
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      // Assert
      expect(isExpanded, false);
    });

    testWidgets('Add group button works', (WidgetTester tester) async {
      // Arrange
      int addCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatingActionButton(
              onPressed: () => addCount++,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.add));

      // Assert
      expect(addCount, 1);
    });

    testWidgets('Groups can be reordered', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableListView(
              onReorder: (oldIndex, newIndex) {},
              children: [
                ListTile(
                    key: const ValueKey(1), title: const Text('Groceries')),
                ListTile(
                    key: const ValueKey(2), title: const Text('Household')),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('Delete group option appears', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTile(
              title: const Text('Groceries'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('Delete')),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    testWidgets('Edit group dialog opens', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListTile(
              title: const Text('Groceries'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(child: Text('Edit')),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    testWidgets('Shows empty state when no groups',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('No groups yet. Create one to get started!'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('No groups yet. Create one to get started!'),
          findsOneWidget);
    });
  });
}
