/// Data model for item suggestions based on user behavior patterns
class ItemSuggestion {
  final String name;
  final String? iconIdentifier;
  final Map<String, dynamic>? location;
  final String? categoryId;
  final String? categoryName;
  final double confidence;
  final DateTime lastUsed;
  final int frequency;
  final List<int> commonDaysOfWeek; // 1=Monday, 7=Sunday
  final List<int> commonHoursOfDay;

  ItemSuggestion({
    required this.name,
    this.iconIdentifier,
    this.location,
    this.categoryId,
    this.categoryName,
    required this.confidence,
    required this.lastUsed,
    required this.frequency,
    required this.commonDaysOfWeek,
    required this.commonHoursOfDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconIdentifier': iconIdentifier,
      'location': location,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'confidence': confidence,
      'lastUsed': lastUsed.toIso8601String(),
      'frequency': frequency,
      'commonDaysOfWeek': commonDaysOfWeek,
      'commonHoursOfDay': commonHoursOfDay,
    };
  }

  factory ItemSuggestion.fromJson(Map<String, dynamic> json) {
    return ItemSuggestion(
      name: json['name'] as String,
      iconIdentifier: json['iconIdentifier'] as String?,
      location: json['location'] as Map<String, dynamic>?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      frequency: json['frequency'] as int,
      commonDaysOfWeek: (json['commonDaysOfWeek'] as List).cast<int>(),
      commonHoursOfDay: (json['commonHoursOfDay'] as List).cast<int>(),
    );
  }

  ItemSuggestion copyWith({
    String? name,
    String? iconIdentifier,
    Map<String, dynamic>? location,
    String? categoryId,
    String? categoryName,
    double? confidence,
    DateTime? lastUsed,
    int? frequency,
    List<int>? commonDaysOfWeek,
    List<int>? commonHoursOfDay,
  }) {
    return ItemSuggestion(
      name: name ?? this.name,
      iconIdentifier: iconIdentifier ?? this.iconIdentifier,
      location: location ?? this.location,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      confidence: confidence ?? this.confidence,
      lastUsed: lastUsed ?? this.lastUsed,
      frequency: frequency ?? this.frequency,
      commonDaysOfWeek: commonDaysOfWeek ?? this.commonDaysOfWeek,
      commonHoursOfDay: commonHoursOfDay ?? this.commonHoursOfDay,
    );
  }
}

/// Represents a single item learning data point
class ItemLearningData {
  final String name;
  final String? iconIdentifier;
  final Map<String, dynamic>? location;
  final String? categoryId;
  final String? categoryName;
  final DateTime addedAt;
  final DateTime? completedAt;
  final int dayOfWeek; // 1-7
  final int hourOfDay; // 0-23

  ItemLearningData({
    required this.name,
    this.iconIdentifier,
    this.location,
    this.categoryId,
    this.categoryName,
    required this.addedAt,
    this.completedAt,
    required this.dayOfWeek,
    required this.hourOfDay,
  });

  factory ItemLearningData.fromFirestore(Map<String, dynamic> data) {
    final addedAt = (data['addedAt'] as dynamic)?.toDate() ?? DateTime.now();
    final completedAt = data['completedAt'] != null
        ? (data['completedAt'] as dynamic).toDate()
        : null;

    return ItemLearningData(
      name: (data['name'] as String? ?? '').toLowerCase().trim(),
      iconIdentifier: data['iconIdentifier'] as String?,
      location: data['location'] as Map<String, dynamic>?,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      addedAt: addedAt,
      completedAt: completedAt,
      dayOfWeek: addedAt.weekday,
      hourOfDay: addedAt.hour,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconIdentifier': iconIdentifier,
      'location': location,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'addedAt': addedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'hourOfDay': hourOfDay,
    };
  }

  factory ItemLearningData.fromJson(Map<String, dynamic> json) {
    return ItemLearningData(
      name: json['name'] as String,
      iconIdentifier: json['iconIdentifier'] as String?,
      location: json['location'] as Map<String, dynamic>?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      addedAt: DateTime.parse(json['addedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      dayOfWeek: json['dayOfWeek'] as int,
      hourOfDay: json['hourOfDay'] as int,
    );
  }
}
