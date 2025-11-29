import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'wear_list_view_screen.dart';

class WearHomeScreen extends StatefulWidget {
  const WearHomeScreen({super.key});

  @override
  State<WearHomeScreen> createState() => _WearHomeScreenState();
}

class _WearHomeScreenState extends State<WearHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _listsStream;

  @override
  void initState() {
    super.initState();
    // Delay stream initialization to prevent freeze on login
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
        _listsStream = FirebaseFirestore.instance
            .collection('lists')
            .where('members', arrayContains: user.uid)
            .orderBy('createdAt', descending: true)
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
              body: _buildListsStream(user, mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildListsStream(User? user, WearMode mode, WearShape shape) {
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    if (_listsStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _listsStream,
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

        final lists = snapshot.hasData ? snapshot.data!.docs : [];

        return RotaryScrollbar(
          controller: _scrollController,
          autoHideDuration: const Duration(seconds: 2),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: shape == WearShape.round ? 32.0 : 16.0,
                    right: shape == WearShape.round ? 32.0 : 16.0,
                    top: shape == WearShape.round ? 24.0 : 16.0,
                    bottom: 12.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: mode == WearMode.active
                            ? Colors.green[400]
                            : Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ShopSync',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: mode == WearMode.active
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                          size: 18,
                          color: mode == WearMode.active
                              ? Colors.white70
                              : Colors.white54,
                        ),
                        color: Colors.grey[900],
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.exit_to_app,
                                    size: 18, color: Colors.red[400]),
                                const SizedBox(width: 8),
                                const Text('Sign Out',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // List items
              SliverPadding(
                padding: EdgeInsets.only(
                  left: shape == WearShape.round ? 24.0 : 12.0,
                  right: shape == WearShape.round ? 24.0 : 12.0,
                  bottom: 20.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final list = lists[index];
                      final data = list.data() as Map<String, dynamic>;
                      final listName = data['name'] ?? 'Unnamed List';

                      return FutureBuilder<int>(
                        future: _getItemCount(list.id),
                        builder: (context, itemSnapshot) {
                          final itemCount = itemSnapshot.data ?? 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              color: mode == WearMode.active
                                  ? Colors.grey[900]
                                  : Colors.grey[850],
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WearListViewScreen(
                                        listId: list.id,
                                        listName: listName,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listName,
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
                                        '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: mode == WearMode.active
                                              ? Colors.green[300]
                                              : Colors.green[700],
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
                    },
                    childCount: lists.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> _getItemCount(String listId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('lists')
        .doc(listId)
        .collection('items')
        .get();
    return snapshot.docs.length;
  }
}
