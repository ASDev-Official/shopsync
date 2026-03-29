import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class MaintenanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ValueNotifier<bool> isMaintenanceActive =
      ValueNotifier<bool>(false);

  /// Returns a Firebase-backed stream of the maintenance status document.
  /// This stream emits the document snapshot whenever the maintenance status changes.
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMaintenanceStream() {
    return _firestore.collection('maintenance').doc('status').snapshots();
  }

  /// Returns a stream of boolean values indicating if maintenance is active.
  /// Derived from the Firebase document stream.
  static Stream<bool> getMaintenanceActiveStream() {
    return getMaintenanceStream().map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        final isUnderMaintenance = data['isUnderMaintenance'] ?? false;
        final startTime = data['startTime']?.toDate();
        final isPredictive = !isUnderMaintenance && (startTime != null);
        return isUnderMaintenance || isPredictive;
      }
      return false;
    });
  }

  static Future<Map<String, dynamic>?> checkMaintenance() async {
    try {
      final doc =
          await _firestore.collection('maintenance').doc('status').get();

      if (doc.exists) {
        final data = doc.data()!;
        final isUnderMaintenance = data['isUnderMaintenance'] ?? false;
        final startTime = data['startTime']?.toDate();
        final isPredictive = !isUnderMaintenance && (startTime != null);

        // Set to true for both active and predictive maintenance
        isMaintenanceActive.value = isUnderMaintenance || isPredictive;

        return {
          'isUnderMaintenance': isUnderMaintenance,
          'message': data['message'] ?? '',
          'startTime': startTime,
          'endTime': data['endTime']?.toDate(),
          'isPredictive': isPredictive,
        };
      }
      isMaintenanceActive.value = false;
      return null;
    } catch (e, stackTrace) {
      isMaintenanceActive.value = false;
      if (kDebugMode) {
        print('Error fetching maintenance status: $e');
        print('Stack trace: $stackTrace');
      }

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

      SnackBar(
        content: Text('Error fetching maintenance status: $e'),
        backgroundColor: Colors.red,
      );
      return null;
    }
  }
}
