import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'wear_item_details_screen.dart';

class WearCategoryItemsScreen extends StatefulWidget {
  final String listId;
  final String? categoryId;
  final String categoryName;

  const WearCategoryItemsScreen({
    super.key,
    required this.listId,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<WearCategoryItemsScreen> createState() =>
      _WearCategoryItemsScreenState();
}

class _WearCategoryItemsScreenState extends State<WearCategoryItemsScreen> {
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _itemsStream;

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
    setState(() {
      _itemsStream = FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .orderBy('addedAt', descending: true)
          .snapshots();
    });
  }

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
              body: _buildItemsStream(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildItemsStream(WearMode mode, WearShape shape) {
    if (_itemsStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _itemsStream,
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: shape == WearShape.round ? 32.0 : 16.0,
              ),
              child: Text(
                'No items in this list',
                style: TextStyle(
                  color:
                      mode == WearMode.active ? Colors.white70 : Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Filter items by category
        final allItems = snapshot.data!.docs;

        final categoryItems = allItems.where((item) {
          final data = item.data() as Map<String, dynamic>;
          final itemCategoryId = data['categoryId'] as String?;
          return itemCategoryId == widget.categoryId;
        }).toList();

        if (categoryItems.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: shape == WearShape.round ? 32.0 : 16.0,
              ),
              child: Text(
                'No items in this category\n(Check console logs)',
                style: TextStyle(
                  color:
                      mode == WearMode.active ? Colors.white70 : Colors.white54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Separate unchecked and checked items
        final uncheckedItems = categoryItems.where((item) {
          final data = item.data() as Map<String, dynamic>;
          return data['completed'] != true;
        }).toList();

        final checkedItems = categoryItems.where((item) {
          final data = item.data() as Map<String, dynamic>;
          return data['completed'] == true;
        }).toList();

        return RotaryScrollbar(
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header (no back button, padded title)
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
                      widget.categoryName,
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
              // Unchecked items
              SliverPadding(
                padding: EdgeInsets.only(
                  left: shape == WearShape.round ? 32.0 : 12.0,
                  right: shape == WearShape.round ? 32.0 : 12.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildItemCard(uncheckedItems[index], mode),
                    childCount: uncheckedItems.length,
                  ),
                ),
              ),
              // Checked items section
              if (checkedItems.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: shape == WearShape.round ? 28.0 : 16.0,
                      right: shape == WearShape.round ? 28.0 : 16.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 11,
                        color: mode == WearMode.active
                            ? Colors.white54
                            : Colors.white38,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: shape == WearShape.round ? 32.0 : 12.0,
                    right: shape == WearShape.round ? 32.0 : 12.0,
                    bottom: 20.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildItemCard(checkedItems[index], mode),
                      childCount: checkedItems.length,
                    ),
                  ),
                ),
              ] else
                const SliverPadding(padding: EdgeInsets.only(bottom: 20.0)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemCard(DocumentSnapshot item, WearMode mode) {
    final data = item.data() as Map<String, dynamic>;
    final itemName = data['name'] ?? 'Unnamed Item';
    final quantity = data['counter'] ?? 1;
    final isChecked = data['completed'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        color: mode == WearMode.active
            ? (isChecked ? Colors.grey[850] : Colors.grey[900])
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
                builder: (context) => WearItemDetailsScreen(
                  listId: widget.listId,
                  itemId: item.id,
                ),
              ),
            );
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(minHeight: 48, minWidth: 48),
                    child: GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isChecked
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          size: 24,
                          color: isChecked
                              ? (mode == WearMode.active
                                  ? Colors.green[400]
                                  : Colors.green[700])
                              : (mode == WearMode.active
                                  ? Colors.white54
                                  : Colors.white38),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 12,
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
                              fontSize: 10,
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
        ),
      ),
    );
  }
}
