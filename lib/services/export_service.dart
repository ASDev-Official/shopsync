import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'web_export.dart' if (dart.library.io) 'stub_export.dart';

class ExportService {
  static Future<void> exportList(String listId, String listName) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final items = await firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .get();

      String csvData =
          'Item,Counter,Status,Deadline,Store Location,Added By,Added Date\n';

      for (var doc in items.docs) {
        final item = doc.data();

        final addedAt = item['addedAt'] as Timestamp?;
        final addedDate = addedAt != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(addedAt.toDate())
            : 'N/A';

        final deadline = item['deadline'] as Timestamp?;
        final deadlineDate = deadline != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(deadline.toDate())
            : 'N/A';

        final isCompleted = item['completed'] as bool? ?? false;
        final name = item['name'] as String? ?? 'N/A';
        final addedByName = item['addedByName'] as String? ?? 'N/A';
        final counter = item['counter'] ?? 1;

        final location = item['location'] as Map<String, dynamic>?;
        final storeName = location?['name'] as String? ?? 'N/A';
        final storeAddress = location?['address'] as String? ?? '';
        final storeLocation =
            storeName != 'N/A' ? '$storeName/$storeAddress' : 'N/A';

        csvData += '$name,$counter,${isCompleted ? 'Completed' : 'Pending'},'
            '$deadlineDate,$addedByName,$addedDate,$storeLocation\n';
      }

      if (kIsWeb) {
        exportForWeb(csvData, listName);
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$listName.csv');
        await file.writeAsString(csvData);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Shopping List: $listName',
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error exporting list: $e');
        print('Stack trace: $stackTrace');
      }

      // Use withScope to add context data instead
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setContexts('export_info', {
            'listId': listId,
            'listName': listName,
          });
          scope.setTag('error_type', 'export_error');
        },
      );

      rethrow;
    }
  }
}
