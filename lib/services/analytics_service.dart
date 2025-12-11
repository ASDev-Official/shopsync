import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

enum TimeFrame { week, month, quarter, year, allTime }

class ShoppingInsight {
  final String title;
  final String value;
  final String subtitle;
  final IconValue iconType;
  final Color? color;

  ShoppingInsight({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconType,
    this.color,
  });
}

enum IconValue {
  shoppingCart,
  checkCircle,
  list,
  clock,
  trend,
  category,
  users,
  star,
}

class ListCompletionData {
  final String listName;
  final int totalItems;
  final int completedItems;
  final double completionPercentage;
  final DateTime createdAt;

  ListCompletionData({
    required this.listName,
    required this.totalItems,
    required this.completedItems,
    required this.createdAt,
  }) : completionPercentage =
            totalItems == 0 ? 0 : (completedItems / totalItems) * 100;
}

class CategoryInsight {
  final String categoryName;
  final int itemCount;
  final int completedCount;

  CategoryInsight({
    required this.categoryName,
    required this.itemCount,
    required this.completedCount,
  });
}

class AnalyticsService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  /// Get the date range based on timeframe
  static DateRange _getDateRange(TimeFrame timeFrame) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    switch (timeFrame) {
      case TimeFrame.week:
        final weekAgo = startOfDay.subtract(const Duration(days: 7));
        return DateRange(weekAgo, now);
      case TimeFrame.month:
        final monthAgo = DateTime(now.year, now.month - 1, 1);
        final adjustedMonthAgo = DateTime(
          monthAgo.year,
          monthAgo.month,
          now.day.clamp(1, DateTime(monthAgo.year, monthAgo.month + 1, 0).day),
        );
        return DateRange(adjustedMonthAgo, now);
      case TimeFrame.quarter:
        final quarterAgo = DateTime(now.year, now.month - 3, now.day);
        return DateRange(quarterAgo, now);
      case TimeFrame.year:
        final yearAgo = DateTime(now.year - 1, now.month, now.day);
        return DateRange(yearAgo, now);
      case TimeFrame.allTime:
        return DateRange(DateTime(2020), now);
    }
  }

  /// Get total shopping lists created in timeframe
  static Future<int> getTotalListsCreated(TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final dateRange = _getDateRange(timeFrame);
      final query = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('createdAt', isLessThanOrEqualTo: dateRange.end)
          .count()
          .get();

      return query.count ?? 0;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getTotalListsCreated'}));
      return 0;
    }
  }

  /// Get total items added across all lists in timeframe
  static Future<int> getTotalItemsAdded(TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final dateRange = _getDateRange(timeFrame);

      // Get all lists for the user
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .get();

      int totalItems = 0;

      // Count items in each list
      for (final listDoc in listsSnapshot.docs) {
        final itemsSnapshot = await _firestore
            .collection('lists')
            .doc(listDoc.id)
            .collection('items')
            .where('addedAt', isGreaterThanOrEqualTo: dateRange.start)
            .where('addedAt', isLessThanOrEqualTo: dateRange.end)
            .count()
            .get();

        totalItems += itemsSnapshot.count ?? 0;
      }

      return totalItems;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st, hint: Hint.withMap({'action': 'getTotalItemsAdded'}));
      return 0;
    }
  }

  /// Get total items completed in timeframe
  static Future<int> getTotalItemsCompleted(TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final dateRange = _getDateRange(timeFrame);

      // Get all lists for the user
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .get();

      int totalCompleted = 0;

      // Count completed items in each list
      // Note: Items don't have completedAt field, so we count all completed items
      // and filter by addedAt as a proxy (items added in timeframe that are now completed)
      for (final listDoc in listsSnapshot.docs) {
        final itemsSnapshot = await _firestore
            .collection('lists')
            .doc(listDoc.id)
            .collection('items')
            .where('completed', isEqualTo: true)
            .where('addedAt', isGreaterThanOrEqualTo: dateRange.start)
            .where('addedAt', isLessThanOrEqualTo: dateRange.end)
            .count()
            .get();

        totalCompleted += itemsSnapshot.count ?? 0;
      }

      return totalCompleted;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getTotalItemsCompleted'}));
      return 0;
    }
  }

  /// Get average completion percentage
  static Future<double> getAverageCompletionPercentage(
      TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final dateRange = _getDateRange(timeFrame);

      // Get all lists for the user
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('createdAt', isLessThanOrEqualTo: dateRange.end)
          .get();

      if (listsSnapshot.docs.isEmpty) return 0;

      double totalPercentage = 0;

      // Calculate completion percentage for each list
      for (final listDoc in listsSnapshot.docs) {
        final itemsSnapshot = await _firestore
            .collection('lists')
            .doc(listDoc.id)
            .collection('items')
            .get();

        if (itemsSnapshot.docs.isEmpty) continue;

        int completedCount = 0;
        for (final item in itemsSnapshot.docs) {
          if (item['completed'] == true) {
            completedCount++;
          }
        }

        totalPercentage += (completedCount / itemsSnapshot.docs.length) * 100;
      }

      return listsSnapshot.docs.isEmpty
          ? 0
          : totalPercentage / listsSnapshot.docs.length;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getAverageCompletionPercentage'}));
      return 0;
    }
  }

  /// Get most used categories
  static Future<List<CategoryInsight>> getMostUsedCategories(
      TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final dateRange = _getDateRange(timeFrame);

      // Get all lists for the user
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .get();

      final categoryMap = <String, (int, int)>{};

      // Count items by category
      for (final listDoc in listsSnapshot.docs) {
        final itemsSnapshot = await _firestore
            .collection('lists')
            .doc(listDoc.id)
            .collection('items')
            .where('addedAt', isGreaterThanOrEqualTo: dateRange.start)
            .where('addedAt', isLessThanOrEqualTo: dateRange.end)
            .get();

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
      }

      // Convert to list and sort by item count
      final insights = categoryMap.entries
          .map((e) => CategoryInsight(
              categoryName: e.key,
              itemCount: e.value.$1,
              completedCount: e.value.$2))
          .toList()
        ..sort((a, b) => b.itemCount.compareTo(a.itemCount));

      return insights.take(5).toList();
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getMostUsedCategories'}));
      return [];
    }
  }

  /// Get list completion data for top lists
  static Future<List<ListCompletionData>> getTopListCompletions(
      TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final dateRange = _getDateRange(timeFrame);

      // Get all lists for the user
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('createdAt', isLessThanOrEqualTo: dateRange.end)
          .get();

      final completionData = <ListCompletionData>[];

      // Get completion data for each list
      for (final listDoc in listsSnapshot.docs) {
        final listName = listDoc['name'] as String? ?? 'Unnamed List';
        final createdAt =
            (listDoc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        final itemsSnapshot = await _firestore
            .collection('lists')
            .doc(listDoc.id)
            .collection('items')
            .get();

        if (itemsSnapshot.docs.isEmpty) continue;

        int completedCount = 0;
        for (final item in itemsSnapshot.docs) {
          if (item['completed'] == true) {
            completedCount++;
          }
        }

        completionData.add(ListCompletionData(
          listName: listName,
          totalItems: itemsSnapshot.docs.length,
          completedItems: completedCount,
          createdAt: createdAt,
        ));
      }

      // Sort by completion percentage
      completionData.sort(
          (a, b) => b.completionPercentage.compareTo(a.completionPercentage));

      return completionData.take(10).toList();
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getTopListCompletions'}));
      return [];
    }
  }

  /// Get number of collaborators
  static Future<int> getCollaboratorCount(TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final dateRange = _getDateRange(timeFrame);

      // Get all lists for the user
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('createdAt', isLessThanOrEqualTo: dateRange.end)
          .get();

      final collaboratorIds = <String>{};

      // Collect unique collaborator IDs
      for (final listDoc in listsSnapshot.docs) {
        final members = List<String>.from(listDoc['members'] as List? ?? []);
        collaboratorIds.addAll(members);
      }

      // Exclude current user
      collaboratorIds.remove(user.uid);

      return collaboratorIds.length;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getCollaboratorCount'}));
      return 0;
    }
  }

  /// Get shopping productivity trend (items per day average)
  static Future<double> getProductivityTrend(TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final dateRange = _getDateRange(timeFrame);
      final daysDiff = dateRange.end.difference(dateRange.start).inDays + 1;

      final totalItems = await getTotalItemsAdded(timeFrame);
      return totalItems / daysDiff;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getProductivityTrend'}));
      return 0;
    }
  }

  /// Get completion rate trend
  static Future<double> getCompletionTrend(TimeFrame timeFrame) async {
    try {
      final totalAdded = await getTotalItemsAdded(timeFrame);
      final totalCompleted = await getTotalItemsCompleted(timeFrame);

      if (totalAdded == 0) return 0;
      return (totalCompleted / totalAdded) * 100;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st, hint: Hint.withMap({'action': 'getCompletionTrend'}));
      return 0;
    }
  }

  /// Get items added per day for trend chart
  static Future<List<ChartData>> getItemsPerDayTrend(
      TimeFrame timeFrame) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final dateRange = _getDateRange(timeFrame);

      // Get all lists for the user
      final listsSnapshot = await _firestore
          .collection('lists')
          .where('members', arrayContains: user.uid)
          .get();

      final dailyItemsMap = <DateTime, int>{};

      // Count items per day
      for (final listDoc in listsSnapshot.docs) {
        final itemsSnapshot = await _firestore
            .collection('lists')
            .doc(listDoc.id)
            .collection('items')
            .where('addedAt', isGreaterThanOrEqualTo: dateRange.start)
            .where('addedAt', isLessThanOrEqualTo: dateRange.end)
            .get();

        for (final item in itemsSnapshot.docs) {
          final addedAt =
              (item['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final dateOnly = DateTime(addedAt.year, addedAt.month, addedAt.day);

          dailyItemsMap[dateOnly] = (dailyItemsMap[dateOnly] ?? 0) + 1;
        }
      }

      // Convert to chart data and sort by date
      final chartData = dailyItemsMap.entries
          .map((e) => ChartData(date: e.key, value: e.value.toDouble()))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      return chartData;
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'getItemsPerDayTrend'}));
      return [];
    }
  }

  /// Generate key insights
  static Future<List<ShoppingInsight>> generateKeyInsights(
      TimeFrame timeFrame) async {
    try {
      final totalLists = await getTotalListsCreated(timeFrame);
      final totalItems = await getTotalItemsAdded(timeFrame);
      final totalCompleted = await getTotalItemsCompleted(timeFrame);
      final avgCompletion = await getAverageCompletionPercentage(timeFrame);
      final collaborators = await getCollaboratorCount(timeFrame);
      final productivity = await getProductivityTrend(timeFrame);

      return [
        ShoppingInsight(
          title: 'Lists Created',
          value: totalLists.toString(),
          subtitle: 'shopping lists',
          iconType: IconValue.list,
        ),
        ShoppingInsight(
          title: 'Items Added',
          value: totalItems.toString(),
          subtitle: 'total items',
          iconType: IconValue.shoppingCart,
        ),
        ShoppingInsight(
          title: 'Items Completed',
          value: totalCompleted.toString(),
          subtitle: 'items checked off',
          iconType: IconValue.checkCircle,
        ),
        ShoppingInsight(
          title: 'Avg Completion',
          value: '${avgCompletion.toStringAsFixed(1)}%',
          subtitle: 'completion rate',
          iconType: IconValue.trend,
        ),
        ShoppingInsight(
          title: 'Collaborators',
          value: collaborators.toString(),
          subtitle: 'people collaborating',
          iconType: IconValue.users,
        ),
        ShoppingInsight(
          title: 'Productivity',
          value: productivity.toStringAsFixed(1),
          subtitle: 'items per day',
          iconType: IconValue.clock,
        ),
      ];
    } catch (e, st) {
      await Sentry.captureException(e,
          stackTrace: st,
          hint: Hint.withMap({'action': 'generateKeyInsights'}));
      return [];
    }
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);
}

class ChartData {
  final DateTime date;
  final double value;

  ChartData({required this.date, required this.value});
}
