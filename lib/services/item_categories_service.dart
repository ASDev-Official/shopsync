import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoriesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get categories for a specific list
  static Stream<QuerySnapshot> getListCategories(String listId) {
    return _firestore
        .collection('lists')
        .doc(listId)
        .collection('categories')
        .orderBy('order')
        .snapshots();
  }

  // Create new category
  static Future<String> createCategory({
    required String listId,
    required String name,
    String? iconIdentifier,
  }) async {
    final user = _auth.currentUser;

    // Get next order value
    final existingCategories = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('categories')
        .get();

    final order = existingCategories.docs.length;

    final docRef = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('categories')
        .add({
      'name': name,
      'iconIdentifier': iconIdentifier,
      'order': order,
      'createdBy': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Update category
  static Future<void> updateCategory({
    required String listId,
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('lists')
        .doc(listId)
        .collection('categories')
        .doc(categoryId)
        .update(data);
  }

  // Delete category
  static Future<void> deleteCategory(String listId, String categoryId) async {
    // Remove category from items that use it
    final itemsWithCategory = await _firestore
        .collection('lists')
        .doc(listId)
        .collection('items')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    final batch = _firestore.batch();
    for (final item in itemsWithCategory.docs) {
      batch.update(item.reference, {'categoryId': FieldValue.delete()});
    }

    // Delete the category
    batch.delete(_firestore
        .collection('lists')
        .doc(listId)
        .collection('categories')
        .doc(categoryId));

    await batch.commit();
  }

  // Get default categories for new lists
  static List<Map<String, dynamic>> getDefaultCategories() {
    return [
      {
        'name': 'Groceries',
        'iconIdentifier': 'icon:fontAwesome:cart-shopping',
        'order': 0,
      },
      {
        'name': 'Household',
        'iconIdentifier': 'icon:fontAwesome:house',
        'order': 1,
      },
      {
        'name': 'Personal Care',
        'iconIdentifier': 'icon:fontAwesome:user',
        'order': 2,
      },
      {
        'name': 'Electronics',
        'iconIdentifier': 'icon:fontAwesome:mobile-screen',
        'order': 3,
      },
    ];
  }

  // Initialize default categories for a new list
  static Future<void> initializeDefaultCategories(String listId) async {
    final user = _auth.currentUser!;
    final defaultCategories = getDefaultCategories();
    final batch = _firestore.batch();

    for (final category in defaultCategories) {
      final docRef = _firestore
          .collection('lists')
          .doc(listId)
          .collection('categories')
          .doc();

      batch.set(docRef, {
        ...category,
        'createdBy': user.uid,
        'createdByName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
