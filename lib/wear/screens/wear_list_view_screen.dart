import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';

class WearListViewScreen extends StatefulWidget {
  final String listId;
  final String listName;

  const WearListViewScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<WearListViewScreen> createState() => _WearListViewScreenState();
}

class _WearListViewScreenState extends State<WearListViewScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Delay stream initialization to prevent any potential issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleItemChecked(String itemId, bool currentValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .doc(itemId)
          .update({
        'completed': !currentValue,
        'lastModified': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              body: _buildItemsStream(mode),
            );
          },
        );
      },
    );
  }

  Widget _buildItemsStream(WearMode mode) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .orderBy('timestamp', descending: false)
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
              'No items in this list',
              style: TextStyle(
                color:
                    mode == WearMode.active ? Colors.white70 : Colors.white54,
                fontSize: 12,
              ),
            ),
          );
        }

        final items = snapshot.data!.docs;
        final uncheckedItems = items.where((item) {
          final data = item.data() as Map<String, dynamic>;
          return data['completed'] != true;
        }).toList();

        final checkedItems = items.where((item) {
          final data = item.data() as Map<String, dynamic>;
          return data['completed'] == true;
        }).toList();

        return RotaryScrollbar(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              // Unchecked items
              ...uncheckedItems.map((item) => _buildItemCard(item, mode)),

              // Checked items
              if (checkedItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: mode == WearMode.active
                          ? Colors.white54
                          : Colors.white38,
                    ),
                  ),
                ),
                ...checkedItems.map((item) => _buildItemCard(item, mode)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(DocumentSnapshot item, WearMode mode) {
    final data = item.data() as Map<String, dynamic>;
    final itemName = data['name'] ?? 'Unnamed Item';
    final quantity = data['quantity'] ?? 1;
    final isChecked = data['completed'] == true;

    return Card(
      color: mode == WearMode.active
          ? (isChecked ? Colors.grey[850] : Colors.grey[900])
          : Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _toggleItemChecked(item.id, isChecked),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(
                isChecked ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: isChecked
                    ? (mode == WearMode.active
                        ? Colors.green[400]
                        : Colors.green[700])
                    : (mode == WearMode.active
                        ? Colors.white54
                        : Colors.white38),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: TextStyle(
                        fontSize: 13,
                        color: mode == WearMode.active
                            ? (isChecked ? Colors.white54 : Colors.white)
                            : Colors.white70,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (quantity > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Qty: $quantity',
                        style: TextStyle(
                          fontSize: 11,
                          color: mode == WearMode.active
                              ? Colors.white38
                              : Colors.white24,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
