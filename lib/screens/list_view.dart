import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'item_details.dart';
import 'create_item.dart';
import 'list_options.dart';
import '/widgets/loading_spinner.dart';
import '/libraries/icons/food_icons_map.dart';
import '/utils/permissions.dart';

class ListViewScreen extends StatefulWidget {
  final String listId;
  final String listName;

  const ListViewScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final _firestore = FirebaseFirestore.instance;
  late AnimationController _itemsAnimationController;
  late AnimationController _optionsAnimationController;
  late Animation<double> _itemsBounceAnimation;
  late Animation<double> _itemsRotateAnimation;
  late Animation<double> _optionsSpinAnimation;

  @override
  void initState() {
    super.initState();

    // Items animation controller for bouncy effect
    _itemsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _itemsBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _itemsAnimationController,
      curve: Curves.elasticOut,
    ));
    _itemsRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1, // Small rotation for playful effect
    ).animate(CurvedAnimation(
      parent: _itemsAnimationController,
      curve: Curves.elasticOut,
    ));

    // Options animation controller for spin effect
    _optionsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _optionsSpinAnimation = Tween<double>(
      begin: 0.0,
      end: 2.5, // 2.5 full rotations for extra playfulness
    ).animate(CurvedAnimation(
      parent: _optionsAnimationController,
      curve: Curves.easeInOutBack, // More playful curve with overshoot
    ));
  }

  @override
  void dispose() {
    _itemsAnimationController.dispose();
    _optionsAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add haptic feedback
    HapticFeedback.selectionClick();

    // Play different animations based on selected tab
    if (index == 0) {
      // Items tab - bouncy animation
      _itemsAnimationController.forward().then((_) {
        _itemsAnimationController.reverse();
      });
    } else if (index == 1) {
      // Options tab - spin animation
      _optionsAnimationController.forward().then((_) {
        _optionsAnimationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrTablet = screenWidth >= 600; // Tablets and desktop

    Widget body = IndexedStack(
      index: _selectedIndex,
      children: [
        ItemsTab(listId: widget.listId, listName: widget.listName),
        ListOptionsScreen(listId: widget.listId, listName: widget.listName),
      ],
    );

    Widget? fab = _selectedIndex == 0
        ? FutureBuilder<bool>(
            future: PermissionsHelper.isViewer(widget.listId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return const SizedBox.shrink();
              }
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? Colors.green[700] : Colors.green[600],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateItemScreen(listId: widget.listId),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : null;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('lists').doc(widget.listId).snapshots(),
          builder: (context, snapshot) {
            String listName = widget.listName;
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              listName = data?['name'] ?? widget.listName;
            }
            return Text(
              listName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isDesktopOrTablet
          ? Row(
              children: [
                // Navigation Rail for desktop/tablet
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  indicatorColor:
                      isDark ? Colors.green[800] : Colors.green[600],
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: -0.8,
                  destinations: [
                    NavigationRailDestination(
                      icon: AnimatedBuilder(
                        animation: _itemsAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _selectedIndex == 0
                                ? _itemsBounceAnimation.value
                                : 1.0,
                            child: Transform.rotate(
                              angle: _selectedIndex == 0
                                  ? _itemsRotateAnimation.value * 2 * 3.14159
                                  : 0.0,
                              child: Icon(
                                Icons.checklist_outlined,
                                color: _selectedIndex == 0
                                    ? Colors.white
                                    : (isDark
                                        ? Colors.grey[400]
                                        : Colors.green[600]),
                              ),
                            ),
                          );
                        },
                      ),
                      selectedIcon: AnimatedBuilder(
                        animation: _itemsAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _selectedIndex == 0
                                ? _itemsBounceAnimation.value
                                : 1.0,
                            child: Transform.rotate(
                              angle: _selectedIndex == 0
                                  ? _itemsRotateAnimation.value * 2 * 3.14159
                                  : 0.0,
                              child: const Icon(
                                Icons.checklist,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      label: Text(
                        'Items',
                        style: TextStyle(
                          color: _selectedIndex == 0
                              ? (isDark ? Colors.white : Colors.green[800])
                              : (isDark ? Colors.grey[400] : Colors.green[600]),
                          fontWeight: _selectedIndex == 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    NavigationRailDestination(
                      icon: AnimatedBuilder(
                        animation: _optionsSpinAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _selectedIndex == 1
                                ? _optionsSpinAnimation.value * 2 * 3.14159
                                : 0.0,
                            child: Icon(
                              Icons.settings_outlined,
                              color: _selectedIndex == 1
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.grey[400]
                                      : Colors.green[600]),
                            ),
                          );
                        },
                      ),
                      selectedIcon: AnimatedBuilder(
                        animation: _optionsSpinAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _selectedIndex == 1
                                ? _optionsSpinAnimation.value * 2 * 3.14159
                                : 0.0,
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      label: Text(
                        'Options',
                        style: TextStyle(
                          color: _selectedIndex == 1
                              ? (isDark ? Colors.white : Colors.green[800])
                              : (isDark ? Colors.grey[400] : Colors.green[600]),
                          fontWeight: _selectedIndex == 1
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Main content
                Expanded(child: body),
              ],
            )
          : body,
      bottomNavigationBar: isDesktopOrTablet
          ? null
          : Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
                  indicatorColor:
                      isDark ? Colors.green[800] : Colors.green[600],
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return TextStyle(
                        color: isDark ? Colors.white : Colors.green[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      );
                    }
                    return TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.green[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(
                        color: Colors.white,
                        size: 24,
                      );
                    }
                    return IconThemeData(
                      color: isDark ? Colors.grey[400] : Colors.green[600],
                      size: 20,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                destinations: [
                  NavigationDestination(
                    icon: AnimatedBuilder(
                      animation: _itemsAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _selectedIndex == 0
                              ? _itemsBounceAnimation.value
                              : 1.0,
                          child: Transform.rotate(
                            angle: _selectedIndex == 0
                                ? _itemsRotateAnimation.value * 2 * 3.14159
                                : 0.0,
                            child: const Icon(Icons.checklist_outlined),
                          ),
                        );
                      },
                    ),
                    selectedIcon: AnimatedBuilder(
                      animation: _itemsAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _selectedIndex == 0
                              ? _itemsBounceAnimation.value
                              : 1.0,
                          child: Transform.rotate(
                            angle: _selectedIndex == 0
                                ? _itemsRotateAnimation.value * 2 * 3.14159
                                : 0.0,
                            child: const Icon(Icons.checklist),
                          ),
                        );
                      },
                    ),
                    label: 'Items',
                  ),
                  NavigationDestination(
                    icon: AnimatedBuilder(
                      animation: _optionsSpinAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _selectedIndex == 1
                              ? _optionsSpinAnimation.value * 2 * 3.14159
                              : 0.0,
                          child: const Icon(Icons.settings_outlined),
                        );
                      },
                    ),
                    selectedIcon: AnimatedBuilder(
                      animation: _optionsSpinAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _selectedIndex == 1
                              ? _optionsSpinAnimation.value * 2 * 3.14159
                              : 0.0,
                          child: const Icon(Icons.settings),
                        );
                      },
                    ),
                    label: 'Options',
                  ),
                ],
              ),
            ),
      floatingActionButton: fab,
    );
  }
}

class ItemsTab extends StatefulWidget {
  final String listId;
  final String listName;

  const ItemsTab({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  final _firestore = FirebaseFirestore.instance;

  // String _standardizePriority(String? priority) {
  //   switch (priority?.toLowerCase()) {
  //     case 'high':
  //       return 'high';
  //     case 'medium':
  //       return 'medium';
  //     case 'low':
  //       return 'low';
  //     default:
  //       return 'low';
  //   }
  // }

  // Widget _buildPriorityBadge(String priority) {
  //   Color color;
  //   IconData icon;

  //   switch (priority.toLowerCase()) {
  //     case 'high':
  //       color = Colors.red;
  //       icon = FontAwesomeIcons.exclamation;
  //       break;
  //     case 'medium':
  //       color = Colors.orange;
  //       icon = FontAwesomeIcons.minus;
  //       break;
  //     case 'low':
  //     default:
  //       color = Colors.green;
  //       icon = FontAwesomeIcons.arrowDown;
  //       break;
  //   }

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: color.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: color, width: 1),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         FaIcon(icon, size: 10, color: color),
  //         const SizedBox(width: 4),
  //         Text(
  //           priority.toUpperCase(),
  //           style: TextStyle(
  //             color: color,
  //             fontSize: 10,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatsCard(QuerySnapshot itemsSnapshot) {
    final totalItems = itemsSnapshot.docs.length;
    final completedItems = itemsSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['completed'] ?? false;
    }).length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
              strokeWidth: 6,
            ),
          ),
          const SizedBox(width: 16),

          // Stats text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(progress * 100).round()}% Complete',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '$completedItems of $totalItems items completed',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('lists')
                .doc(widget.listId)
                .collection('items')
                .orderBy('addedAt', descending: true)
                .snapshots(),
            builder: (context, itemsSnapshot) {
              if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CustomLoadingSpinner());
              }

              if (itemsSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading items',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!itemsSnapshot.hasData || itemsSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No items yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first item to get started',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Fetch categories
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('lists')
                    .doc(widget.listId)
                    .collection('categories')
                    .orderBy('order', descending: false)
                    .snapshots(),
                builder: (context, categoriesSnapshot) {
                  final items = itemsSnapshot.data!.docs;

                  // Group items by category and completion status
                  final Map<String?, List<DocumentSnapshot>> itemsByCategory = {
                    null: [], // Uncategorized items
                  };

                  // Initialize categories
                  if (categoriesSnapshot.hasData) {
                    for (var categoryDoc in categoriesSnapshot.data!.docs) {
                      itemsByCategory[categoryDoc.id] = [];
                    }
                  }

                  // Group items
                  for (var item in items) {
                    final data = item.data() as Map<String, dynamic>;
                    final categoryId = data['categoryId'] as String?;
                    if (!itemsByCategory.containsKey(categoryId)) {
                      itemsByCategory[categoryId] = [];
                    }
                    itemsByCategory[categoryId]!.add(item);
                  }

                  // Separate incomplete and completed items within each category
                  final Map<String?, Map<String, List<DocumentSnapshot>>>
                      groupedItems = {};

                  itemsByCategory.forEach((categoryId, categoryItems) {
                    final incomplete = categoryItems.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return !(data['completed'] ?? false);
                    }).toList();

                    final completed = categoryItems.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['completed'] ?? false;
                    }).toList();

                    if (incomplete.isNotEmpty || completed.isNotEmpty) {
                      groupedItems[categoryId] = {
                        'incomplete': incomplete,
                        'completed': completed,
                      };
                    }
                  });

                  return ListView(
                    children: [
                      _buildStatsCard(itemsSnapshot.data!),

                      // Build category sections
                      ...groupedItems.entries.map((entry) {
                        final categoryId = entry.key;
                        final categoryItemGroups = entry.value;
                        final incompleteItems =
                            categoryItemGroups['incomplete']!;
                        final completedItems = categoryItemGroups['completed']!;

                        // Get category data
                        Map<String, dynamic>? categoryData;
                        if (categoryId != null && categoriesSnapshot.hasData) {
                          try {
                            final categoryDoc = categoriesSnapshot.data!.docs
                                .firstWhere((doc) => doc.id == categoryId);
                            categoryData =
                                categoryDoc.data() as Map<String, dynamic>;
                          } catch (e) {
                            // Category not found
                          }
                        }

                        return CategorySection(
                          key: ValueKey(categoryId ?? 'uncategorized'),
                          categoryId: categoryId,
                          categoryData: categoryData,
                          incompleteItems: incompleteItems,
                          completedItems: completedItems,
                          listId: widget.listId,
                        );
                      }),

                      const SizedBox(height: 80), // Space for FAB
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Separate stateful widget for each category section to prevent full page rebuilds
class CategorySection extends StatefulWidget {
  final String? categoryId;
  final Map<String, dynamic>? categoryData;
  final List<DocumentSnapshot> incompleteItems;
  final List<DocumentSnapshot> completedItems;
  final String listId;

  const CategorySection({
    super.key,
    required this.categoryId,
    required this.categoryData,
    required this.incompleteItems,
    required this.completedItems,
    required this.listId,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  bool _isExpanded = true; // Default to expanded

  void _toggleItemCompletion(String itemId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .doc(itemId)
          .update({
        'completed': !currentStatus,
      });
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'message': 'Failed to toggle item completion',
          'listId': widget.listId,
          'itemId': itemId,
        }),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update item status')),
      );
    }
  }

  void _deleteItem(String itemId) async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // Get the item data before deleting
      final itemDoc = await firestore
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .doc(itemId)
          .get();

      if (!itemDoc.exists) return;

      final batch = firestore.batch();

      // Move to recycled_items collection
      batch.set(
        firestore
            .collection('lists')
            .doc(widget.listId)
            .collection('recycled_items')
            .doc(),
        {
          ...itemDoc.data()!,
          'deletedAt': FieldValue.serverTimestamp(),
          'deletedBy': auth.currentUser!.uid,
          'deletedByName': auth.currentUser!.displayName,
        },
      );

      // Delete from original collection
      batch.delete(itemDoc.reference);

      await batch.commit();
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'message': 'Failed to delete item',
          'listId': widget.listId,
          'itemId': itemId,
        }),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item')),
      );
    }
  }

  Widget _buildItemCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isCompleted = data['completed'] ?? false;
    final deadline = data['deadline'] as Timestamp?;
    final location = data['location'] as Map<String, dynamic>?;
    final counter = data['counter'] ?? 1;
    final iconIdentifier = data['iconIdentifier'] as String?;
    final itemIcon =
        iconIdentifier != null ? FoodIconMap.getIcon(iconIdentifier) : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(
                listId: widget.listId,
                itemId: doc.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isCompleted
                ? (isDark ? Colors.grey[800] : Colors.grey[100])
                : null,
          ),
          child: Row(
            children: [
              // Checkbox
              FutureBuilder<bool>(
                future: PermissionsHelper.isViewer(widget.listId),
                builder: (context, snapshot) {
                  final isViewerMode =
                      snapshot.hasData && snapshot.data == true;

                  return GestureDetector(
                    onTap: isViewerMode
                        ? null
                        : () => _toggleItemCompletion(doc.id, isCompleted),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green[700]!
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isCompleted
                            ? Colors.green[700]
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),

              // Item Icon
              if (itemIcon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isDark ? Colors.grey[700] : Colors.grey[300])
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? (isDark ? Colors.grey[600]! : Colors.grey[400]!)
                          : Colors.green[200]!,
                      width: 1,
                    ),
                  ),
                  child: itemIcon.buildIcon(
                    width: 28,
                    height: 28,
                    color: isCompleted
                        ? (isDark ? Colors.grey[400] : Colors.grey[600])
                        : Colors.green[800],
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Item content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['name'] ?? 'Unnamed Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted ? Colors.grey[600] : null,
                            ),
                          ),
                        ),
                        if (counter > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'x$counter',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (data['description'] != null &&
                        data['description'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          data['description'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Tags row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (deadline != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time,
                                    size: 10, color: Colors.orange[800]),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM dd, HH:mm')
                                      .format(deadline.toDate()),
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (location != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    size: 10, color: Colors.purple[800]),
                                const SizedBox(width: 4),
                                Text(
                                  location['name'] ?? 'Location',
                                  style: TextStyle(
                                    color: Colors.purple[800],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              FutureBuilder<bool>(
                future: PermissionsHelper.isViewer(widget.listId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    onPressed: () => _deleteItem(doc.id),
                    icon: Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.red[400],
                    ),
                    tooltip: 'Delete item',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryName = widget.categoryData?['name'] ?? 'Uncategorized';
    final iconIdentifier = widget.categoryData?['iconIdentifier'] as String?;
    final categoryIcon =
        iconIdentifier != null ? FoodIconMap.getIcon(iconIdentifier) : null;

    final totalItems =
        widget.incompleteItems.length + widget.completedItems.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Category header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
              bottom: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.green[50],
                borderRadius: _isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: categoryIcon != null
                        ? categoryIcon.buildIcon(
                            width: 24,
                            height: 24,
                            color: Colors.green[800],
                          )
                        : Icon(
                            Icons.label,
                            color: Colors.green[800],
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Category name and count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '$totalItems item${totalItems != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expansion icon with rotation animation
                  AnimatedRotation(
                    turns: _isExpanded ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.expand_less,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tasks list with animated expansion
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    children: [
                      // Incomplete items
                      if (widget.incompleteItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 12, bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                'Pending',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.incompleteItems.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...widget.incompleteItems
                            .map((doc) => _buildItemCard(doc)),
                      ],

                      // Completed items
                      if (widget.completedItems.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 12, bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.completedItems.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...widget.completedItems
                            .map((doc) => _buildItemCard(doc)),
                      ],

                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class ItemsScreenWithFAB extends StatelessWidget {
  final String listId;
  final String listName;

  const ItemsScreenWithFAB({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ItemsTab(listId: listId, listName: listName),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateItemScreen(listId: listId),
            ),
          );
        },
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
