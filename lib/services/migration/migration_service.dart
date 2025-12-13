import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MigrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _migrationCompleteKey = 'list_groups_migration_complete';
  static const String _migrationSkippedKey = 'list_groups_migration_skipped';

  // Check if user needs migration
  static Future<bool> needsMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final migrationComplete = prefs.getBool(_migrationCompleteKey) ?? false;
      final migrationSkipped = prefs.getBool(_migrationSkippedKey) ?? false;

      if (migrationComplete || migrationSkipped) {
        return false;
      }

      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if user has lists but no groups
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .limit(1)
          .get();

      final groupsSnapshot = await _firestore
          .collection('list_groups')
          .where('members', arrayContains: user.uid)
          .limit(1)
          .get();

      // Needs migration if has lists but no groups
      return listsSnapshot.docs.isNotEmpty && groupsSnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // Mark migration as complete
  static Future<void> markMigrationComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationCompleteKey, true);
  }

  // Mark migration as skipped
  static Future<void> markMigrationSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_migrationSkippedKey, true);
  }

  // Get user's lists for migration
  static Future<List<QueryDocumentSnapshot>> getUserLists() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs;
    } catch (e) {
      return [];
    }
  }

  // Create suggested groups based on list names
  static List<MigrationGroup> suggestGroups(List<QueryDocumentSnapshot> lists) {
    final Map<String, List<QueryDocumentSnapshot>> groupSuggestions = {};
    final List<QueryDocumentSnapshot> ungroupedLists = [];

    for (final list in lists) {
      final data = list.data() as Map<String, dynamic>;
      final listName = (data['name'] as String? ?? '').toLowerCase();

      String? suggestedGroup;

      // Basic categorization based on common keywords
      if (listName.contains('grocery') ||
          listName.contains('food') ||
          listName.contains('supermarket') ||
          listName.contains('market')) {
        suggestedGroup = 'Grocery Shopping';
      } else if (listName.contains('work') ||
          listName.contains('office') ||
          listName.contains('meeting') ||
          listName.contains('project')) {
        suggestedGroup = 'Work';
      } else if (listName.contains('home') ||
          listName.contains('house') ||
          listName.contains('chore') ||
          listName.contains('clean')) {
        suggestedGroup = 'Home & Garden';
      } else if (listName.contains('gift') ||
          listName.contains('birthday') ||
          listName.contains('holiday') ||
          listName.contains('christmas')) {
        suggestedGroup = 'Gifts & Events';
      } else if (listName.contains('travel') ||
          listName.contains('trip') ||
          listName.contains('vacation') ||
          listName.contains('pack')) {
        suggestedGroup = 'Travel';
      }

      if (suggestedGroup != null) {
        groupSuggestions.putIfAbsent(suggestedGroup, () => []);
        groupSuggestions[suggestedGroup]!.add(list);
      } else {
        ungroupedLists.add(list);
      }
    }

    final migrationGroups = <MigrationGroup>[];

    // Add suggested groups
    groupSuggestions.forEach((groupName, groupLists) {
      migrationGroups.add(MigrationGroup(
        name: groupName,
        lists: groupLists,
        isCustom: false,
      ));
    });

    // Add individual ungrouped lists as potential groups
    for (final list in ungroupedLists) {
      final data = list.data() as Map<String, dynamic>;
      final listName = data['name'] as String? ?? 'Unnamed List';
      migrationGroups.add(MigrationGroup(
        name: listName,
        lists: [list],
        isCustom: true,
      ));
    }

    return migrationGroups;
  }

  // Execute migration with selected groups
  static Future<bool> executeMigration(
      List<MigrationGroup> selectedGroups) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final batch = _firestore.batch();

      for (int i = 0; i < selectedGroups.length; i++) {
        final group = selectedGroups[i];

        // Create group document with listIds only
        // Don't set groupId on list documents to allow lists to be in multiple groups
        final groupRef = _firestore.collection('list_groups').doc();
        batch.set(groupRef, {
          'name': group.name,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'members': [user.uid],
          'position': i,
          'isExpanded': true,
          'listIds': group.lists.map((list) => list.id).toList(),
        });
      }

      await batch.commit();
      await markMigrationComplete();

      return true;
    } catch (error, stackTrace) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'action': 'execute_migration',
          'groups_count': selectedGroups.length,
        }),
      );
      return false;
    }
  }

  // Skip migration and mark as complete
  static Future<void> skipMigration() async {
    await markMigrationSkipped();
  }

  // Reset migration state (for testing)
  static Future<void> resetMigrationState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationCompleteKey);
    await prefs.remove(_migrationSkippedKey);
  }
}

class MigrationGroup {
  final String name;
  final List<QueryDocumentSnapshot> lists;
  final bool isCustom;
  bool isSelected;

  MigrationGroup({
    required this.name,
    required this.lists,
    required this.isCustom,
    this.isSelected = true,
  });

  MigrationGroup copyWith({
    String? name,
    List<QueryDocumentSnapshot>? lists,
    bool? isCustom,
    bool? isSelected,
  }) {
    return MigrationGroup(
      name: name ?? this.name,
      lists: lists ?? this.lists,
      isCustom: isCustom ?? this.isCustom,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
