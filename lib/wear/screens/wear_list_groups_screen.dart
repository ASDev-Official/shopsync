import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'wear_group_lists_screen.dart';
import 'wear_settings_screen.dart';

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
              // ShopSync Branding
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: shape == WearShape.round ? 40.0 : 16.0,
                    right: shape == WearShape.round ? 40.0 : 16.0,
                    top: shape == WearShape.round ? 32.0 : 16.0,
                    bottom: 8.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green[800],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ShopSync',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: mode == WearMode.active
                                  ? Colors.white
                                  : Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WearSettingsScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.settings,
                            size: 24,
                            color: mode == WearMode.active
                                ? Colors.white70
                                : Colors.white54,
                          ),
                        ),
                      ),
                    ],
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
