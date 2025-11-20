import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '/widgets/loading_spinner.dart';
import '/utils/permissions.dart';
import '/libraries/icons/food_icons_map.dart';

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 16);

    path.quadraticBezierTo(
      size.width / 4,
      size.height,
      size.width / 2,
      size.height,
    );

    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height,
      size.width,
      size.height - 16,
    );

    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RecycleBinScreen extends StatefulWidget {
  final String listId;

  const RecycleBinScreen({super.key, required this.listId});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen>
    with TickerProviderStateMixin {
  // Changed from SingleTickerProviderStateMixin
  late AnimationController _controller;
  final Map<String, AnimationController> _itemControllers = {};
  final Map<String, Animation<double>> _itemAnimations = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final controller in _itemControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _restoreItem(
      String itemId, Map<String, dynamic> itemData) async {
    try {
      await _itemControllers[itemId]?.reverse();

      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance
            .collection('lists')
            .doc(widget.listId)
            .collection('items')
            .doc(),
        {...itemData, 'restoredAt': FieldValue.serverTimestamp()},
      );
      batch.delete(
        FirebaseFirestore.instance
            .collection('lists')
            .doc(widget.listId)
            .collection('recycled_items')
            .doc(itemId),
      );
      await batch.commit();
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'message': 'Failed to restore item from recycle bin',
          'listId': widget.listId,
          'itemId': itemId,
        }),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to restore item')),
      );
    }
  }

  Future<void> _deletePermanently(String itemId) async {
    try {
      await _itemControllers[itemId]?.reverse();
      await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('recycled_items')
          .doc(itemId)
          .delete();
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'message': 'Failed to permanently delete item',
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

  Widget _buildStatsCard(QuerySnapshot recycleBinSnapshot) {
    final totalItems = recycleBinSnapshot.docs.length;
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
          // Trash icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.red[900] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.delete_outline,
                size: 28,
                color: Colors.red[700],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Stats text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recycle Bin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '$totalItems ${totalItems == 1 ? 'item' : 'items'} in recycle bin',
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

  Widget _buildItemCard(DocumentSnapshot doc, Map<String, dynamic> itemData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deadline = itemData['deadline'] as Timestamp?;
    final location = itemData['location'] as Map<String, dynamic>?;
    final counter = itemData['counter'] ?? 1;
    final iconIdentifier = itemData['iconIdentifier'] as String?;
    final itemIcon =
        iconIdentifier != null ? FoodIconMap.getIcon(iconIdentifier) : null;
    final deletedAt = itemData['deletedAt'] as Timestamp?;
    final deletedByName = itemData['deletedByName'] ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[850] : Colors.grey[100],
        ),
        child: Row(
          children: [
            // Item Icon
            if (itemIcon != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                child: itemIcon.buildIcon(
                  width: 28,
                  height: 28,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                          itemData['name'] ?? 'Unnamed Item',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
                            decorationColor:
                                isDark ? Colors.white38 : Colors.black38,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                      if (counter > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.blue[900] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x$counter',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.blue[200] : Colors.blue[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (itemData['description'] != null &&
                      itemData['description'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        itemData['description'],
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
                      // Deleted by tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person,
                                size: 10, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              deletedByName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Deleted at tag
                      if (deletedAt != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time,
                                  size: 10, color: Colors.red[800]),
                              const SizedBox(width: 4),
                              Text(
                                'Deleted ${DateFormat('MMM dd, yyyy').format(deletedAt.toDate())}',
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
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

            // Action buttons
            FutureBuilder<bool>(
              future: PermissionsHelper.isViewer(widget.listId),
              builder: (context, permissionSnapshot) {
                if (permissionSnapshot.hasData &&
                    permissionSnapshot.data == true) {
                  return const SizedBox.shrink();
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _restoreItem(doc.id, itemData),
                      icon: Icon(
                        Icons.restore,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      tooltip: 'Restore item',
                    ),
                    IconButton(
                      onPressed: () => _deletePermanently(doc.id),
                      icon: Icon(
                        Icons.delete,
                        size: 16,
                        color: Colors.red[400],
                      ),
                      tooltip: 'Delete permanently',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    PreferredSize buildCustomAppBar(BuildContext context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Recycle Bin",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: buildCustomAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lists')
            .doc(widget.listId)
            .collection('recycled_items')
            .orderBy('deletedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CustomLoadingSpinner(color: Colors.green, size: 60.0),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 48,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Deleted Items',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Items you delete will appear here for 30 days',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            children: [
              // Statistics Card
              _buildStatsCard(snapshot.data!),

              // Recycled Items List
              ...snapshot.data!.docs.map((doc) {
                final itemData = doc.data() as Map<String, dynamic>;

                if (!_itemControllers.containsKey(doc.id)) {
                  _itemControllers[doc.id] = AnimationController(
                    duration: const Duration(milliseconds: 300),
                    vsync: this,
                  )..forward();

                  _itemAnimations[doc.id] = _itemControllers[doc.id]!.drive(
                    Tween<double>(begin: 0, end: 1),
                  );
                }

                return AnimatedBuilder(
                  animation: _itemAnimations[doc.id]!,
                  builder: (context, child) => FadeTransition(
                    opacity: _itemAnimations[doc.id]!,
                    child: SizeTransition(
                      sizeFactor: _itemAnimations[doc.id]!,
                      child: _buildItemCard(doc, itemData),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
