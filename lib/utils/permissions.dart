import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PermissionsHelper {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Check if the current user is a viewer for a given list
  static Future<bool> isViewer(String listId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return true; // Default to viewer if not authenticated
    }

    try {
      final listDoc = await _firestore.collection('lists').doc(listId).get();
      if (!listDoc.exists) return true;

      final data = listDoc.data() as Map<String, dynamic>;

      // Check if user is the owner
      if (data['createdBy'] == currentUserId) return false;

      // Check member role
      final memberRoles = Map<String, String>.from(data['memberRoles'] ?? {});
      final userRole = memberRoles[currentUserId] ?? 'viewer';

      return userRole == 'viewer';
    } catch (e) {
      return true; // Default to viewer on error
    }
  }

  /// Get the role of the current user for a given list
  static Future<String> getUserRole(String listId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return 'viewer';

    try {
      final listDoc = await _firestore.collection('lists').doc(listId).get();
      if (!listDoc.exists) return 'viewer';

      final data = listDoc.data() as Map<String, dynamic>;

      // Check if user is the owner
      if (data['createdBy'] == currentUserId) return 'owner';

      // Check member role
      final memberRoles = Map<String, String>.from(data['memberRoles'] ?? {});
      return memberRoles[currentUserId] ?? 'viewer';
    } catch (e) {
      return 'viewer';
    }
  }
}
