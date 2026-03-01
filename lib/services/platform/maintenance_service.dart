import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class MaintenanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>?> checkMaintenance() async {
    const maxRetries = 3;
    const transientErrorCode = 'unavailable';

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final doc =
            await _firestore.collection('maintenance').doc('status').get();

        if (doc.exists) {
          final data = doc.data()!;
          final startTime = data['startTime']?.toDate();
          final endTime = data['endTime']?.toDate();

          return {
            'isUnderMaintenance': data['isUnderMaintenance'] ?? false,
            'message': data['message'] ?? '',
            'startTime': startTime,
            'endTime': endTime,
            'isPredictive': !data['isUnderMaintenance'] && (startTime != null),
          };
        }
        return null;
      } catch (e, stackTrace) {
        final isTransient =
            e is FirebaseException && e.code == transientErrorCode;

        if (isTransient && attempt < maxRetries - 1) {
          // Transient error — wait with exponential backoff and retry.
          final backoffDuration =
              Duration(milliseconds: 500 * (1 << attempt)); // 500ms, 1s, 2s
          if (kDebugMode) {
            print(
              'Transient Firestore error on attempt ${attempt + 1}/$maxRetries. '
              'Retrying in ${backoffDuration.inMilliseconds}ms...',
            );
          }
          await Future.delayed(backoffDuration);
          continue;
        }

        if (kDebugMode) {
          print('Error fetching maintenance status: $e');
          print('Stack trace: $stackTrace');
        }

        if (isTransient) {
          // Transient error that persisted through all retries — add a
          // breadcrumb rather than a full Sentry event to avoid noise.
          await Sentry.addBreadcrumb(
            Breadcrumb(
              message:
                  'Transient Firestore unavailable error in checkMaintenance '
                  'after $maxRetries attempts: $e',
              category: 'maintenance_check',
              level: SentryLevel.warning,
            ),
          );
        } else {
          // Non-transient / unexpected error — report to Sentry as usual.
          await Sentry.captureException(
            e,
            stackTrace: stackTrace,
            withScope: (scope) {
              scope.setContexts('maintenance_check', {
                'operation': 'checkMaintenance',
              });
              scope.setTag('error_type', 'maintenance_status_error');
            },
          );
        }

        SnackBar(
          content: Text('Error fetching maintenance status: $e'),
          backgroundColor: Colors.red,
        );
        return null;
      }
    }

    // Unreachable, but satisfies the Dart type system.
    return null;
  }
}
