import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class MaintenanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ValueNotifier<bool> isMaintenanceActive =
      ValueNotifier<bool>(false);

  static Future<Map<String, dynamic>?> checkMaintenance() async {
    try {
      final doc =
          await _firestore.collection('maintenance').doc('status').get();

      if (doc.exists) {
        final data = doc.data()!;
        final isUnderMaintenance = data['isUnderMaintenance'] ?? false;
        isMaintenanceActive.value = isUnderMaintenance;
        final startTime = data['startTime']?.toDate();
        final endTime = data['endTime']?.toDate();

        return {
          'isUnderMaintenance': isUnderMaintenance,
          'message': data['message'] ?? '',
          'startTime': startTime,
          'endTime': endTime,
          'isPredictive': !isUnderMaintenance && (startTime != null),
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
