import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';

class WearSignOutScreen extends StatefulWidget {
  const WearSignOutScreen({super.key});

  @override
  State<WearSignOutScreen> createState() => _WearSignOutScreenState();
}

class _WearSignOutScreenState extends State<WearSignOutScreen> {
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
              body: _buildSignOutConfirmation(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildSignOutConfirmation(WearMode mode, WearShape shape) {
    return RotaryScrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Centered, padded title header (no back button)
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
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color:
                        mode == WearMode.active ? Colors.white : Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Warning Icon and Message
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: shape == WearShape.round ? 40.0 : 20.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.exit_to_app,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sign out of ShopSync?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: mode == WearMode.active
                          ? Colors.white
                          : Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll need to sign in again',
                    style: TextStyle(
                      fontSize: 11,
                      color: mode == WearMode.active
                          ? Colors.white54
                          : Colors.white38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          SliverPadding(
            padding: EdgeInsets.only(
              left: shape == WearShape.round ? 32.0 : 12.0,
              right: shape == WearShape.round ? 32.0 : 12.0,
              bottom: 8.0,
            ),
            sliver: SliverToBoxAdapter(
              child: Card(
                color: Colors.red[900],
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: 48),
                  child: InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) {
                        // Pop both this screen and settings screen
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
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
                            'Yes, Sign Out',
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

          SliverPadding(
            padding: EdgeInsets.only(
              left: shape == WearShape.round ? 32.0 : 12.0,
              right: shape == WearShape.round ? 32.0 : 12.0,
              bottom: 36.0, // Increased bottom padding to prevent clipping
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
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: 48),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close,
                            size: 20,
                            color: mode == WearMode.active
                                ? Colors.white70
                                : Colors.white54,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: mode == WearMode.active
                                  ? Colors.white70
                                  : Colors.white54,
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
        ],
      ),
    );
  }
}
