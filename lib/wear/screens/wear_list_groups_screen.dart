import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'wear_group_lists_screen.dart';
import 'wear_settings_screen.dart';
import '../../services/platform/statuspage_service.dart';
import '../../models/status_outage.dart';
import 'wear_outage_screen.dart';

class WearListGroupsScreen extends StatefulWidget {
  const WearListGroupsScreen({super.key});

  @override
  State<WearListGroupsScreen> createState() => _WearListGroupsScreenState();
}

class _WearListGroupsScreenState extends State<WearListGroupsScreen> {
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _groupsStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeStream();
      }
    });
  }

  void _initializeStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _groupsStream = FirebaseFirestore.instance
            .collection('list_groups')
            .where('members', arrayContains: user.uid)
            .orderBy('position')
            .snapshots();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Scaffold(
              backgroundColor:
                  mode == WearMode.active ? Colors.black : Colors.black,
              body: _buildGroupsStream(user, mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsStream(User? user, WearMode mode, WearShape shape) {
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    if (_groupsStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _groupsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }

        final groups = snapshot.hasData ? snapshot.data!.docs : [];

        if (groups.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: shape == WearShape.round ? 32.0 : 16.0,
              ),
              child: Text(
                'No list groups\nCreate one on your phone',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      mode == WearMode.active ? Colors.white70 : Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RotaryScrollbar(
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header: ShopSync branding or outage indicator (if dialog dismissed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: shape == WearShape.round ? 40.0 : 16.0,
                    right: shape == WearShape.round ? 40.0 : 16.0,
                    top: shape == WearShape.round ? 32.0 : 16.0,
                    bottom: 8.0,
                  ),
                  child: ValueListenableBuilder<StatusOutage?>(
                    valueListenable: StatuspageService.currentOutage,
                    builder: (context, outage, _) {
                      final showOutageIndicator = outage?.active == true &&
                          StatuspageService.dialogDismissedThisSession;
                      if (showOutageIndicator) {
                        return InkWell(
                          onTap: () {
                            if (outage != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WearOutageScreen(
                                    outage: outage,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        outage?.shortStatus == 'outage'
                                            ? 'Outage'
                                            : (outage?.shortStatus == 'fixed'
                                                ? 'Fixed'
                                                : 'Status'),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: mode == WearMode.active
                                              ? Colors.white
                                              : Colors.white70,
                                        ),
                                      ),
                                      if ((outage?.affectedComponents ??
                                              const [])
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatFirstComponent(
                                              outage!.affectedComponents),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: mode == WearMode.active
                                                ? Colors.white70
                                                : Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.green[800],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'ShopSync',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: mode == WearMode.active
                                    ? Colors.white
                                    : Colors.white70,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Settings icon+text button below logo
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: shape == WearShape.round ? 40.0 : 16.0,
                    right: shape == WearShape.round ? 40.0 : 16.0,
                    bottom: 12.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: mode == WearMode.active
                            ? Colors.white
                            : Colors.white70,
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                      ),
                      icon: const Icon(Icons.settings, size: 22),
                      label: const Text('Settings',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WearSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // List Groups Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: shape == WearShape.round ? 32.0 : 16.0,
                    right: shape == WearShape.round ? 32.0 : 16.0,
                    bottom: 12.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder,
                        color: mode == WearMode.active
                            ? Colors.green[400]
                            : Colors.green[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'List Groups',
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
              // Group items
              SliverPadding(
                padding: EdgeInsets.only(
                  left: shape == WearShape.round ? 32.0 : 12.0,
                  right: shape == WearShape.round ? 32.0 : 12.0,
                  bottom: 20.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = groups[index];
                      final data = group.data() as Map<String, dynamic>;
                      final groupName = data['name'] ?? 'Unnamed Group';
                      final listIds = List<String>.from(data['listIds'] ?? []);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          color: mode == WearMode.active
                              ? Colors.grey[900]
                              : Colors.grey[850],
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WearGroupListsScreen(
                                    groupId: group.id,
                                    groupName: groupName,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 18,
                                    color: mode == WearMode.active
                                        ? Colors.green[300]
                                        : Colors.green[700],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          groupName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: mode == WearMode.active
                                                ? Colors.white
                                                : Colors.white70,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${listIds.length} ${listIds.length == 1 ? 'list' : 'lists'}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: mode == WearMode.active
                                                ? Colors.white54
                                                : Colors.white38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: Colors.white38,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: groups.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension _WearOutageText on _WearListGroupsScreenState {
  String _formatFirstComponent(List<String> comps) {
    if (comps.isEmpty) return '';
    if (comps.length == 1) return 'Affected: ${comps.first}';
    return 'Affected: ${comps.first} +${comps.length - 1} more';
  }
}
