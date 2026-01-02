import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import '../../models/status_outage.dart';
import '../../services/platform/statuspage_service.dart';

class OutageDialog extends StatelessWidget {
  final StatusOutage outage;

  const OutageDialog({super.key, required this.outage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final cardColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.8);

    return Dialog.fullscreen(
      backgroundColor: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
          elevation: 0,
          title: const Text(
            'ShopSync',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                StatuspageService.markDialogDismissed();
                Navigator.of(context).pop();
              },
            ),
          ],
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
                            : Colors.red.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.red.shade700 : Colors.red.shade200,
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
                            colors: [
                              Colors.red.shade700,
                              Colors.red.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        outage.name.isNotEmpty
                            ? outage.name
                            : l10n.outageServiceOutage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        outage.description.isNotEmpty
                            ? outage.description
                            : l10n.outageDefaultDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      if (outage.affectedComponents.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.outageAffected(
                              _formatComponents(outage.affectedComponents)),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildTimes(isDark, l10n),
                      if (outage.updates.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildUpdates(isDark, l10n),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          StatuspageService.markDialogDismissed();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.red.shade700
                              : Colors.red.shade600,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle,
                            size: 18, color: Colors.white),
                        label: Text(l10n.outageClose,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimes(bool isDark, AppLocalizations l10n) {
    final started =
        DateFormat('MMM d, yyyy • HH:mm').format(outage.startedAt.toUtc());
    final resolved = outage.resolvedAt != null
        ? DateFormat('MMM d, yyyy • HH:mm').format(outage.resolvedAt!.toUtc())
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.red.shade700 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.outageStarted,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$started (UTC)',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          if (resolved != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.outageResolved,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$resolved (UTC)',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpdates(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.red.shade700 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.outageLatestUpdates,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final u in outage.updates.take(5)) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _iconForUpdate(u.status),
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM d, HH:mm').format(u.createdAt.toUtc()),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(u.body, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  IconData _iconForUpdate(String status) {
    switch (status) {
      case 'investigating':
        return Icons.search;
      case 'identified':
        return Icons.flag;
      case 'monitoring':
        return Icons.monitor_heart;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }

  String _formatComponents(List<String> comps) {
    if (comps.length <= 4) return comps.join(', ');
    final head = comps.take(4).join(', ');
    final more = comps.length - 4;
    return '$head +$more more';
  }
}
