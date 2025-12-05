import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'package:intl/intl.dart';

class WearMaintenanceScreen extends StatefulWidget {
  final String message;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isPredictive;

  const WearMaintenanceScreen({
    super.key,
    required this.message,
    this.startTime,
    this.endTime,
    this.isPredictive = false,
  });

  @override
  State<WearMaintenanceScreen> createState() => _WearMaintenanceScreenState();
}

class _WearMaintenanceScreenState extends State<WearMaintenanceScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Scaffold(
              backgroundColor:
                  mode == WearMode.active ? Colors.black : Colors.black,
              body: _buildMaintenanceContent(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildMaintenanceContent(WearMode mode, WearShape shape) {
    return RotaryScrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Centered, padded title header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 32.0 : 16.0,
                right: shape == WearShape.round ? 32.0 : 16.0,
                top: shape == WearShape.round ? 24.0 : 16.0,
                bottom: 12.0,
              ),
              child: Center(
                child: Text(
                  widget.isPredictive
                      ? 'Upcoming Maintenance'
                      : 'Under Maintenance',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color:
                        mode == WearMode.active ? Colors.white : Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Icon and Message Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: shape == WearShape.round ? 40.0 : 20.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  Icon(
                    widget.isPredictive ? Icons.warning_rounded : Icons.build,
                    size: 48,
                    color: widget.isPredictive
                        ? Colors.amber[400]
                        : Colors.orange[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mode == WearMode.active
                          ? Colors.white
                          : Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Time Display if available
          if (widget.startTime != null && widget.endTime != null) ...[
            SliverPadding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 32.0 : 12.0,
                right: shape == WearShape.round ? 32.0 : 12.0,
                bottom: 16.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Card(
                  color: mode == WearMode.active
                      ? Colors.grey[900]
                      : Colors.grey[850],
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text(
                          widget.isPredictive
                              ? 'Scheduled Period'
                              : 'Expected Duration',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mode == WearMode.active
                                ? Colors.white
                                : Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildTimeCard(
                                _formatDate(widget.startTime!),
                                mode,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: mode == WearMode.active
                                    ? Colors.white54
                                    : Colors.white38,
                              ),
                            ),
                            Expanded(
                              child: _buildTimeCard(
                                _formatDate(widget.endTime!),
                                mode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'UTC Time Zone',
                          style: TextStyle(
                            fontSize: 9,
                            color: mode == WearMode.active
                                ? Colors.white54
                                : Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Understood Button for predictive maintenance
          if (widget.isPredictive) ...[
            SliverPadding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 32.0 : 12.0,
                right: shape == WearShape.round ? 32.0 : 12.0,
                bottom: 36.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Card(
                  color: Colors.amber[900],
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: 48, minWidth: 48),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Understood',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Bottom padding for under maintenance state
            SliverToBoxAdapter(
              child: SizedBox(
                height: shape == WearShape.round ? 20.0 : 12.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCard(List<String> timeData, WearMode mode) {
    return Column(
      children: [
        Text(
          timeData[0],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: mode == WearMode.active ? Colors.white : Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          timeData[1],
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: mode == WearMode.active ? Colors.white54 : Colors.white38,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<String> _formatDate(DateTime dateTime) {
    return [
      DateFormat('MMM d, yyyy').format(dateTime),
      DateFormat('HH:mm').format(dateTime),
    ];
  }
}
