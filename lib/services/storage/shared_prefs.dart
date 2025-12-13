// lib/services/shared_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class SharedPrefs {
  static const String _firstLaunchKey = 'is_first_launch';

  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_firstLaunchKey) ?? true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error checking first launch status: $e');
        print('Stack trace: $stackTrace');
      }

      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setContexts('preferences', {
            'operation': 'isFirstLaunch',
            'key': _firstLaunchKey,
          });
          scope.setTag('error_type', 'shared_prefs_error');
        },
      );

      // Return true as default if there's an error
      return true;
    }
  }

  static Future<void> setFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstLaunchKey, false);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error setting first launch flag: $e');
        print('Stack trace: $stackTrace');
      }

      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setContexts('preferences', {
            'operation': 'setFirstLaunch',
            'key': _firstLaunchKey,
            'value': false,
          });
          scope.setTag('error_type', 'shared_prefs_error');
        },
      );
    }
  }
}
