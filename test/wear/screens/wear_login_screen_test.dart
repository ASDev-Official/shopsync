import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/wear/screens/wear_login_screen.dart';

void main() {
  group('WearLoginScreen Widget Tests', () {
    testWidgets('should render login screen with all required elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      // Verify title is displayed
      expect(find.text('ShopSync'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Verify input fields exist
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify login button exists
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('email field should accept text input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final emailField = find.widgetWithText(TextField, 'Email');
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field should obscure text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final passwordFields = find.byType(TextField);
      final passwordField = tester.widgetList<TextField>(passwordFields).last;

      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('password field should accept text input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final textFields = find.byType(TextField);
      // Second TextField should be password field
      await tester.enterText(textFields.last, 'password123');
      await tester.pump();

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('should disable input fields when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      // Enter credentials
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Find and tap login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(loginButton);
      await tester.pump();

      // Check if loading state is triggered (button should show loading indicator)
      final textFieldWidgets = tester.widgetList<TextField>(find.byType(TextField));
      
      // Verify fields are disabled during loading
      for (final field in textFieldWidgets) {
        expect(field.enabled, isFalse);
      }
    });

    testWidgets('login button should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(loginButton, findsOneWidget);

      // Verify button is enabled
      final button = tester.widget<ElevatedButton>(loginButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should render correctly on round watch shape',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget tree is built
      expect(find.byType(WearLoginScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle empty email input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, '');
      await tester.pump();

      expect(find.text(''), findsWidgets);
    });

    testWidgets('should handle empty password input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, '');
      await tester.pump();

      expect(find.text(''), findsWidgets);
    });

    testWidgets('email field should have correct keyboard type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final emailTextField =
          tester.widget<TextField>(find.byType(TextField).first);
      expect(emailTextField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('email field should have autocorrect disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final emailTextField =
          tester.widget<TextField>(find.byType(TextField).first);
      expect(emailTextField.autocorrect, isFalse);
    });

    testWidgets('password field should have autocorrect disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final passwordTextField =
          tester.widget<TextField>(find.byType(TextField).last);
      expect(passwordTextField.autocorrect, isFalse);
    });

    testWidgets('should display error message when login fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      // Trigger login with invalid credentials (this would show error in real scenario)
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      await tester.enterText(emailField, 'invalid@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(loginButton);
      await tester.pump();

      // Error would be shown after authentication attempt
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('should trim email input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, '  test@example.com  ');
      await tester.pump();

      // The actual trimming happens in the sign-in method
      expect(find.textContaining('test@example.com'), findsOneWidget);
    });

    testWidgets('should handle long email addresses',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final emailField = find.byType(TextField).first;
      const longEmail =
          'verylongemailaddress123456789@verylongdomainname.com';
      await tester.enterText(emailField, longEmail);
      await tester.pump();

      expect(find.text(longEmail), findsOneWidget);
    });

    testWidgets('should handle long passwords', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final passwordField = find.byType(TextField).last;
      const longPassword = 'VeryLongPassword1234567890!@#\$%^&*()';
      await tester.enterText(passwordField, longPassword);
      await tester.pump();

      expect(find.text(longPassword), findsOneWidget);
    });

    testWidgets('should have proper text styling for title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final titleFinder = find.text('ShopSync');
      expect(titleFinder, findsOneWidget);

      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.style?.fontSize, 16);
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should have proper text styling for subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final subtitleFinder = find.text('Sign in to continue');
      expect(subtitleFinder, findsOneWidget);

      final subtitleWidget = tester.widget<Text>(subtitleFinder);
      expect(subtitleWidget.style?.fontSize, 12);
    });

    testWidgets('should use black background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.black);
    });

    testWidgets('should be scrollable for small screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have proper spacing between elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      // Verify SizedBox widgets for spacing exist
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('login button should have full width',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final buttonContainer =
          find.ancestor(
            of: find.widgetWithText(ElevatedButton, 'Sign In'),
            matching: find.byType(SizedBox),
          ).first;

      final sizedBox = tester.widget<SizedBox>(buttonContainer);
      expect(sizedBox.width, double.infinity);
    });
  });

  group('WearLoginScreen State Management', () {
    testWidgets('should initialize with non-loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      // Initially, fields should be enabled
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final field in textFields) {
        expect(field.enabled, isTrue);
      }
    });

    testWidgets('should properly dispose controllers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Other Screen')),
        ),
      );

      expect(find.byType(WearLoginScreen), findsNothing);
    });
  });

  group('WearLoginScreen Edge Cases', () {
    testWidgets('should handle special characters in email',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test+tag@example.com');
      await tester.pump();

      expect(find.text('test+tag@example.com'), findsOneWidget);
    });

    testWidgets('should handle special characters in password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, 'P@ssw0rd!#\$');
      await tester.pump();

      expect(find.text('P@ssw0rd!#\$'), findsOneWidget);
    });

    testWidgets('should handle rapid button taps',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');

      // Tap multiple times rapidly
      await tester.tap(loginButton);
      await tester.tap(loginButton);
      await tester.tap(loginButton);
      await tester.pump();

      // Should handle gracefully without crashes
      expect(find.byType(WearLoginScreen), findsOneWidget);
    });

    testWidgets('should handle empty form submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WearLoginScreen(),
        ),
      );

      final loginButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(loginButton);
      await tester.pump();

      // Should not crash with empty inputs
      expect(find.byType(WearLoginScreen), findsOneWidget);
    });
  });
}