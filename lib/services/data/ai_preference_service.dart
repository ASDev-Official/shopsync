import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Service for managing user AI preference settings
class AIPreferenceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user has set their AI preference
  static Future<bool> hasAIPreference() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final data = userDoc.data();
      return data?.containsKey('aiEnabled') ?? false;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'check_ai_preference'}));
      if (kDebugMode) {
        print('Error checking AI preference: $e');
      }
      return false;
    }
  }

  /// Get user's AI preference (null if not set)
  static Future<bool?> getAIPreference() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data();
      if (data == null || !data.containsKey('aiEnabled')) return null;

      return data['aiEnabled'] as bool?;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'get_ai_preference'}));
      if (kDebugMode) {
        print('Error getting AI preference: $e');
      }
      return null;
    }
  }

  /// Set user's AI preference
  static Future<void> setAIPreference(bool enabled) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('users').doc(user.uid).update({
        'aiEnabled': enabled,
        'aiPreferenceUpdatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('AI preference set to: $enabled for user ${user.uid}');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap(
              {'action': 'set_ai_preference', 'enabled': enabled}));
      if (kDebugMode) {
        print('Error setting AI preference: $e');
      }
      rethrow;
    }
  }

  /// Initialize AI preference field for existing user
  /// This is called when user doesn't have the field set yet
  static Future<void> initializeAIPreference(bool defaultValue) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        // Only set if not already present
        if (data == null || !data.containsKey('aiEnabled')) {
          await userDoc.update({
            'aiEnabled': defaultValue,
            'aiPreferenceUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      if (kDebugMode) {
        print(
            'Initialized AI preference to: $defaultValue for user ${user.uid}');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({
            'action': 'initialize_ai_preference',
            'default_value': defaultValue
          }));
      if (kDebugMode) {
        print('Error initializing AI preference: $e');
      }
      rethrow;
    }
  }

  /// Check if AI features are enabled for current user
  /// Returns false if preference not set or user not authenticated
  static Future<bool> isAIEnabled() async {
    final preference = await getAIPreference();
    return preference ?? false;
  }
}
