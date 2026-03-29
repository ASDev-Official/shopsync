import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../../services/platform/statuspage_service.dart';
import '../../services/platform/maintenance_service.dart';
import '../../core/navigation_service.dart';
import '../../models/status_outage.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/status/outage_dialog.dart';

class OutageBanner extends StatefulWidget {
  const OutageBanner({super.key});

  @override
  State<OutageBanner> createState() => _OutageBannerState();
}

class _OutageBannerState extends State<OutageBanner>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<StatusOutage?> _notifier;
  Timer? _timer;
  bool _isDismissed = false;
  String? _lastOutageKey;
  double _dragOffset = 0;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _notifier = StatuspageService.currentOutage;
    _notifier.addListener(_handleOutageChange);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _resetAnimation =
        _animationController.drive(Tween<double>(begin: 0, end: 0));
    _resetAnimation.addListener(_onAnimationTick);
  }

  void _onAnimationTick() {
    if (mounted) {
      setState(() {
        _dragOffset = _resetAnimation.value;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notifier.removeListener(_handleOutageChange);
    _resetAnimation.removeListener(_onAnimationTick);
    _animationController.dispose();
    super.dispose();
  }

  String? _outageKey(StatusOutage? outage) {
    if (outage == null || !outage.active) {
      return null;
    }

    final incidentId = outage.incidentId;
    if (incidentId != null && incidentId.isNotEmpty) {
      return incidentId;
    }

    return '${outage.name}|${outage.startedAt.millisecondsSinceEpoch}|${outage.impact}';
  }

  void _handleOutageChange() {
    final key = _outageKey(_notifier.value);

    if (key == null) {
      if (_isDismissed ||
          _lastOutageKey != null ||
          _dragOffset != 0 ||
          _isDragging) {
        setState(() {
          _isDismissed = false;
          _lastOutageKey = null;
          _dragOffset = 0;
          _isDragging = false;
        });
      }
      return;
    }

    if (_lastOutageKey != key) {
      setState(() {
        _lastOutageKey = key;
        _isDismissed = false;
        _dragOffset = 0;
        _isDragging = false;
      });
    }
  }

  void _dismissBanner() {
    setState(() {
      _isDismissed = true;
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (_isLargeScreen(context)) return;
    setState(() {
      _isDragging = true;
      _dragOffset = 0;
    });
    _animationController.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isLargeScreen(context)) return;
    setState(() {
      // Only allow dragging upward (negative dy)
      _dragOffset = min(_dragOffset + details.delta.dy, 0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isLargeScreen(context)) return;
    final dragThreshold = -100.0;

    if (_dragOffset <= dragThreshold) {
      // Dismiss if dragged far enough
      _dismissBanner();
    } else {
      // Remove listener from old animation before reassigning
      _resetAnimation.removeListener(_onAnimationTick);

      // Animate back to original position
      _resetAnimation = Tween<double>(begin: _dragOffset, end: 0)
          .animate(_animationController);

      // Attach listener to new animation
      _resetAnimation.addListener(_onAnimationTick);

      _animationController.reset();
      _animationController.forward();
    }

    setState(() {
      _isDragging = false;
    });
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: MaintenanceService.getMaintenanceActiveStream(),
      initialData: false,
      builder: (context, snapshot) {
        // Handle stream states
        final isMaintenanceActive = snapshot.data ?? false;

        if (snapshot.hasError) {
          // On error, default to not showing maintenance banner
          if (kDebugMode) {
            print('Error in maintenance stream: ${snapshot.error}');
          }
        }

        if (isMaintenanceActive) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<StatusOutage?>(
          valueListenable: _notifier,
          builder: (context, outage, _) {
            if (outage == null || !outage.active || _isDismissed) {
              return const SizedBox.shrink();
            }
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isLarge = _isLargeScreen(context);
            final l10n = AppLocalizations.of(context)!;

            return SafeArea(
              bottom: false,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onVerticalDragStart: isLarge ? null : _onVerticalDragStart,
                  onVerticalDragUpdate: isLarge ? null : _onVerticalDragUpdate,
                  onVerticalDragEnd: isLarge ? null : _onVerticalDragEnd,
                  child: Transform.translate(
                    offset: Offset(0, _dragOffset),
                    child: Opacity(
                      opacity: 1 - (_dragOffset.abs() / 150).clamp(0, 0.3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _isDragging
                            ? null
                            : () {
                                if (MaintenanceService
                                    .isMaintenanceActive.value) {
                                  return;
                                }

                                final ctx =
                                    AppNavigation.navigatorKey.currentContext;
                                if (ctx != null) {
                                  showDialog(
                                    context: ctx,
                                    barrierDismissible: true,
                                    builder: (context) =>
                                        OutageDialog(outage: outage),
                                  );
                                }
                              },
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.red.shade900
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.red.shade700
                                  : Colors.red.shade300,
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
                                          : l10n.outageServiceOutage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.red.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      outage.description.isNotEmpty
                                          ? outage.description
                                          : l10n.outageDefaultDescription,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                    if (outage
                                        .affectedComponents.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.outageAffected(_formatComponents(
                                            outage.affectedComponents, l10n)),
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
                              if (!isLarge) ...[
                                Text(
                                  _labelForImpact(outage.impact, l10n),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.red.shade800,
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(width: 8),
                                Text(
                                  _labelForImpact(outage.impact, l10n),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.red.shade800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _dismissBanner,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _labelForImpact(String impact, AppLocalizations l10n) {
    switch (impact) {
      case 'critical':
        return l10n.outageImpactCritical;
      case 'major':
        return l10n.outageImpactMajor;
      case 'minor':
        return l10n.outageImpactMinor;
      default:
        return l10n.outageImpactDefault;
    }
  }

  String _formatComponents(List<String> comps, AppLocalizations l10n) {
    if (comps.length <= 3) return comps.join(', ');
    final head = comps.take(3).join(', ');
    final more = comps.length - 3;
    return '$head +$more ${l10n.outageMoreComponents}';
  }
}