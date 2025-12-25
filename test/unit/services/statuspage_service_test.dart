import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/models/status_outage.dart';

void main() {
  group('StatusOutage model', () {
    test('IncidentUpdate parses correctly', () {
      final json = {
        'body': 'Investigating the issue',
        'created_at': '2025-01-01T12:00:00Z',
        'status': 'investigating',
      };
      final update = IncidentUpdate.fromJson(json);
      expect(update.body, 'Investigating the issue');
      expect(update.status, 'investigating');
      expect(update.createdAt.toUtc().toIso8601String(),
          '2025-01-01T12:00:00.000Z');
    });

    test('StatusOutage.none has expected defaults', () {
      final o = StatusOutage.none();
      expect(o.active, false);
      expect(o.shortStatus, 'none');
      expect(o.updates, isEmpty);
    });
  });
}
