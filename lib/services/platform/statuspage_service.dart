import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../config/statuspage_config.dart';
import '../../models/status_outage.dart';

class StatuspageService {
  static final ValueNotifier<StatusOutage?> currentOutage =
      ValueNotifier<StatusOutage?>(null);
  static Timer? _pollTimer;
  static bool _dialogDismissedThisSession = false;

  static bool get dialogDismissedThisSession => _dialogDismissedThisSession;
  static void markDialogDismissed() {
    _dialogDismissedThisSession = true;
  }

  static void startPolling() {
    // Initial fetch immediately
    _fetchAndUpdate();
    // Poll every minute to avoid rate limits
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      StatuspageConfig.pollingInterval,
      (_) => _fetchAndUpdate(),
    );
  }

  static void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  static Future<void> _fetchAndUpdate() async {
    try {
      final outage = await fetchCurrentOutage();
      currentOutage.value = outage;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Statuspage fetch error: $e');
      }
      await Sentry.captureException(e,
          stackTrace: stack,
          hint: Hint.withMap({
            'action': 'statuspage_fetch',
            'endpoint': 'summary/unresolved',
          }));
    }
  }

  static Future<StatusOutage> fetchCurrentOutage() async {
    // We first check unresolved incidents; if any exist, we treat as active outage.
    final unresolvedUrl =
        Uri.parse('${StatuspageConfig.baseApiUrl}/incidents/unresolved.json');
    final summaryUrl = Uri.parse('${StatuspageConfig.baseApiUrl}/summary.json');

    try {
      final unresolvedResp = await http.get(unresolvedUrl);
      if (unresolvedResp.statusCode == 200) {
        final data = json.decode(unresolvedResp.body);
        final incidents = (data['incidents'] as List?) ?? [];
        if (incidents.isNotEmpty) {
          final inc = incidents.first as Map<String, dynamic>;
          final updates = ((inc['incident_updates'] as List?) ?? [])
              .map((u) => IncidentUpdate.fromJson(u as Map<String, dynamic>))
              .toList();
          final impact = inc['impact'] ?? 'minor';
          // Fetch summary to derive affected components list
          final comps = await _fetchAffectedComponents(summaryUrl);
          return StatusOutage(
            active: true,
            shortStatus: 'outage',
            name: inc['name'] ?? 'Service Outage',
            description: inc['shortlink'] != null
                ? 'An outage has been reported.'
                : (inc['postmortem_body'] ?? inc['shortlink'] ?? ''),
            impact: impact,
            startedAt: DateTime.parse(inc['created_at']),
            resolvedAt: inc['resolved_at'] != null
                ? DateTime.parse(inc['resolved_at'])
                : null,
            updates: updates,
            incidentId: inc['id'],
            affectedComponents: comps,
          );
        }
      }

      // If no unresolved incidents, use summary to infer status.
      final summaryResp = await http.get(summaryUrl);
      if (summaryResp.statusCode == 200) {
        final data = json.decode(summaryResp.body) as Map<String, dynamic>;
        final status = (data['status'] as Map<String, dynamic>?);
        final indicator = status?['indicator'] ?? 'none';
        final desc = status?['description'] ?? '';
        final comps = _extractAffectedComponentsFromSummary(data);
        // If indicator isn't none, treat as outage but may be partial.
        if (indicator != 'none') {
          return StatusOutage(
            active: true,
            shortStatus: 'outage',
            name: 'Service Degradation',
            description: desc,
            impact: indicator,
            startedAt: DateTime.now(),
            updates: const [],
            affectedComponents: comps,
          );
        }
        // Otherwise, no outage.
        return StatusOutage.none();
      }

      // Fallback: no data
      return StatusOutage.none();
    } catch (e, stack) {
      await Sentry.captureException(e,
          stackTrace: stack,
          hint: Hint.withMap({
            'action': 'statuspage_fetch_error',
          }));
      return StatusOutage.none();
    }
  }

  static Future<List<String>> _fetchAffectedComponents(Uri summaryUrl) async {
    try {
      final resp = await http.get(summaryUrl);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        return _extractAffectedComponentsFromSummary(data);
      }
    } catch (_) {}
    return const [];
  }

  static List<String> _extractAffectedComponentsFromSummary(
      Map<String, dynamic> summaryJson) {
    final comps = (summaryJson['components'] as List?) ?? [];
    final affected = <String>[];
    for (final c in comps) {
      final comp = c as Map<String, dynamic>;
      final status = (comp['status'] ?? 'operational') as String;
      if (status != 'operational') {
        final name = (comp['name'] ?? '') as String;
        if (name.isNotEmpty) affected.add(name);
      }
    }
    return affected;
  }
}
