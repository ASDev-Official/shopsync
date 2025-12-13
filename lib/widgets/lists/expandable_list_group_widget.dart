import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import '/services/data/list_groups_service.dart';
import '/screens/lists/list_view.dart';
import '/widgets/lists/manage_list_group_bottom_sheet.dart';

class ListItemWidget extends StatefulWidget {
  final DocumentSnapshot listDoc;

  const ListItemWidget({
    super.key,
    required this.listDoc,
  });

  @override
  State<ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  bool _isNavigating = false;

  void _navigateToList() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    final data = widget.listDoc.data() as Map<String, dynamic>;
    final listName = data['name'] ?? 'Unnamed List';

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ListViewScreen(
            listId: widget.listDoc.id,
            listName: listName,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = widget.listDoc.data() as Map<String, dynamic>;
    final listName = data['name'] ?? 'Unnamed List';
    final timestamp = data['createdAt'] as Timestamp?;
    final createdAt = timestamp != null
        ? DateFormat('MMM dd, yyyy').format(timestamp.toDate())
        : 'Unknown date';

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey[850]!, Colors.grey[800]!]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isNavigating ? null : _navigateToList,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.green[900] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    color: isDark ? Colors.green[200] : Colors.green[700],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            createdAt,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _isNavigating
                      ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CustomLoadingSpinner(),
                        )
                      : Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandableListGroupWidget extends StatefulWidget {
  final DocumentSnapshot groupDoc;
  final Function(String groupId, List<String> groupIds)? onReorder;

  const ExpandableListGroupWidget({
    super.key,
    required this.groupDoc,
    this.onReorder,
  });

  @override
  State<ExpandableListGroupWidget> createState() =>
      _ExpandableListGroupWidgetState();
}

class _ExpandableListGroupWidgetState extends State<ExpandableListGroupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _heightAnimation;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    final data = widget.groupDoc.data() as Map<String, dynamic>;
    _isExpanded = data['isExpanded'] ?? true;

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() async {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    // Update in database
    await ListGroupsService.toggleGroupExpansion(
        widget.groupDoc.id, _isExpanded);
  }

  void _showManageGroup() {
    final data = widget.groupDoc.data() as Map<String, dynamic>;
    final groupName = data['name'] ?? 'Unnamed Group';
    final listIds = List<String>.from(data['listIds'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManageListGroupBottomSheet(
        groupId: widget.groupDoc.id,
        groupName: groupName,
        currentListIds: listIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = widget.groupDoc.data() as Map<String, dynamic>;
    final groupName = data['name'] ?? 'Unnamed Group';
    final listIds = List<String>.from(data['listIds'] ?? []);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          // Group header
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              onTap: () {
                _toggleExpansion();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Expansion icon
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 3.14159,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.green[900] : Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.expand_more,
                              color: isDark
                                  ? Colors.green[200]
                                  : Colors.green[700],
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),

                    // Group info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${listIds.length} list${listIds.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Manage button
                    IconButton(
                      onPressed: _showManageGroup,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.more_vert,
                          size: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _heightAnimation,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                const SizedBox(height: 12),

                // Lists in group
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: ListGroupsService.getListsInGroup(widget.groupDoc.id),
                  builder: (context, snapshot) {
                    // Prevent rebuilds during navigation
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        child: const Center(
                          child: CustomLoadingSpinner(),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No lists in this group',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the menu to add lists',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final lists = snapshot.data!;

                    return RepaintBoundary(
                      child: Column(
                        children: [
                          ...lists.map((listDoc) => RepaintBoundary(
                                key: ValueKey(listDoc.id),
                                child: ListItemWidget(
                                  listDoc: listDoc,
                                ),
                              )),
                          const SizedBox(height: 12),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
