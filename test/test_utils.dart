import 'package:flutter_test/flutter_test.dart';

/// Mock Firebase setup for testing
/// Note: Testing will be done against FakeFirebaseFirestore instances created in each test
class FirebaseTestSetup {
  /// Initialize test environment
  static void setup() {
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Reset state between tests
  static Future<void> resetState() async {
    // Reset state as needed between tests
  }
}

/// Test data generators
class TestDataGenerator {
  static Map<String, dynamic> createListGroup({
    String? id,
    String name = 'Test Group',
    String createdBy = 'test-user-123',
    List<String>? members,
    List<String>? listIds,
    bool isExpanded = true,
    int position = 0,
  }) {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      'members': members ?? [createdBy],
      'position': position,
      'isExpanded': isExpanded,
      'listIds': listIds ?? [],
    };
  }

  static Map<String, dynamic> createShoppingList({
    String? id,
    String name = 'Test List',
    String createdBy = 'test-user-123',
    List<String>? members,
    String color = '#FF6B6B',
    String? place,
    bool isRecycleBin = false,
  }) {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      'members': members ?? [createdBy],
      'color': color,
      'place': place,
      'isRecycleBin': isRecycleBin,
      'items': {},
    };
  }

  static Map<String, dynamic> createCategory({
    String name = 'Groceries',
    String? iconIdentifier = 'icon:fontAwesome:cart-shopping',
    int order = 0,
    String createdBy = 'test-user-123',
  }) {
    return {
      'name': name,
      'iconIdentifier': iconIdentifier,
      'order': order,
      'createdBy': createdBy,
      'createdAt': DateTime.now(),
    };
  }

  static Map<String, dynamic> createItem({
    String name = 'Test Item',
    bool checked = false,
    int quantity = 1,
    String? categoryId,
    bool deleted = false,
    String createdBy = 'test-user-123',
  }) {
    return {
      'name': name,
      'checked': checked,
      'quantity': quantity,
      'categoryId': categoryId,
      'deleted': deleted,
      'createdBy': createdBy,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }
}

/// Custom Flutter test bindings with Firebase setup
void setupTestEnvironment() {
  FirebaseTestSetup.setup();
}
