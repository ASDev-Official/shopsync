import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'wear_sign_out_screen.dart';

class WearSettingsScreen extends StatefulWidget {
  const WearSettingsScreen({super.key});

  @override
  State<WearSettingsScreen> createState() => _WearSettingsScreenState();
}

class _WearSettingsScreenState extends State<WearSettingsScreen> {
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
              body: _buildSettings(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildSettings(WearMode mode, WearShape shape) {
    final user = FirebaseAuth.instance.currentUser;

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
                  'Settings',
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

          // Account Info
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 36.0 : 16.0,
                right: shape == WearShape.round ? 36.0 : 16.0,
                bottom: 8.0,
              ),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      mode == WearMode.active ? Colors.white54 : Colors.white38,
                ),
              ),
            ),
          ),

          // User info card
          if (user != null)
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 16,
                              color: mode == WearMode.active
                                  ? Colors.white54
                                  : Colors.white38,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.displayName ?? 'User',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mode == WearMode.active
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (user.email != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: mode == WearMode.active
                                    ? Colors.white38
                                    : Colors.white24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user.email!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mode == WearMode.active
                                        ? Colors.white54
                                        : Colors.white38,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Actions section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: shape == WearShape.round ? 36.0 : 16.0,
                right: shape == WearShape.round ? 36.0 : 16.0,
                bottom: 8.0,
                top: 8.0,
              ),
              child: Text(
                'Actions',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      mode == WearMode.active ? Colors.white54 : Colors.white38,
                ),
              ),
            ),
          ),

          // Sign out button
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WearSignOutScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            size: 18,
                            color: Colors.red[400],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 12,
                                color: mode == WearMode.active
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: mode == WearMode.active
                                ? Colors.white38
                                : Colors.white24,
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
