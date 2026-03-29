import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopsync/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        title: Row(
          children: [
            Image(
              image: AssetImage('assets/logos/shopsync.png'),
              height: 32,
              width: 32,
            ),
            SizedBox(width: 8),
            Text(
              l10n.shopsync,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minHeight = constraints.maxHeight > 48
              ? constraints.maxHeight - 48
              : constraints.maxHeight;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  minHeight: minHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPredictive
                            ? Colors.amber.shade700
                            : Colors.orange.shade700,
                      ),
                      child: Icon(
                        isPredictive ? Icons.warning : Icons.build,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isPredictive
                          ? l10n.upcomingMaintenance
                          : l10n.underMaintenance,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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
                      _buildTimeDisplay(isDark, l10n),
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
                        label: Text(
                          l10n.understood,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeDisplay(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            isPredictive ? l10n.scheduledPeriod : l10n.expectedDuration,
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
            l10n.utcTimeZone,
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
