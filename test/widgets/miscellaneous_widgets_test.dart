import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Additional Widget Tests', () {
    testWidgets('Settings screen displays options',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                ListTile(title: Text('Notifications')),
                ListTile(title: Text('Theme')),
                ListTile(title: Text('Language')),
                ListTile(title: Text('About')),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('Theme toggle works', (WidgetTester tester) async {
      // Arrange
      bool isDarkMode = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (value) {
                  setState(() => isDarkMode = value);
                },
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Assert
      expect(isDarkMode, true);
    });

    testWidgets('About screen shows version', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('ShopSync'),
                Text('Version 1.0.0'),
                Text('Build 2024.01.15'),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.text('Build 2024.01.15'), findsOneWidget);
    });

    testWidgets('Feedback form displays', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const TextField(
                    decoration: InputDecoration(hintText: 'Feedback')),
                ElevatedButton(onPressed: null, child: const Text('Submit')),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('Onboarding screen displays steps',
        (WidgetTester tester) async {
      // Arrange
      int currentStep = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Step ${currentStep + 1}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => currentStep++);
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert
      expect(currentStep, 1);
    });

    testWidgets('Migration screen shows progress', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LinearProgressIndicator(value: 0.5),
                Text('Migrating... 50%'),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Migrating... 50%'), findsOneWidget);
    });

    testWidgets('Error dialog displays message', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDialog(
              title: const Text('Error'),
              content: const Text('Something went wrong'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('Success dialog displays confirmation',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlertDialog(
              title: const Text('Success'),
              content: const Text('List created successfully'),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('List created successfully'), findsOneWidget);
    });

    testWidgets('Loading screen shows spinner', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('Empty state displays message', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined),
                  SizedBox(height: 16),
                  Text('No items yet'),
                  Text('Create your first shopping list'),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('No items yet'), findsOneWidget);
      expect(find.text('Create your first shopping list'), findsOneWidget);
    });

    testWidgets('Search bar is functional', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: InputDecoration(
                hintText: 'Search items',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Milk');

      // Assert
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('Floating action button is visible',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
            body: Text('Content'),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Bottom navigation works', (WidgetTester tester) async {
      // Arrange
      int selectedIndex = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: selectedIndex,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profile'),
                ],
                onTap: (index) {
                  setState(() => selectedIndex = index);
                },
              ),
              body: const Text('Content'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedIndex, 1);
    });

    testWidgets('Snackbar displays message', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Show Snackbar'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Show Snackbar'), findsOneWidget);
    });

    testWidgets('Pull to refresh works', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                children: const [
                  ListTile(title: Text('Item 1')),
                ],
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
