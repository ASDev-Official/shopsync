import 'package:flutter/material.dart';
import 'package:shopsync/services/list_analytics_service.dart';
import 'package:intl/intl.dart';
import 'package:shopsync/widgets/loading_spinner.dart';

class ListInsightsScreen extends StatefulWidget {
  final String listId;
  final String listName;

  const ListInsightsScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ListInsightsScreen> createState() => _ListInsightsScreenState();
}

class _ListInsightsScreenState extends State<ListInsightsScreen> {
  ListTimeFrame _selectedTimeFrame = ListTimeFrame.week;
  bool _isLoading = true;

  List<ListInsightData> _keyInsights = [];
  List<CategoryBreakdown> _categoryBreakdown = [];
  List<ItemActivityData> _activityTimeline = [];
  List<CollaboratorActivity> _collaboratorActivity = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final insights = await ListAnalyticsService.generateListInsights(
          widget.listId, _selectedTimeFrame);
      final categories =
          await ListAnalyticsService.getCategoryBreakdown(widget.listId);
      final activity = await ListAnalyticsService.getActivityTimeline(
          widget.listId, _selectedTimeFrame);
      final collaborators = await ListAnalyticsService.getCollaboratorActivity(
          widget.listId, _selectedTimeFrame);

      setState(() {
        _keyInsights = insights;
        _categoryBreakdown = categories;
        _activityTimeline = activity;
        _collaboratorActivity = collaborators;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading insights: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[50],
      body: _isLoading
          ? const Center(child: CustomLoadingSpinner())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeFrameSelector(colorScheme),
                    const SizedBox(height: 24),
                    _buildKeyInsights(colorScheme),
                    const SizedBox(height: 24),
                    _buildActivityChart(colorScheme),
                    const SizedBox(height: 24),
                    _buildCategoryBreakdown(colorScheme),
                    const SizedBox(height: 24),
                    _buildCollaboratorActivity(colorScheme),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimeFrameSelector(ColorScheme colorScheme) {
    return Card(
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeFrameButton('Day', ListTimeFrame.day, colorScheme),
            _buildTimeFrameButton('Week', ListTimeFrame.week, colorScheme),
            _buildTimeFrameButton('Month', ListTimeFrame.month, colorScheme),
            _buildTimeFrameButton('All', ListTimeFrame.allTime, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameButton(
      String label, ListTimeFrame timeFrame, ColorScheme colorScheme) {
    final isSelected = _selectedTimeFrame == timeFrame;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton(
          onPressed: () {
            setState(() => _selectedTimeFrame = timeFrame);
            _loadData();
          },
          style: FilledButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.green[600] : colorScheme.surface,
            foregroundColor: isSelected
                ? Colors.white
                : colorScheme.onSurface.withValues(alpha: 0.8),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildKeyInsights(ColorScheme colorScheme) {
    if (_keyInsights.isEmpty) {
      return Card(
        color: colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No insights available yet',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _keyInsights.length,
      itemBuilder: (context, index) {
        final insight = _keyInsights[index];
        return Card(
          color: colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(insight.icon, color: insight.color, size: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insight.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityChart(ColorScheme colorScheme) {
    if (_activityTimeline.isEmpty) {
      return Card(
        color: colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No activity data for this timeframe',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    final maxValue = _activityTimeline.fold<int>(
      0,
      (max, data) {
        final dataMax = data.addedCount > data.completedCount
            ? data.addedCount
            : data.completedCount;
        return dataMax > max ? dataMax : max;
      },
    );

    return Card(
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Activity Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLegendItem(Colors.cyan[600]!, 'Added', colorScheme),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.teal[600]!, 'Completed', colorScheme),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _activityTimeline.length,
                itemBuilder: (context, index) {
                  final data = _activityTimeline[index];
                  return _buildBarGroup(data, maxValue, colorScheme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBarGroup(
      ItemActivityData data, int maxValue, ColorScheme colorScheme) {
    final dateLabel = DateFormat('MM/dd').format(data.date);
    final addedHeight =
        maxValue == 0 ? 0.0 : (data.addedCount / maxValue) * 150;
    final completedHeight =
        maxValue == 0 ? 0.0 : (data.completedCount / maxValue) * 150;

    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(addedHeight, Colors.cyan[600]!),
              _buildBar(completedHeight, Colors.teal[600]!),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 20,
      height: height < 1 ? 1 : height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ColorScheme colorScheme) {
    if (_categoryBreakdown.isEmpty) {
      return Card(
        color: colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No categories yet',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_outlined,
                    color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categoryBreakdown.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = _categoryBreakdown[index];
                final completionRate = category.itemCount == 0
                    ? 0.0
                    : category.completedCount / category.itemCount;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            category.categoryName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${category.completedCount}/${category.itemCount}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: colorScheme.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green[600]!,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorActivity(ColorScheme colorScheme) {
    if (_collaboratorActivity.isEmpty) {
      return Card(
        color: colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No collaborator activity in this timeframe',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Collaborator Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _collaboratorActivity.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final collaborator = _collaboratorActivity[index];
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[600],
                      child: Text(
                        collaborator.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collaborator.userName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${collaborator.itemsAdded} added • ${collaborator.itemsCompleted} completed',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
