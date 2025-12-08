import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - Basic Smoke Tests', () {
    testWidgets('Widget test framework works', (WidgetTester tester) async {
      // Build a simple widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Test Widget'),
          ),
        ),
      );

      // Verify the text is rendered
      expect(find.text('Test Widget'), findsOneWidget);
    });

    testWidgets('Material app renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test App')),
            body: const Center(
              child: Text('Hello, World!'),
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Hello, World!'), findsOneWidget);
    });

    testWidgets('Button tap interaction works', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => tapCount++,
                child: const Text('Tap Me'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(tapCount, 1);
    });
  });
}
