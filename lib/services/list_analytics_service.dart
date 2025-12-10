import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

enum ListTimeFrame { day, week, month, allTime }

class ListInsightData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  ListInsightData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class ItemActivityData {
  final DateTime date;
  final int addedCount;
  final int completedCount;

  ItemActivityData({
    required this.date,
    required this.addedCount,
    required this.completedCount,
  });
}

class CategoryBreakdown {
  final String categoryName;
  final int itemCount;
  final int completedCount;
  final double percentage;

  CategoryBreakdown({
    required this.categoryName,
    required this.itemCount,
    required this.completedCount,
  }) : percentage = itemCount == 0 ? 0 : (completedCount / itemCount) * 100;
}

class CollaboratorActivity {
  final String userId;
  final String userName;
  final int itemsAdded;
  final int itemsCompleted;

  CollaboratorActivity({
    required this.userId,
    required this.userName,
    required this.itemsAdded,
    required this.itemsCompleted,
  });
}

class ListAnalyticsService {
  static final _firestore = FirebaseFirestore.instance;

  /// Get date range based on timeframe
  static DateRange _getDateRange(ListTimeFrame timeFrame) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    switch (timeFrame) {
      case ListTimeFrame.day:
        return DateRange(startOfDay, now);
      case ListTimeFrame.week:
        final weekAgo = startOfDay.subtract(const Duration(days: 7));
        return DateRange(weekAgo, now);
      case ListTimeFrame.month:
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return DateRange(monthAgo, now);
      case ListTimeFrame.allTime:
        return DateRange(DateTime(2020), now);
    }
  }

  /// Get total items in list
  static Future<int> getTotalItems(String listId) async {
    try {
      final snapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getTotalItems', 'listId': listId}));
      return 0;
    }
  }

  /// Get completed items in list
  static Future<int> getCompletedItems(String listId) async {
    try {
      final snapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .where('completed', isEqualTo: true)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint:
              Hint.withMap({'action': 'getCompletedItems', 'listId': listId}));
      return 0;
    }
  }

  /// Get completion percentage
  static Future<double> getCompletionPercentage(String listId) async {
    try {
      final total = await getTotalItems(listId);
      final completed = await getCompletedItems(listId);

      if (total == 0) return 0;
      return (completed / total) * 100;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'getCompletionPercentage', 'listId': listId}));
      return 0;
    }
  }

  /// Get items added in timeframe
  static Future<int> getItemsAddedInTimeframe(
      String listId, ListTimeFrame timeFrame) async {
    try {
      final dateRange = _getDateRange(timeFrame);

      final snapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .where('addedAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('addedAt', isLessThanOrEqualTo: dateRange.end)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'getItemsAddedInTimeframe', 'listId': listId}));
      return 0;
    }
  }

  /// Get items completed in timeframe
  static Future<int> getItemsCompletedInTimeframe(
      String listId, ListTimeFrame timeFrame) async {
    try {
      final dateRange = _getDateRange(timeFrame);

      final snapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .where('completed', isEqualTo: true)
          .get();

      // Filter by timeframe in memory since we can't use multiple where clauses
      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
        if (completedAt != null &&
            completedAt.isAfter(dateRange.start) &&
            completedAt.isBefore(dateRange.end)) {
          count++;
        }
      }

      return count;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'getItemsCompletedInTimeframe', 'listId': listId}));
      return 0;
    }
  }

  /// Get category breakdown for list
  static Future<List<CategoryBreakdown>> getCategoryBreakdown(
      String listId) async {
    try {
      // Fetch categories first to get names
      final categoriesSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('categories')
          .get();

      final categoryNames = <String, String>{};
      for (final cat in categoriesSnapshot.docs) {
        categoryNames[cat.id] = cat['name'] as String? ?? cat.id;
      }

      final itemsSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .get();

      final categoryMap = <String, (int, int)>{};

      for (final item in itemsSnapshot.docs) {
        final categoryId = item['categoryId'] as String? ?? 'Uncategorized';
        final isCompleted = item['completed'] == true;

        if (categoryMap.containsKey(categoryId)) {
          final (total, completed) = categoryMap[categoryId]!;
          categoryMap[categoryId] =
              (total + 1, completed + (isCompleted ? 1 : 0));
        } else {
          categoryMap[categoryId] = (1, isCompleted ? 1 : 0);
        }
      }

      final breakdown = categoryMap.entries
          .map((e) => CategoryBreakdown(
              categoryName: categoryNames[e.key] ?? e.key,
              itemCount: e.value.$1,
              completedCount: e.value.$2))
          .toList()
        ..sort((a, b) => b.itemCount.compareTo(a.itemCount));

      return breakdown;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'getCategoryBreakdown', 'listId': listId}));
      return [];
    }
  }

  /// Get activity timeline
  static Future<List<ItemActivityData>> getActivityTimeline(
      String listId, ListTimeFrame timeFrame) async {
    try {
      final dateRange = _getDateRange(timeFrame);

      final itemsSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .where('addedAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('addedAt', isLessThanOrEqualTo: dateRange.end)
          .get();

      final dailyAddedMap = <DateTime, int>{};
      final dailyCompletedMap = <DateTime, int>{};

      for (final item in itemsSnapshot.docs) {
        final addedAt =
            (item['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateOnly = DateTime(addedAt.year, addedAt.month, addedAt.day);

        dailyAddedMap[dateOnly] = (dailyAddedMap[dateOnly] ?? 0) + 1;

        if (item['completed'] == true) {
          final completedAt =
              (item['completedAt'] as Timestamp?)?.toDate() ?? addedAt;
          final completedDateOnly =
              DateTime(completedAt.year, completedAt.month, completedAt.day);

          if (completedDateOnly
                  .isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
              completedDateOnly
                  .isBefore(dateRange.end.add(const Duration(days: 1)))) {
            dailyCompletedMap[completedDateOnly] =
                (dailyCompletedMap[completedDateOnly] ?? 0) + 1;
          }
        }
      }

      // Combine data
      final allDates = {...dailyAddedMap.keys, ...dailyCompletedMap.keys};
      final activityData = allDates
          .map((date) => ItemActivityData(
                date: date,
                addedCount: dailyAddedMap[date] ?? 0,
                completedCount: dailyCompletedMap[date] ?? 0,
              ))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return activityData;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'getActivityTimeline', 'listId': listId}));
      return [];
    }
  }

  /// Get collaborator activity
  static Future<List<CollaboratorActivity>> getCollaboratorActivity(
      String listId, ListTimeFrame timeFrame) async {
    try {
      final dateRange = _getDateRange(timeFrame);

      final itemsSnapshot = await _firestore
          .collection('lists')
          .doc(listId)
          .collection('items')
          .where('createdAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('createdAt', isLessThanOrEqualTo: dateRange.end)
          .get();

      final collaboratorMap = <String, (String, int, int)>{};

      for (final item in itemsSnapshot.docs) {
        final createdBy = item['createdBy'] as String? ?? 'Unknown';
        final createdByName = item['createdByName'] as String? ?? 'Unknown';
        final isCompleted = item['completed'] == true;

        if (collaboratorMap.containsKey(createdBy)) {
          final (name, added, completed) = collaboratorMap[createdBy]!;
          collaboratorMap[createdBy] =
              (name, added + 1, completed + (isCompleted ? 1 : 0));
        } else {
          collaboratorMap[createdBy] = (createdByName, 1, isCompleted ? 1 : 0);
        }
      }

      final activity = collaboratorMap.entries
          .map((e) => CollaboratorActivity(
                userId: e.key,
                userName: e.value.$1,
                itemsAdded: e.value.$2,
                itemsCompleted: e.value.$3,
              ))
          .toList()
        ..sort((a, b) => b.itemsAdded.compareTo(a.itemsAdded));

      return activity;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'getCollaboratorActivity', 'listId': listId}));
      return [];
    }
  }

  /// Get average items per day
  static Future<double> getAverageItemsPerDay(
      String listId, ListTimeFrame timeFrame) async {
    try {
      final dateRange = _getDateRange(timeFrame);
      final daysDiff = dateRange.end.difference(dateRange.start).inDays + 1;

      final itemsAdded = await getItemsAddedInTimeframe(listId, timeFrame);
      return itemsAdded / daysDiff;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'getAverageItemsPerDay', 'listId': listId}));
      return 0;
    }
  }

  /// Generate key insights for list
  static Future<List<ListInsightData>> generateListInsights(
      String listId, ListTimeFrame timeFrame) async {
    try {
      final totalItems = await getTotalItems(listId);
      final completedItems = await getCompletedItems(listId);
      final completionPercentage = await getCompletionPercentage(listId);
      final itemsAdded = await getItemsAddedInTimeframe(listId, timeFrame);
      final itemsCompleted =
          await getItemsCompletedInTimeframe(listId, timeFrame);
      final avgPerDay = await getAverageItemsPerDay(listId, timeFrame);

      return [
        ListInsightData(
          title: 'Total Items',
          value: totalItems.toString(),
          subtitle: 'items in list',
          icon: Icons.inventory_2_outlined,
          color: Colors.blue[600]!,
        ),
        ListInsightData(
          title: 'Completed',
          value: completedItems.toString(),
          subtitle: 'items checked off',
          icon: Icons.check_circle_outline,
          color: Colors.green[600]!,
        ),
        ListInsightData(
          title: 'Progress',
          value: '${completionPercentage.toStringAsFixed(1)}%',
          subtitle: 'completion rate',
          icon: Icons.trending_up,
          color: Colors.orange[600]!,
        ),
        ListInsightData(
          title: 'Added',
          value: itemsAdded.toString(),
          subtitle: 'in timeframe',
          icon: Icons.add_circle_outline,
          color: Colors.cyan[600]!,
        ),
        ListInsightData(
          title: 'Finished',
          value: itemsCompleted.toString(),
          subtitle: 'in timeframe',
          icon: Icons.done_all,
          color: Colors.teal[600]!,
        ),
        ListInsightData(
          title: 'Daily Avg',
          value: avgPerDay.toStringAsFixed(1),
          subtitle: 'items per day',
          icon: Icons.calendar_today,
          color: Colors.purple[600]!,
        ),
      ];
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap(
              {'action': 'generateListInsights', 'listId': listId}));
      return [];
    }
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);
}
