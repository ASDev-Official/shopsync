import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'wear_list_categories_screen.dart';

class WearGroupListsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const WearGroupListsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<WearGroupListsScreen> createState() => _WearGroupListsScreenState();
}

class _WearGroupListsScreenState extends State<WearGroupListsScreen> {
  final ScrollController _scrollController = ScrollController();
  Stream<DocumentSnapshot>? _groupStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _groupStream = FirebaseFirestore.instance
              .collection('list_groups')
              .doc(widget.groupId)
              .snapshots();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot?> _getListData(String listId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('lists')
          .doc(listId)
          .get();
      return doc.exists ? doc : null;
    } catch (e) {
      return null;
    }
  }

  Future<int> _getItemCount(String listId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('lists')
          .doc(listId)
          .collection('items')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
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
              body: _buildListsStream(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildListsStream(WearMode mode, WearShape shape) {
    if (_groupStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _groupStream,
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

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              'Group not found',
              style: TextStyle(
                fontSize: 12,
                color:
                    mode == WearMode.active ? Colors.white70 : Colors.white54,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final listIds = List<String>.from(data['listIds'] ?? []);

        if (listIds.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: shape == WearShape.round ? 32.0 : 16.0,
              ),
              child: Text(
                'No lists in this group\nAdd lists on your phone',
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
                      widget.groupName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: mode == WearMode.active
                            ? Colors.white
                            : Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // List items
              SliverPadding(
                padding: EdgeInsets.only(
                  left: shape == WearShape.round ? 32.0 : 12.0,
                  right: shape == WearShape.round ? 32.0 : 12.0,
                  bottom: 20.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final listId = listIds[index];
                      return FutureBuilder<DocumentSnapshot?>(
                        future: _getListData(listId),
                        builder: (context, listSnapshot) {
                          if (!listSnapshot.hasData ||
                              listSnapshot.data == null) {
                            return const SizedBox.shrink();
                          }
                          final listData = listSnapshot.data!.data()
                              as Map<String, dynamic>?;
                          if (listData == null) {
                            return const SizedBox.shrink();
                          }
                          final listName = listData['name'] ?? 'Unnamed List';
                          return FutureBuilder<int>(
                            future: _getItemCount(listId),
                            builder: (context, itemSnapshot) {
                              final itemCount = itemSnapshot.data ?? 0;
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
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        minHeight: 48, minWidth: 48),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WearListCategoriesScreen(
                                              listId: listId,
                                              listName: listName,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.list_alt,
                                              size: 18,
                                              color: mode == WearMode.active
                                                  ? Colors.blue[300]
                                                  : Colors.blue[700],
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    listName,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: mode ==
                                                              WearMode.active
                                                          ? Colors.white
                                                          : Colors.white70,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: mode ==
                                                              WearMode.active
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
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    childCount: listIds.length,
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
