import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/platform/statuspage_service.dart';
import '../../core/navigation_service.dart';
import '../../models/status_outage.dart';
import '../../screens/status/outage_dialog.dart';

class OutageBanner extends StatefulWidget {
  const OutageBanner({super.key});

  @override
  State<OutageBanner> createState() => _OutageBannerState();
}

class _OutageBannerState extends State<OutageBanner> {
  late final ValueNotifier<StatusOutage?> _notifier;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _notifier = StatuspageService.currentOutage;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StatusOutage?>(
      valueListenable: _notifier,
      builder: (context, outage, _) {
        if (outage == null || !outage.active) {
          return const SizedBox.shrink();
        }
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          bottom: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                final ctx = AppNavigation.navigatorKey.currentContext;
                if (ctx != null) {
                  showDialog(
                    context: ctx,
                    barrierDismissible: true,
                    builder: (context) => OutageDialog(outage: outage),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.red.shade900 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.red.shade700 : Colors.red.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.4)
                          : Colors.red.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            outage.name.isNotEmpty
                                ? outage.name
                                : 'Service Outage',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            outage.description.isNotEmpty
                                ? outage.description
                                : 'We\'re investigating ongoing issues.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.white70 : Colors.red.shade700,
                            ),
                          ),
                          if (outage.affectedComponents.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Affected: ${_formatComponents(outage.affectedComponents)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      _labelForImpact(outage.impact),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _labelForImpact(String impact) {
    switch (impact) {
      case 'critical':
        return 'Critical';
      case 'major':
        return 'Major';
      case 'minor':
        return 'Minor';
      default:
        return 'Outage';
    }
  }

  String _formatComponents(List<String> comps) {
    if (comps.length <= 3) return comps.join(', ');
    final head = comps.take(3).join(', ');
    final more = comps.length - 3;
    return '$head +$more more';
  }
}
