import 'package:flutter/material.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import '../../models/status_outage.dart';
import '../../services/platform/statuspage_service.dart';

class WearOutageScreen extends StatefulWidget {
  final StatusOutage outage;
  final bool isPredictive;

  const WearOutageScreen({
    super.key,
    required this.outage,
    this.isPredictive = false,
  });

  @override
  State<WearOutageScreen> createState() => _WearOutageScreenState();
}

class _WearOutageScreenState extends State<WearOutageScreen> {
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
              body: RotaryScrollbar(
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
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
                            'Service Outage',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: mode == WearMode.active
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: shape == WearShape.round ? 40.0 : 20.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.outage.name.isNotEmpty
                                  ? widget.outage.name
                                  : 'ShopSync Services',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: mode == WearMode.active
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.outage.description.isNotEmpty
                                  ? widget.outage.description
                                  : 'An outage has been reported. Our team is investigating.',
                              style: TextStyle(
                                fontSize: 11,
                                color: mode == WearMode.active
                                    ? Colors.white70
                                    : Colors.white60,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: shape == WearShape.round ? 32.0 : 12.0,
                        right: shape == WearShape.round ? 32.0 : 12.0,
                        bottom: 28.0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Card(
                          color: Colors.grey[900],
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 48,
                              minWidth: 48,
                            ),
                            child: InkWell(
                              onTap: () {
                                StatuspageService.markDialogDismissed();
                                Navigator.of(context).pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check,
                                        size: 18, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      'Close',
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
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 12.0),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
