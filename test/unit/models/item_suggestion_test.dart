import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/models/item_suggestion.dart';

void main() {
  group('ItemSuggestion', () {
    test('creates ItemSuggestion with correct values', () {
      final now = DateTime.now();
      final suggestion = ItemSuggestion(
        name: 'Milk',
        frequency: 5,
        lastUsed: now,
        confidence: 0.85,
        commonDaysOfWeek: [1, 3, 5],
        commonHoursOfDay: [9, 14, 19],
      );

      expect(suggestion.name, 'Milk');
      expect(suggestion.frequency, 5);
      expect(suggestion.lastUsed, now);
      expect(suggestion.confidence, 0.85);
      expect(suggestion.commonDaysOfWeek, [1, 3, 5]);
      expect(suggestion.commonHoursOfDay, [9, 14, 19]);
    });

    test('ItemSuggestion toJson serialization works', () {
      final now = DateTime.now();
      final suggestion = ItemSuggestion(
        name: 'Milk',
        iconIdentifier: 'icon:milk',
        frequency: 5,
        lastUsed: now,
        confidence: 0.85,
        commonDaysOfWeek: [1, 3, 5],
        commonHoursOfDay: [9, 14, 19],
        categoryId: 'cat-123',
        categoryName: 'Dairy',
      );

      final json = suggestion.toJson();

      expect(json['name'], 'Milk');
      expect(json['frequency'], 5);
      expect(json['confidence'], 0.85);
      expect(json['iconIdentifier'], 'icon:milk');
      expect(json['categoryId'], 'cat-123');
      expect(json['categoryName'], 'Dairy');
      expect(json['commonDaysOfWeek'], [1, 3, 5]);
      expect(json['commonHoursOfDay'], [9, 14, 19]);
    });

    test('ItemSuggestion fromJson deserialization works', () {
      final now = DateTime.now();
      final json = {
        'name': 'Milk',
        'iconIdentifier': 'icon:milk',
        'frequency': 5,
        'lastUsed': now.toIso8601String(),
        'confidence': 0.85,
        'categoryId': 'cat-123',
        'categoryName': 'Dairy',
        'commonDaysOfWeek': [1, 3, 5],
        'commonHoursOfDay': [9, 14, 19],
      };

      final suggestion = ItemSuggestion.fromJson(json);

      expect(suggestion.name, 'Milk');
      expect(suggestion.frequency, 5);
      expect(suggestion.confidence, 0.85);
      expect(suggestion.categoryId, 'cat-123');
      expect(suggestion.categoryName, 'Dairy');
    });

    test('ItemSuggestion roundtrip serialization works', () {
      final now = DateTime.now();
      final original = ItemSuggestion(
        name: 'Bread',
        frequency: 10,
        lastUsed: now,
        confidence: 0.75,
        commonDaysOfWeek: [2, 4, 6],
        commonHoursOfDay: [8, 15],
        categoryId: 'cat-456',
      );

      final json = original.toJson();
      final restored = ItemSuggestion.fromJson(json);

      expect(restored.name, original.name);
      expect(restored.frequency, original.frequency);
      expect(restored.confidence, original.confidence);
      expect(restored.categoryId, original.categoryId);
    });
  });
}
