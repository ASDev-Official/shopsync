// ignore_for_file: invalid_runtime_check_with_js_interop_types

import 'dart:js_interop';
import 'package:web/web.dart';
import 'dart:convert';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

void exportForWeb(String csvData, String listName) {
  try {
    final bytes = utf8.encode(csvData);
    final blob =
        Blob([bytes] as JSArray<BlobPart>, BlobPropertyBag(type: 'text/csv'));
    final url = URL.createObjectURL(blob);

    // ignore: unused_local_variable
    final anchor = document.createElement('a') as HTMLAnchorElement
      ..href = url
      ..setAttribute('download', '$listName.csv')
      ..click();

    URL.revokeObjectURL(url);
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Error exporting list for web: $e');
      print('Stack trace: $stackTrace');
    }

    Sentry.captureException(
      e,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.setContexts('web_export', {
          'operation': 'exportForWeb',
          'listName': listName,
          'dataSize': csvData.length,
        });
        scope.setTag('error_type', 'web_export_error');
        scope.setTag('platform', 'web');
      },
    );
  }
}
