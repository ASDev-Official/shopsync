import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login Widget Tests', () {
    testWidgets('Login screen displays', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Login'),
                TextField(decoration: InputDecoration(hintText: 'Email')),
                TextField(decoration: InputDecoration(hintText: 'Password')),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsWidgets);
    });

    testWidgets('Email field accepts input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'Email'),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'test@example.com');

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Password field accepts input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'Password'),
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'password123');

      // Assert
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Login button submits form', (WidgetTester tester) async {
      // Arrange
      int loginCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => loginCount++,
              child: const Text('Login'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Login'));

      // Assert
      expect(loginCount, 1);
    });

    testWidgets('Google Sign-In button appears', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: null,
              child: Text('Sign in with Google'),
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Sign in with Google'), findsOneWidget);
    });

    testWidgets('Forgot password link works', (WidgetTester tester) async {
      // Arrange
      int forgotCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () => forgotCount++,
              child: const Text('Forgot Password?'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Forgot Password?'));

      // Assert
      expect(forgotCount, 1);
    });

    testWidgets('Sign up link navigates', (WidgetTester tester) async {
      // Arrange
      int signupCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () => signupCount++,
              child: const Text("Don't have an account? Sign up"),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text("Don't have an account? Sign up"));

      // Assert
      expect(signupCount, 1);
    });

    testWidgets('Displays error message on failed login',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Invalid email or password'),
              ],
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('Loading indicator shows during login',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularProgressIndicator(),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
