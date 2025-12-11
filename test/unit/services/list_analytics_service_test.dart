import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/services/list_analytics_service.dart';
import 'package:flutter/material.dart';

void main() {
  group('ListTimeFrame', () {
    test('has correct enum values', () {
      expect(ListTimeFrame.values.length, 4);
      expect(ListTimeFrame.values, contains(ListTimeFrame.day));
      expect(ListTimeFrame.values, contains(ListTimeFrame.week));
      expect(ListTimeFrame.values, contains(ListTimeFrame.month));
      expect(ListTimeFrame.values, contains(ListTimeFrame.allTime));
    });
  });

  group('ListInsightData', () {
    test('creates instance with all properties', () {
      final insight = ListInsightData(
        title: 'Test Title',
        value: '42',
        subtitle: 'Test Subtitle',
        icon: Icons.check,
        color: Colors.blue,
      );

      expect(insight.title, 'Test Title');
      expect(insight.value, '42');
      expect(insight.subtitle, 'Test Subtitle');
      expect(insight.icon, Icons.check);
      expect(insight.color, Colors.blue);
    });
  });

  group('ItemActivityData', () {
    test('creates instance with all properties', () {
      final date = DateTime(2024, 1, 15);
      final activity = ItemActivityData(
        date: date,
        addedCount: 10,
        completedCount: 5,
      );

      expect(activity.date, date);
      expect(activity.addedCount, 10);
      expect(activity.completedCount, 5);
    });
  });

  group('CategoryBreakdown', () {
    test('calculates percentage correctly with items', () {
      final breakdown = CategoryBreakdown(
        categoryName: 'Groceries',
        itemCount: 20,
        completedCount: 15,
      );

      expect(breakdown.categoryName, 'Groceries');
      expect(breakdown.itemCount, 20);
      expect(breakdown.completedCount, 15);
      expect(breakdown.percentage, 75.0); // 15/20 * 100 = 75.0
    });

    test('handles zero items correctly', () {
      final breakdown = CategoryBreakdown(
        categoryName: 'Empty',
        itemCount: 0,
        completedCount: 0,
      );

      expect(breakdown.percentage, 0);
    });

    test('calculates percentage for partially completed category', () {
      final breakdown = CategoryBreakdown(
        categoryName: 'Shopping',
        itemCount: 10,
        completedCount: 5,
      );

      expect(breakdown.percentage, 50.0); // 5/10 * 100 = 50.0
    });
  });

  group('CollaboratorActivity', () {
    test('creates instance with all properties', () {
      final activity = CollaboratorActivity(
        userId: 'user123',
        userName: 'John Doe',
        itemsAdded: 25,
        itemsCompleted: 20,
      );

      expect(activity.userId, 'user123');
      expect(activity.userName, 'John Doe');
      expect(activity.itemsAdded, 25);
      expect(activity.itemsCompleted, 20);
    });
  });

  group('DateRange', () {
    test('creates instance with start and end dates', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final range = DateRange(start, end);

      expect(range.start, start);
      expect(range.end, end);
    });

    test('allows same start and end date', () {
      final date = DateTime(2024, 1, 15);
      final range = DateRange(date, date);

      expect(range.start, date);
      expect(range.end, date);
    });
  });

  group('ListAnalyticsService data models integration', () {
    test('ItemActivityData can be used in a list', () {
      final activities = [
        ItemActivityData(
          date: DateTime(2024, 1, 1),
          addedCount: 5,
          completedCount: 3,
        ),
        ItemActivityData(
          date: DateTime(2024, 1, 2),
          addedCount: 8,
          completedCount: 6,
        ),
      ];

      expect(activities.length, 2);
      expect(activities[0].addedCount, 5);
      expect(activities[1].completedCount, 6);
    });

    test('CategoryBreakdown can be sorted', () {
      final breakdowns = [
        CategoryBreakdown(
          categoryName: 'A',
          itemCount: 5,
          completedCount: 3,
        ),
        CategoryBreakdown(
          categoryName: 'B',
          itemCount: 10,
          completedCount: 8,
        ),
        CategoryBreakdown(
          categoryName: 'C',
          itemCount: 3,
          completedCount: 2,
        ),
      ];

      breakdowns.sort((a, b) => b.itemCount.compareTo(a.itemCount));

      expect(breakdowns[0].categoryName, 'B');
      expect(breakdowns[1].categoryName, 'A');
      expect(breakdowns[2].categoryName, 'C');
    });

    test('CollaboratorActivity can be sorted by items added', () {
      final activities = [
        CollaboratorActivity(
          userId: '1',
          userName: 'Alice',
          itemsAdded: 10,
          itemsCompleted: 8,
        ),
        CollaboratorActivity(
          userId: '2',
          userName: 'Bob',
          itemsAdded: 20,
          itemsCompleted: 15,
        ),
        CollaboratorActivity(
          userId: '3',
          userName: 'Charlie',
          itemsAdded: 5,
          itemsCompleted: 4,
        ),
      ];

      activities.sort((a, b) => b.itemsAdded.compareTo(a.itemsAdded));

      expect(activities[0].userName, 'Bob');
      expect(activities[1].userName, 'Alice');
      expect(activities[2].userName, 'Charlie');
    });
  });
}
