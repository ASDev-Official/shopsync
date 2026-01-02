import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopsync/services/analytics/analytics_service.dart';
import 'package:shopsync/l10n/app_localizations.dart';

import '../../widgets/ui/loading_spinner.dart';

class UserInsightsScreen extends StatefulWidget {
  const UserInsightsScreen({super.key});

  @override
  State<UserInsightsScreen> createState() => _UserInsightsScreenState();
}

class _UserInsightsScreenState extends State<UserInsightsScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.month;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Your Insights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Time frame selector
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildTimeFrameSelector(isDark),
            ),
            const SizedBox(height: 8),

            // Key insights cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<List<ShoppingInsight>>(
                future:
                    AnalyticsService.generateKeyInsights(_selectedTimeFrame),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CustomLoadingSpinner()),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildInsightCards(snapshot.data!, isDark);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Trends section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trends & Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCompletionTrendCard(isDark),
                  const SizedBox(height: 16),
                  _buildProductivityCard(isDark),
                  const SizedBox(height: 16),
                  _buildItemsPerDayChart(isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTopCategoriesCard(isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // List completion breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Completed Lists',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildListCompletionCard(isDark),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTimeFrameButton(TimeFrame.week, 'Week', isDark),
          const SizedBox(width: 8),
          _buildTimeFrameButton(TimeFrame.month, 'Month', isDark),
          const SizedBox(width: 8),
          _buildTimeFrameButton(TimeFrame.quarter, 'Quarter', isDark),
          const SizedBox(width: 8),
          _buildTimeFrameButton(TimeFrame.year, 'Year', isDark),
          const SizedBox(width: 8),
          _buildTimeFrameButton(TimeFrame.allTime, 'All Time', isDark),
        ],
      ),
    );
  }

  Widget _buildTimeFrameButton(TimeFrame timeFrame, String label, bool isDark) {
    final isSelected = _selectedTimeFrame == timeFrame;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTimeFrame = timeFrame;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.green[700] : Colors.green[600])
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.green[500]! : Colors.green[400]!)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCards(List<ShoppingInsight> insights, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        return _buildInsightCard(insight, isDark);
      },
    );
  }

  Widget _buildInsightCard(ShoppingInsight insight, bool isDark) {
    final Color iconColor = _getIconColor(insight.iconType);
    final Color bgColor = iconColor.withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconData(insight.iconType),
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionTrendCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Rate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<double>(
            future: AnalyticsService.getCompletionTrend(_selectedTimeFrame),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 100, child: Center(child: CustomLoadingSpinner()));
              }

              if (snapshot.hasError) {
                debugPrint('Error loading completion trend: ${snapshot.error}');
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load completion rate',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final value = snapshot.data ?? 0;
              return Column(
                children: [
                  Text(
                    '${value.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      minHeight: 8,
                      backgroundColor:
                          isDark ? Colors.grey[700] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[600]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'of items completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityCard(bool isDark) {
    return SizedBox(
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Productivity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<double>(
                future:
                    AnalyticsService.getProductivityTrend(_selectedTimeFrame),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingSpinner());
                  }

                  if (snapshot.hasError) {
                    debugPrint(
                        'Error loading productivity trend: ${snapshot.error}');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Failed to load productivity data',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton.icon(
                            onPressed: () => setState(() {}),
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Retry',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }
                  final value = snapshot.data ?? 0;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'items added per day',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsPerDayChart(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Over Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ChartData>>(
            future: AnalyticsService.getItemsPerDayTrend(_selectedTimeFrame),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    height: 200, child: Center(child: CustomLoadingSpinner()));
              }

              if (snapshot.hasError) {
                debugPrint('Error loading items per day: ${snapshot.error}');
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load activity data',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context)!.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                );
              }

              return _buildSimpleBarChart(data, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(List<ChartData> data, bool isDark) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }

    final maxValue = data.isEmpty
        ? 1
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final displayData = data.length > 7 ? data.sublist(data.length - 7) : data;

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: displayData.map((item) {
              final height = (item.value / (maxValue > 0 ? maxValue : 1)) * 120;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: '${item.value.toStringAsFixed(0)} items',
                    child: Container(
                      width: 20,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('M/d').format(item.date),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Items added each day',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTopCategoriesCard(bool isDark) {
    return FutureBuilder<List<CategoryInsight>>(
      future: AnalyticsService.getMostUsedCategories(_selectedTimeFrame),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: const Center(child: CustomLoadingSpinner()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error loading top categories: ${snapshot.error}');
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load category data',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            ),
          );
        }

        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[200],
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              final completionRate = category.itemCount == 0
                  ? 0.0
                  : (category.completedCount / category.itemCount) * 100;

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.categoryName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${category.itemCount} items',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${completionRate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRate / 100,
                        minHeight: 6,
                        backgroundColor:
                            isDark ? Colors.grey[700] : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange[500]!,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListCompletionCard(bool isDark) {
    return FutureBuilder<List<ListCompletionData>>(
      future: AnalyticsService.getTopListCompletions(_selectedTimeFrame),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: const Center(child: CustomLoadingSpinner()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error loading list completions: ${snapshot.error}');
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load list data',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            ),
          );
        }

        final lists = snapshot.data ?? [];
        if (lists.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lists.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[200],
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final list = lists[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.listName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : Colors.grey[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${list.completedItems}/${list.totalItems} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blue[900]!.withValues(alpha: 0.3)
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${list.completionPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.blue[300] : Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: list.completionPercentage / 100,
                        minHeight: 6,
                        backgroundColor:
                            isDark ? Colors.grey[700] : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue[600]!,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding items to see insights',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(IconValue iconType) {
    switch (iconType) {
      case IconValue.shoppingCart:
        return Colors.green[600]!;
      case IconValue.checkCircle:
        return Colors.blue[600]!;
      case IconValue.list:
        return Colors.orange[600]!;
      case IconValue.clock:
        return Colors.red[600]!;
      case IconValue.trend:
        return Colors.green[600]!;
      case IconValue.category:
        return Colors.cyan[600]!;
      case IconValue.users:
        return Colors.pink[600]!;
      case IconValue.star:
        return Colors.yellow[700]!;
    }
  }

  IconData _getIconData(IconValue iconType) {
    switch (iconType) {
      case IconValue.shoppingCart:
        return Icons.shopping_cart_outlined;
      case IconValue.checkCircle:
        return Icons.check_circle_outline;
      case IconValue.list:
        return Icons.list_outlined;
      case IconValue.clock:
        return Icons.schedule_outlined;
      case IconValue.trend:
        return Icons.trending_up;
      case IconValue.category:
        return Icons.category_outlined;
      case IconValue.users:
        return Icons.people_outline;
      case IconValue.star:
        return Icons.star_outline;
    }
  }
}
