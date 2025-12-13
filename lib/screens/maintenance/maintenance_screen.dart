import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceScreen extends StatelessWidget {
  final String message;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isPredictive;

  const MaintenanceScreen({
    super.key,
    required this.message,
    this.startTime,
    this.endTime,
    this.isPredictive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final cardColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        title: const Text(
          'ShopSync',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.orange.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.blueGrey.shade700
                        : Colors.orange.shade200,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isPredictive
                              ? [Colors.amber.shade700, Colors.amber.shade400]
                              : [
                                  Colors.orange.shade700,
                                  Colors.orange.shade400
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        isPredictive ? Icons.warning : Icons.build,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isPredictive
                              ? 'Upcoming Maintenance'
                              : 'Under Maintenance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    if (startTime != null && endTime != null) ...[
                      const SizedBox(height: 32),
                      _buildTimeDisplay(isDark),
                    ],
                    if (isPredictive) ...[
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.amber.shade700
                              : Colors.orange.shade600,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Understood',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.blueGrey.shade700 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            isPredictive ? 'Scheduled Period' : 'Expected Duration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildTimeCard(
                  _formatDate(startTime!),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard(
                  _formatDate(endTime!),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'UTC Time Zone',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(List<String> timeData, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.blueGrey.shade700 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Text(
            timeData[0],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeData[1],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _formatDate(DateTime dateTime) {
    return [
      DateFormat('MMM d, yyyy').format(dateTime),
      DateFormat('HH:mm').format(dateTime),
    ];
  }
}
