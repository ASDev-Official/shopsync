import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ListGroupsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new list group
  static Future<String?> createListGroup(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final docRef = await _firestore.collection('list_groups').add({
        'name': name,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'members': [user.uid],
        'position': await _getNextPosition(),
        'isExpanded': true,
        'listIds': <String>[],
      });

      return docRef.id;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'create_list_group',
          'group_name': name,
        }),
      );
      return null;
    }
  }

  // Update list group name
  static Future<bool> updateListGroupName(String groupId, String name) async {
    try {
      await _firestore.collection('list_groups').doc(groupId).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'update_list_group_name',
          'group_id': groupId,
          'group_name': name,
        }),
      );
      return false;
    }
  }

  // Delete a list group
  static Future<bool> deleteListGroup(String groupId) async {
    try {
      // First, get the group to find all lists that need to be ungrouped
      final groupDoc =
          await _firestore.collection('list_groups').doc(groupId).get();

      if (!groupDoc.exists) {
        return true; // Group doesn't exist, consider it successfully deleted
      }

      // Simply delete the group document
      // No need to update list documents since groupId field is no longer used
      await _firestore.collection('list_groups').doc(groupId).delete();

      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'delete_list_group',
          'group_id': groupId,
        }),
      );
      return false;
    }
  }

  // Add a list to a group
  static Future<bool> addListToGroup(String listId, String groupId) async {
    try {
      // Only update the group's listIds array
      // Don't set groupId on the list to allow multiple groups to contain the same list
      await _firestore.collection('list_groups').doc(groupId).update({
        'listIds': FieldValue.arrayUnion([listId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'add_list_to_group',
          'list_id': listId,
          'group_id': groupId,
        }),
      );
      return false;
    }
  }

  // Remove a list from a group
  static Future<bool> removeListFromGroup(String listId, String groupId) async {
    try {
      // Only remove listId from group's listIds array
      // Don't modify the list document since groupId field is no longer used
      await _firestore.collection('list_groups').doc(groupId).update({
        'listIds': FieldValue.arrayRemove([listId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'remove_list_from_group',
          'list_id': listId,
          'group_id': groupId,
        }),
      );
      return false;
    }
  }

  // Toggle group expansion state
  static Future<bool> toggleGroupExpansion(
      String groupId, bool isExpanded) async {
    try {
      await _firestore.collection('list_groups').doc(groupId).update({
        'isExpanded': isExpanded,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'toggle_group_expansion',
          'group_id': groupId,
          'is_expanded': isExpanded,
        }),
      );
      return false;
    }
  }

  // Reorder list groups
  static Future<bool> reorderListGroups(List<String> groupIds) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < groupIds.length; i++) {
        batch.update(_firestore.collection('list_groups').doc(groupIds[i]), {
          'position': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'reorder_list_groups',
          'group_ids': groupIds,
        }),
      );
      return false;
    }
  }

  // Get next position for new groups
  static Future<int> _getNextPosition() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection('list_groups')
          .where('members', arrayContains: user.uid)
          .orderBy('position', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final data = snapshot.docs.first.data();
      return (data['position'] ?? 0) + 1;
    } catch (e) {
      return 0;
    }
  }

  // Get user's list groups stream
  static Stream<QuerySnapshot> getUserListGroups() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('list_groups')
        .where('members', arrayContains: user.uid)
        .orderBy('position')
        .snapshots();
  }

  // Get ungrouped lists
  static Stream<List<QueryDocumentSnapshot>> getUngroupedLists() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('lists')
        .where('members', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // Get all existing groups and their listIds
      final groupsSnapshot = await _firestore
          .collection('list_groups')
          .where('members', arrayContains: user.uid)
          .get();

      // Collect all list IDs that are in any group
      final groupedListIds = <String>{};
      for (final groupDoc in groupsSnapshot.docs) {
        final data = groupDoc.data();
        final listIds = List<String>.from(data['listIds'] ?? []);
        groupedListIds.addAll(listIds);
      }

      // Filter out lists that are in any group
      final ungroupedDocs = snapshot.docs.where((doc) {
        return !groupedListIds.contains(doc.id);
      }).toList();

      return ungroupedDocs;
    });
  }

  // Get lists in a specific group
  static Stream<List<DocumentSnapshot>> getListsInGroup(String groupId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // Get the group document to retrieve listIds and combine with lists stream
    return _firestore
        .collection('list_groups')
        .doc(groupId)
        .snapshots()
        .asyncMap((groupSnapshot) async {
      if (!groupSnapshot.exists) {
        return <DocumentSnapshot>[];
      }

      final data = groupSnapshot.data() as Map<String, dynamic>;
      final listIds = List<String>.from(data['listIds'] ?? []);

      if (listIds.isEmpty) {
        return <DocumentSnapshot>[];
      }

      // Fetch lists in batches (Firestore whereIn limit is 10)
      final List<DocumentSnapshot> allDocs = [];

      for (int i = 0; i < listIds.length; i += 10) {
        final batchIds = listIds.sublist(
          i,
          i + 10 < listIds.length ? i + 10 : listIds.length,
        );

        final batchSnapshot = await _firestore
            .collection('lists')
            .where('members', arrayContains: user.uid)
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        allDocs.addAll(batchSnapshot.docs);
      }

      return allDocs;
    });
  }

  // Clean up orphaned list IDs in groups (list IDs that reference deleted lists)
  static Future<void> cleanupOrphanedLists() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get all user's groups
      final groupsSnapshot = await _firestore
          .collection('list_groups')
          .where('members', arrayContains: user.uid)
          .get();

      // Get all existing list IDs that user has access to
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .get();

      final existingListIds = listsSnapshot.docs.map((doc) => doc.id).toSet();

      // For each group, remove list IDs that reference non-existent lists
      final batch = _firestore.batch();
      bool needsUpdate = false;

      for (var groupDoc in groupsSnapshot.docs) {
        final data = groupDoc.data();
        final listIds = List<String>.from(data['listIds'] ?? []);
        final validListIds =
            listIds.where((id) => existingListIds.contains(id)).toList();

        if (validListIds.length != listIds.length) {
          batch.update(
            _firestore.collection('list_groups').doc(groupDoc.id),
            {
              'listIds': validListIds,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
          needsUpdate = true;
        }
      }

      if (needsUpdate) {
        await batch.commit();
      }
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'cleanup_orphaned_lists',
        }),
      );
    }
  }

  // Check if any lists still use the old groupId format
  static Future<bool> needsGroupIdMigration() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if any of the user's lists have a groupId field
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .get();

      for (var doc in listsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('groupId') && data['groupId'] != null) {
          return true;
        }
      }

      return false;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'check_needs_migration',
        }),
      );
      return false;
    }
  }

  // Migrate lists from old groupId format to new listIds array format
  static Future<bool> migrateGroupIdToListIds() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get all user's lists that have a groupId
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .get();

      // Group lists by their groupId
      final Map<String, List<String>> groupToLists = {};

      for (var doc in listsSnapshot.docs) {
        final data = doc.data();
        final groupId = data['groupId'] as String?;

        if (groupId != null) {
          if (!groupToLists.containsKey(groupId)) {
            groupToLists[groupId] = [];
          }
          groupToLists[groupId]!.add(doc.id);
        }
      }

      if (groupToLists.isEmpty) {
        return true; // No migration needed
      }

      // Update each group with its listIds
      var batch = _firestore.batch();
      int operationCount = 0;

      for (var entry in groupToLists.entries) {
        final groupId = entry.key;
        final listIds = entry.value;

        // Check if group still exists
        final groupDoc =
            await _firestore.collection('list_groups').doc(groupId).get();

        if (groupDoc.exists) {
          batch.update(_firestore.collection('list_groups').doc(groupId), {
            'listIds': FieldValue.arrayUnion(listIds),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          operationCount++;
        }

        // Commit in batches of 400 to avoid Firestore limits
        if (operationCount >= 400) {
          await batch.commit();
          batch = _firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      // Remove groupId field from all lists in batches
      var batch2 = _firestore.batch();
      operationCount = 0;

      for (var doc in listsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('groupId') && data['groupId'] != null) {
          batch2.update(_firestore.collection('lists').doc(doc.id), {
            'groupId': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          operationCount++;

          if (operationCount >= 400) {
            await batch2.commit();
            batch2 = _firestore.batch();
            operationCount = 0;
          }
        }
      }

      if (operationCount > 0) {
        await batch2.commit();
      }

      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'migrate_group_id_to_list_ids',
        }),
      );
      return false;
    }
  }
}
