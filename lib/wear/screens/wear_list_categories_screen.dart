import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'wear_category_items_screen.dart';

class WearListCategoriesScreen extends StatefulWidget {
  final String listId;
  final String listName;

  const WearListCategoriesScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<WearListCategoriesScreen> createState() =>
      _WearListCategoriesScreenState();
}

class _WearListCategoriesScreenState extends State<WearListCategoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _categoriesStream;
  Stream<QuerySnapshot>? _itemsStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _categoriesStream = FirebaseFirestore.instance
              .collection('lists')
              .doc(widget.listId)
              .collection('categories')
              .orderBy('order')
              .snapshots();

          _itemsStream = FirebaseFirestore.instance
              .collection('lists')
              .doc(widget.listId)
              .collection('items')
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

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Scaffold(
              backgroundColor:
                  mode == WearMode.active ? Colors.black : Colors.black,
              body: _buildCategoriesStream(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesStream(WearMode mode, WearShape shape) {
    if (_categoriesStream == null || _itemsStream == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _categoriesStream,
      builder: (context, categoriesSnapshot) {
        if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoriesSnapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${categoriesSnapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _itemsStream,
          builder: (context, itemsSnapshot) {
            if (itemsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories =
                categoriesSnapshot.hasData ? categoriesSnapshot.data!.docs : [];
            final items = itemsSnapshot.hasData ? itemsSnapshot.data!.docs : [];

            // Count items per category
            final Map<String?, int> itemCountByCategory = {null: 0};
            for (var category in categories) {
              itemCountByCategory[category.id] = 0;
            }

            for (var item in items) {
              final data = item.data() as Map<String, dynamic>;
              final categoryId = data['categoryId'] as String?;
              itemCountByCategory[categoryId] =
                  (itemCountByCategory[categoryId] ?? 0) + 1;
            }

            // Filter categories that have items
            final categoriesWithItems = categories.where((category) {
              return (itemCountByCategory[category.id] ?? 0) > 0;
            }).toList();

            final uncategorizedCount = itemCountByCategory[null] ?? 0;

            if (categoriesWithItems.isEmpty && uncategorizedCount == 0) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: shape == WearShape.round ? 32.0 : 16.0,
                  ),
                  child: Text(
                    'No items in this list\nAdd items on your phone',
                    style: TextStyle(
                      fontSize: 12,
                      color: mode == WearMode.active
                          ? Colors.white70
                          : Colors.white54,
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
                          widget.listName,
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
                  // Category items
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: shape == WearShape.round ? 32.0 : 12.0,
                      right: shape == WearShape.round ? 32.0 : 12.0,
                      bottom: 20.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Add uncategorized items as first category if they exist
                          if (uncategorizedCount > 0) {
                            if (index == 0) {
                              return _buildCategoryCard(
                                categoryId: null,
                                categoryName: 'Uncategorized',
                                itemCount: uncategorizedCount,
                                mode: mode,
                              );
                            }
                            index--;
                          }

                          final category = categoriesWithItems[index];
                          final data = category.data() as Map<String, dynamic>;
                          final categoryName =
                              data['name'] ?? 'Unnamed Category';
                          final itemCount =
                              itemCountByCategory[category.id] ?? 0;

                          return _buildCategoryCard(
                            categoryId: category.id,
                            categoryName: categoryName,
                            itemCount: itemCount,
                            mode: mode,
                          );
                        },
                        childCount: categoriesWithItems.length +
                            (uncategorizedCount > 0 ? 1 : 0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required String? categoryId,
    required String categoryName,
    required int itemCount,
    required WearMode mode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: mode == WearMode.active ? Colors.grey[900] : Colors.grey[850],
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WearCategoryItemsScreen(
                  listId: widget.listId,
                  categoryId: categoryId,
                  categoryName: categoryName,
                ),
              ),
            );
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 18,
                    color: mode == WearMode.active
                        ? Colors.orange[300]
                        : Colors.orange[700],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
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
  }
}
