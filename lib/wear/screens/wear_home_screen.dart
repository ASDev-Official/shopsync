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
              body: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ShopSync',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: mode == WearMode.active
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.exit_to_app, size: 20),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Lists
                    Expanded(
                      child: _buildListsStream(user, mode),
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

  Widget _buildListsStream(User? user, WearMode mode) {
    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .where('users', arrayContains: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
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

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No lists found.\nCreate one on your phone.',
              style: TextStyle(
                color:
                    mode == WearMode.active ? Colors.white70 : Colors.white54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final lists = snapshot.data!.docs;

        return RotaryScrollbar(
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              final data = list.data() as Map<String, dynamic>;
              final listName = data['name'] ?? 'Unnamed List';

              return FutureBuilder<int>(
                future: _getItemCount(list.id),
                builder: (context, itemSnapshot) {
                  final itemCount = itemSnapshot.data ?? 0;

                  return Card(
                    color: mode == WearMode.active
                        ? Colors.grey[900]
                        : Colors.grey[850],
                    margin: const EdgeInsets.only(bottom: 8),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listName,
                              style: TextStyle(
                                fontSize: 14,
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
                                fontSize: 12,
                                color: mode == WearMode.active
                                    ? Colors.green[300]
                                    : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
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
