class IncidentUpdate {
  final String body;
  final DateTime createdAt;
  final String
      status; // e.g., 'investigating', 'identified', 'monitoring', 'resolved'

  IncidentUpdate({
    required this.body,
    required this.createdAt,
    required this.status,
  });

  factory IncidentUpdate.fromJson(Map<String, dynamic> json) {
    return IncidentUpdate(
      body: json['body'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'unknown',
    );
  }
}

class StatusOutage {
  final bool active;
  final String shortStatus; // 'outage', 'fixed', 'none'
  final String name;
  final String description;
  final String impact; // 'minor', 'major', 'critical', 'none'
  final DateTime startedAt;
  final DateTime? resolvedAt;
  final List<IncidentUpdate> updates;
  final String? incidentId;
  final List<String> affectedComponents;

  StatusOutage({
    required this.active,
    required this.shortStatus,
    required this.name,
    required this.description,
    required this.impact,
    required this.startedAt,
    this.resolvedAt,
    required this.updates,
    this.incidentId,
    this.affectedComponents = const [],
  });

  factory StatusOutage.none() => StatusOutage(
        active: false,
        shortStatus: 'none',
        name: '',
        description: '',
        impact: 'none',
        startedAt: DateTime.fromMillisecondsSinceEpoch(0),
        updates: const [],
        affectedComponents: const [],
      );
}
