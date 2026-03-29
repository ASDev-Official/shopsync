import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/platform/statuspage_service.dart';
import '../../services/platform/maintenance_service.dart';
import '../../core/navigation_service.dart';
import '../../models/status_outage.dart';
import '../../l10n/app_localizations.dart';

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
  double _dragOffset = 0;
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _notifier = StatuspageService.currentOutage;
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
    _resetAnimation.removeListener(_onAnimationTick);
    _animationController.dispose();
    super.dispose();
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
      // Animate back to original position
      _resetAnimation = Tween<double>(begin: _dragOffset, end: 0)
          .animate(_animationController);
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
    return ValueListenableBuilder<bool>(
      valueListenable: MaintenanceService.isMaintenanceActive,
      builder: (context, isMaintenanceActive, _) {
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
                                        _buildOutageDialog(context, outage),
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
                                            outage.affectedComponents)),
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
                                  _labelForImpact(outage.impact),
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
                                  _labelForImpact(outage.impact),
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

  Widget _buildOutageDialog(BuildContext context, StatusOutage outage) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          child: Container(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: isDark ? Colors.grey[800] : Colors.green[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Image(
                        image: AssetImage('assets/logos/shopsync.png'),
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.shopsync,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade700,
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
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
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
}
