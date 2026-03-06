import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// Service for managing Gravatar profile pictures with privacy controls
class GravatarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate Gravatar URL from email address
  /// Uses MD5 hash of lowercase email as per Gravatar API spec
  ///
  /// Parameters:
  ///   - email: User's email address
  ///   - size: Image size in pixels (default: 200, max: 2048)
  ///   - defaultImage: Fallback if no Gravatar (identicon, mp, retro, robohash, wavatar, blank)
  static String generateGravatarUrl(String email,
      {int size = 200, String defaultImage = 'identicon'}) {
    final emailHash =
        md5.convert(utf8.encode(email.trim().toLowerCase())).toString();
    return 'https://www.gravatar.com/avatar/$emailHash?s=$size&d=$defaultImage';
  }

  /// Check if a Gravatar exists for the given email
  /// Returns true if Gravatar image exists, false otherwise
  static Future<bool> gravatarExists(String email) async {
    try {
      final url = generateGravatarUrl(email, defaultImage: '404');
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap(
              {'action': 'check_gravatar_exists', 'email': email}));
      if (kDebugMode) {
        print('Error checking if Gravatar exists: $e');
      }
      return false;
    }
  }

  /// Initialize Gravatar for a user (called on registration/sign-in)
  /// Checks if Gravatar exists and stores URL in Firestore
  static Future<void> initializeGravatar(String userId, String email) async {
    try {
      final exists = await gravatarExists(email);
      final gravatarUrl = exists ? generateGravatarUrl(email) : null;

      await _firestore.collection('users').doc(userId).update({
        'gravatarUrl': gravatarUrl,
        'gravatarEnabled': exists, // Auto-enable if Gravatar exists
        'gravatarLastChecked': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print(
            'Initialized Gravatar for $userId: ${exists ? "found" : "not found"}');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap(
              {'action': 'initialize_gravatar', 'userId': userId}));
      if (kDebugMode) {
        print('Error initializing Gravatar: $e');
      }
      // Don't rethrow - Gravatar initialization failure shouldn't block user flow
    }
  }

  /// Update Gravatar URL and check if it exists
  /// Call this when user updates their email or manually refreshes
  static Future<bool> refreshGravatar() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      final exists = await gravatarExists(user.email!);
      final gravatarUrl = exists ? generateGravatarUrl(user.email!) : null;

      await _firestore.collection('users').doc(user.uid).update({
        'gravatarUrl': gravatarUrl,
        'gravatarLastChecked': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Refreshed Gravatar: ${exists ? "found" : "not found"}');
      }

      return exists;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'refresh_gravatar'}));
      if (kDebugMode) {
        print('Error refreshing Gravatar: $e');
      }
      return false;
    }
  }

  /// Enable Gravatar display for current user
  static Future<void> enableGravatar() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'gravatarEnabled': true,
      });

      if (kDebugMode) {
        print('Gravatar enabled for ${user.uid}');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'enable_gravatar'}));
      if (kDebugMode) {
        print('Error enabling Gravatar: $e');
      }
      rethrow;
    }
  }

  /// Disable Gravatar display for current user (privacy control)
  static Future<void> disableGravatar() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'gravatarEnabled': false,
      });

      if (kDebugMode) {
        print('Gravatar disabled for ${user.uid}');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'disable_gravatar'}));
      if (kDebugMode) {
        print('Error disabling Gravatar: $e');
      }
      rethrow;
    }
  }

  /// Get Gravatar URL for a specific user
  /// Returns null if Gravatar is disabled or doesn't exist
  static Future<String?> getGravatarUrl(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      final data = userDoc.data();
      final gravatarEnabled = data?['gravatarEnabled'] ?? false;

      if (!gravatarEnabled) return null;

      return data?['gravatarUrl'] as String?;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'get_gravatar_url', 'userId': userId}));
      if (kDebugMode) {
        print('Error getting Gravatar URL: $e');
      }
      return null;
    }
  }

  /// Check if current user has Gravatar enabled
  static Future<bool> isGravatarEnabled() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final data = userDoc.data();
      return data?['gravatarEnabled'] ?? false;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'check_gravatar_enabled'}));
      if (kDebugMode) {
        print('Error checking if Gravatar enabled: $e');
      }
      return false;
    }
  }

  /// Check if current user has a Gravatar URL stored
  static Future<bool> hasGravatarUrl() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final data = userDoc.data();
      final gravatarUrl = data?['gravatarUrl'] as String?;
      return gravatarUrl != null && gravatarUrl.isNotEmpty;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'check_has_gravatar_url'}));
      if (kDebugMode) {
        print('Error checking if Gravatar URL exists: $e');
      }
      return false;
    }
  }

  /// Check if user has set their Gravatar preference (initial setup complete)
  static Future<bool> hasGravatarPreference() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final data = userDoc.data();
      return data?.containsKey('gravatarEnabled') ?? false;
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'check_gravatar_preference'}));
      if (kDebugMode) {
        print('Error checking Gravatar preference: $e');
      }
      return false;
    }
  }

  /// Set user's Gravatar preference during initial setup
  /// Also checks if Gravatar exists and stores URL
  static Future<void> setGravatarPreference(bool enabled) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return;

      // Check if Gravatar exists
      final exists = await gravatarExists(user.email!);
      final gravatarUrl = exists ? generateGravatarUrl(user.email!) : null;

      await _firestore.collection('users').doc(user.uid).update({
        'gravatarEnabled':
            enabled && exists, // Only enable if user wants it AND it exists
        'gravatarUrl': gravatarUrl,
        'gravatarLastChecked': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Set Gravatar preference: enabled=$enabled, exists=$exists');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap(
              {'action': 'set_gravatar_preference', 'enabled': enabled}));
      if (kDebugMode) {
        print('Error setting Gravatar preference: $e');
      }
      rethrow;
    }
  }

  /// Silently refresh Gravatar on app open (non-blocking)
  /// Called when user opens the app to keep Gravatar up-to-date
  static Future<void> refreshGravatarOnAppOpen() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return;

      // Check if user has set Gravatar preference
      final hasPreference = await hasGravatarPreference();
      if (!hasPreference) return; // Skip if user hasn't completed setup

      // Check if Gravatar exists
      final exists = await gravatarExists(user.email!);
      final gravatarUrl = exists ? generateGravatarUrl(user.email!) : null;

      await _firestore.collection('users').doc(user.uid).update({
        'gravatarUrl': gravatarUrl,
        'gravatarLastChecked': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print(
            'Auto-refreshed Gravatar on app open: ${exists ? "found" : "not found"}');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(e,
          stackTrace: stackTrace,
          hint: Hint.withMap({'action': 'refresh_gravatar_on_app_open'}));
      if (kDebugMode) {
        print('Error auto-refreshing Gravatar: $e');
      }
      // Don't rethrow - auto-refresh failure shouldn't block app
    }
  }
}
