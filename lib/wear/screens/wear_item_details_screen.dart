import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wear_plus/wear_plus.dart';
import 'package:rotary_scrollbar/widgets/rotary_scrollbar.dart';
import 'package:intl/intl.dart';

class WearItemDetailsScreen extends StatefulWidget {
  final String listId;
  final String itemId;

  const WearItemDetailsScreen({
    super.key,
    required this.listId,
    required this.itemId,
  });

  @override
  State<WearItemDetailsScreen> createState() => _WearItemDetailsScreenState();
}

class _WearItemDetailsScreenState extends State<WearItemDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleCompleted(bool currentValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .doc(widget.itemId)
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
            duration: const Duration(seconds: 2),
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
              body: _buildItemDetails(mode, shape),
            );
          },
        );
      },
    );
  }

  Widget _buildItemDetails(WearMode mode, WearShape shape) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .doc(widget.listId)
          .collection('items')
          .doc(widget.itemId)
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

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text(
              'Item not found',
              style: TextStyle(
                color:
                    mode == WearMode.active ? Colors.white70 : Colors.white54,
                fontSize: 12,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unnamed Item';
        final description = data['description'] ?? '';
        final completed = data['completed'] == true;
        final quantity = data['counter'] ?? 1;
        final categoryName = data['categoryName'] as String?;
        final location = data['location'] as Map<String, dynamic>?;
        final deadline = data['deadline'] as Timestamp?;
        final addedByName = data['addedByName'] ?? 'Unknown';
        final addedAt = data['addedAt'] as Timestamp?;

        return RotaryScrollbar(
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header with back button
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: shape == WearShape.round ? 32.0 : 16.0,
                    right: shape == WearShape.round ? 32.0 : 16.0,
                    top: shape == WearShape.round ? 24.0 : 16.0,
                    bottom: 8.0,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Back',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Item name and status
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: shape == WearShape.round ? 28.0 : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: mode == WearMode.active
                              ? Colors.white
                              : Colors.white70,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Status toggle
                      GestureDetector(
                        onTap: () => _toggleCompleted(completed),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: completed
                                ? Colors.green[800]
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                completed
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                completed ? 'Completed' : 'Not Completed',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Details sections
              SliverPadding(
                padding: EdgeInsets.only(
                  left: shape == WearShape.round ? 32.0 : 12.0,
                  right: shape == WearShape.round ? 32.0 : 12.0,
                  top: 16.0,
                  bottom: 20.0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quantity
                    if (quantity > 1)
                      _buildDetailCard(
                        mode,
                        'Quantity',
                        quantity.toString(),
                        Icons.numbers,
                      ),

                    // Category
                    if (categoryName != null && categoryName.isNotEmpty)
                      _buildDetailCard(
                        mode,
                        'Category',
                        categoryName,
                        Icons.category,
                      ),

                    // Location
                    if (location != null)
                      _buildDetailCard(
                        mode,
                        'Location',
                        location['name'] ?? 'Unknown location',
                        Icons.location_on,
                      ),

                    // Deadline
                    if (deadline != null)
                      _buildDetailCard(
                        mode,
                        'Deadline',
                        DateFormat('MMM d, y h:mm a').format(deadline.toDate()),
                        Icons.alarm,
                      ),

                    // Description
                    if (description.isNotEmpty)
                      _buildDetailCard(
                        mode,
                        'Description',
                        description,
                        Icons.description,
                        isMultiline: true,
                      ),

                    // Added by
                    _buildDetailCard(
                      mode,
                      'Added by',
                      addedByName,
                      Icons.person,
                    ),

                    // Added at
                    if (addedAt != null)
                      _buildDetailCard(
                        mode,
                        'Added on',
                        DateFormat('MMM d, y h:mm a').format(addedAt.toDate()),
                        Icons.access_time,
                      ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(
    WearMode mode,
    String label,
    String value,
    IconData icon, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: mode == WearMode.active ? Colors.grey[900] : Colors.grey[850],
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: isMultiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    mode == WearMode.active ? Colors.white54 : Colors.white38,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: mode == WearMode.active
                            ? Colors.white54
                            : Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 11,
                        color: mode == WearMode.active
                            ? Colors.white
                            : Colors.white70,
                      ),
                      maxLines: isMultiline ? null : 2,
                      overflow: isMultiline
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
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
