import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CompletedCategoryBucket {
  final String? categoryId;
  final String? categoryName;
  final int completedCount;

  const CompletedCategoryBucket({
    required this.categoryId,
    required this.categoryName,
    required this.completedCount,
  });
}

class ListCategoryOption {
  final String id;
  final String name;

  const ListCategoryOption({
    required this.id,
    required this.name,
  });
}

class CompletedItemsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static void _logIndexCreationLinkIfNeeded(
    Object error, {
    required String action,
    required String listId,
  }) {
    if (error is! FirebaseException) {
      return;
    }

    if (error.code != 'failed-precondition') {
      return;
    }

    final message = error.message ?? '';
    final match = RegExp(r'https://console\\.firebase\\.google\\.com/\\S+')
        .firstMatch(message);

    if (match != null) {
      debugPrint(
        '[CompletedItemsService] Missing Firestore index for $action '
        '(listId: $listId). Create it here: ${match.group(0)}',
      );
      return;
    }

    debugPrint(
      '[CompletedItemsService] Firestore failed-precondition for $action '
      '(listId: $listId). Message: $message',
    );
  }

  static bool _isItemCompleted(Map<String, dynamic> data) {
    return data['completed'] == true || data['checked'] == true;
  }

  static String? _normalizedCategoryId(dynamic categoryIdRaw) {
    if (categoryIdRaw is! String) {
      return null;
    }

    final trimmed = categoryIdRaw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  static String? _normalizedCategoryName(dynamic categoryNameRaw) {
    if (categoryNameRaw is! String) {
      return null;
    }

    final trimmed = categoryNameRaw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  static String? _resolveCategoryIdFromItem(
    Map<String, dynamic> itemData,
    Map<String, String> categoryIdByLowerName,
  ) {
    final categoryId = _normalizedCategoryId(itemData['categoryId']);
    if (categoryId != null) {
      return categoryId;
    }

    final categoryName = _normalizedCategoryName(itemData['categoryName']);
    if (categoryName == null) {
      return null;
    }

    return categoryIdByLowerName[categoryName.toLowerCase()];
  }

  static Future<List<CompletedCategoryBucket>> getCompletedCategoryBuckets(
      String listId) async {
    try {
      final itemsSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .get();

      final completedItems = itemsSnapshot.docs.where((doc) {
        final data = doc.data();
        return _isItemCompleted(data);
      }).toList();

      if (completedItems.isEmpty) {
        return const [];
      }

      final categoriesSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('categories')
          .get();

      final Map<String, String> categoryNames = {
        for (final categoryDoc in categoriesSnapshot.docs)
          categoryDoc.id: (categoryDoc.data()['name'] as String?)?.trim() ?? '',
      };

      final Map<String, String> categoryIdByLowerName = {
        for (final categoryDoc in categoriesSnapshot.docs)
          if (((categoryDoc.data()['name'] as String?)?.trim().isNotEmpty ??
              false))
            (categoryDoc.data()['name'] as String).trim().toLowerCase():
                categoryDoc.id,
      };

      final Map<String?, int> categoryCounts = <String?, int>{};
      for (final itemDoc in completedItems) {
        final data = itemDoc.data();
        final categoryId = _resolveCategoryIdFromItem(
          data,
          categoryIdByLowerName,
        );
        categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
      }

      final buckets = categoryCounts.entries
          .map(
            (entry) => CompletedCategoryBucket(
              categoryId: entry.key,
              categoryName:
                  entry.key == null ? null : categoryNames[entry.key]?.trim(),
              completedCount: entry.value,
            ),
          )
          .toList();

      buckets.sort((a, b) {
        final aName = (a.categoryName == null || a.categoryName!.isEmpty)
            ? 'zzzz_no_category'
            : a.categoryName!.toLowerCase();
        final bName = (b.categoryName == null || b.categoryName!.isEmpty)
            ? 'zzzz_no_category'
            : b.categoryName!.toLowerCase();
        return aName.compareTo(bName);
      });

      return buckets;
    } catch (e, stackTrace) {
      _logIndexCreationLinkIfNeeded(
        e,
        action: 'get_completed_category_buckets',
        listId: listId,
      );
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'get_completed_category_buckets',
          'listId': listId,
        }),
      );
      rethrow;
    }
  }

  static Future<List<ListCategoryOption>> getListCategories(
      String listId) async {
    try {
      final categoriesSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('categories')
          .orderBy('order', descending: false)
          .get();

      return categoriesSnapshot.docs.map((doc) {
        final data = doc.data();
        final name = (data['name'] as String?)?.trim();
        return ListCategoryOption(
          id: doc.id,
          name: (name == null || name.isEmpty) ? doc.id : name,
        );
      }).toList();
    } catch (e, stackTrace) {
      _logIndexCreationLinkIfNeeded(
        e,
        action: 'get_list_categories',
        listId: listId,
      );
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'get_list_categories',
          'listId': listId,
        }),
      );
      rethrow;
    }
  }

  static Future<int> clearCompletedItems({
    required String listId,
    Set<String>? categoryIds,
    bool clearOnlyUncategorized = false,
  }) async {
    try {
      final itemsSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .get();

      final categoriesSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('categories')
          .get();

      final Map<String, String> categoryIdByLowerName = {
        for (final categoryDoc in categoriesSnapshot.docs)
          if (((categoryDoc.data()['name'] as String?)?.trim().isNotEmpty ??
              false))
            (categoryDoc.data()['name'] as String).trim().toLowerCase():
                categoryDoc.id,
      };

      final normalizedCategoryIds = categoryIds
          ?.map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toSet();

      final completedItems = itemsSnapshot.docs.where((doc) {
        final data = doc.data();
        return _isItemCompleted(data);
      }).toList();

      final docsToClear = completedItems.where((doc) {
        final data = doc.data();
        final categoryId = _resolveCategoryIdFromItem(
          data,
          categoryIdByLowerName,
        );

        if (clearOnlyUncategorized) {
          return categoryId == null;
        }

        if (normalizedCategoryIds == null || normalizedCategoryIds.isEmpty) {
          return true;
        }

        return categoryId != null && normalizedCategoryIds.contains(categoryId);
      }).toList();

      if (docsToClear.isEmpty) {
        return 0;
      }

      final currentUser = _auth.currentUser;
      const maxDocsPerBatch = 250; // 250 docs * (set + delete) = 500 ops

      for (var i = 0; i < docsToClear.length; i += maxDocsPerBatch) {
        final chunk = docsToClear.skip(i).take(maxDocsPerBatch);
        final batch = _firestore.batch();

        for (final doc in chunk) {
          final itemData = doc.data();

          batch.set(
            _firestore
                .collection('lists')
                .doc(listId)
                .collection('recycled_items')
                .doc(),
            {
              ...itemData,
              'originalItemId': doc.id,
              'deletedAt': FieldValue.serverTimestamp(),
              'deletedBy': currentUser?.uid,
              'deletedByName': currentUser?.displayName,
            },
          );

          batch.delete(doc.reference);
        }

        await batch.commit();
      }

      return docsToClear.length;
    } catch (e, stackTrace) {
      _logIndexCreationLinkIfNeeded(
        e,
        action: 'clear_completed_items',
        listId: listId,
      );
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'clear_completed_items',
          'listId': listId,
          'categoryIdsCount': categoryIds?.length,
          'clearOnlyUncategorized': clearOnlyUncategorized,
        }),
      );
      rethrow;
    }
  }
}
