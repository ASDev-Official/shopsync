import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Utility Functions Tests', () {
    test('Format currency correctly', () {
      // Arrange
      double amount = 19.99;

      // Act
      String formatted = '\$$amount';

      // Assert
      expect(formatted, contains('\$'));
      expect(formatted, contains('19.99'));
    });

    test('Parse date string correctly', () {
      // Arrange
      String dateString = '2024-01-15';

      // Act
      bool isValidDate = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString);

      // Assert
      expect(isValidDate, true);
    });

    test('Validate email format', () {
      // Arrange
      String validEmail = 'test@example.com';
      String invalidEmail = 'invalid-email';

      // Act
      bool isValidEmail =
          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(validEmail);
      bool isInvalidEmail =
          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(invalidEmail);

      // Assert
      expect(isValidEmail, true);
      expect(isInvalidEmail, false);
    });

    test('Truncate long text with ellipsis', () {
      // Arrange
      String longText = 'This is a very long string that needs to be truncated';
      int maxLength = 20;

      // Act
      String truncated = longText.length > maxLength
          ? '${longText.substring(0, maxLength)}...'
          : longText;

      // Assert
      expect(truncated.length, lessThanOrEqualTo(maxLength + 3));
      expect(truncated, contains('...'));
    });

    test('Convert list to comma-separated string', () {
      // Arrange
      List<String> items = ['Milk', 'Bread', 'Eggs'];

      // Act
      String joined = items.join(', ');

      // Assert
      expect(joined, 'Milk, Bread, Eggs');
    });

    test('Remove duplicates from list', () {
      // Arrange
      List<String> items = ['Milk', 'Bread', 'Milk', 'Eggs'];

      // Act
      List<String> unique = items.toSet().toList();

      // Assert
      expect(unique.length, 3);
      expect(unique.contains('Milk'), true);
    });

    test('Sort list alphabetically', () {
      // Arrange
      List<String> items = ['Zebra', 'Apple', 'Mango'];

      // Act
      items.sort();

      // Assert
      expect(items[0], 'Apple');
      expect(items[1], 'Mango');
      expect(items[2], 'Zebra');
    });

    test('Filter list by condition', () {
      // Arrange
      List<int> numbers = [1, 2, 3, 4, 5, 6];

      // Act
      List<int> evenNumbers = numbers.where((n) => n % 2 == 0).toList();

      // Assert
      expect(evenNumbers.length, 3);
      expect(evenNumbers, [2, 4, 6]);
    });

    test('Calculate list total', () {
      // Arrange
      List<int> quantities = [2, 3, 1, 4];

      // Act
      int total = quantities.reduce((a, b) => a + b);

      // Assert
      expect(total, 10);
    });

    test('Check if list is empty', () {
      // Arrange
      List<String> emptyList = [];
      List<String> filledList = ['Item'];

      // Act & Assert
      expect(emptyList.isEmpty, true);
      expect(filledList.isEmpty, false);
    });

    test('Get first and last item from list', () {
      // Arrange
      List<String> items = ['First', 'Middle', 'Last'];

      // Act
      String first = items.first;
      String last = items.last;

      // Assert
      expect(first, 'First');
      expect(last, 'Last');
    });

    test('Reverse list order', () {
      // Arrange
      List<String> items = ['First', 'Second', 'Third'];

      // Act
      List<String> reversed = items.reversed.toList();

      // Assert
      expect(reversed[0], 'Third');
      expect(reversed[2], 'First');
    });

    test('Find item in list', () {
      // Arrange
      List<String> items = ['Milk', 'Bread', 'Eggs'];
      String searchItem = 'Bread';

      // Act
      bool found = items.contains(searchItem);
      int index = items.indexOf(searchItem);

      // Assert
      expect(found, true);
      expect(index, 1);
    });

    test('Replace item in list', () {
      // Arrange
      List<String> items = ['Milk', 'Bread', 'Eggs'];

      // Act
      int index = items.indexOf('Bread');
      if (index != -1) {
        items[index] = 'Toast';
      }

      // Assert
      expect(items.contains('Toast'), true);
      expect(items.contains('Bread'), false);
    });

    test('Merge two lists', () {
      // Arrange
      List<String> list1 = ['Milk', 'Bread'];
      List<String> list2 = ['Eggs', 'Cheese'];

      // Act
      List<String> merged = [...list1, ...list2];

      // Assert
      expect(merged.length, 4);
      expect(merged.contains('Milk'), true);
      expect(merged.contains('Cheese'), true);
    });

    test('Capitalize first letter of string', () {
      // Arrange
      String text = 'hello world';

      // Act
      String capitalized =
          text.isNotEmpty ? text[0].toUpperCase() + text.substring(1) : text;

      // Assert
      expect(capitalized[0], 'H');
    });

    test('Convert string to lowercase', () {
      // Arrange
      String text = 'HELLO WORLD';

      // Act
      String lowercase = text.toLowerCase();

      // Assert
      expect(lowercase, 'hello world');
    });
  });
}
