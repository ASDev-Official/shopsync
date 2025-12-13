import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '/widgets/lists/place_selector.dart';
import '/widgets/lists/category_picker.dart';
import '/widgets/ui/loading_spinner.dart';
import '/utils/icons/food_icons_map.dart';
import '/screens/lists/choose_item_icon.dart';
import '/utils/permissions.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String listId;
  final String itemId;

  const ItemDetailsScreen({
    super.key,
    required this.listId,
    required this.itemId,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dotSize = 2.0;
    final spacingSize = 2.0;
    var currentX = 0.0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dotSize, 0),
        paint,
      );
      currentX += dotSize + spacingSize;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  DateTime? _selectedDeadline;

  // String? _priority;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateItem(Map<String, dynamic> data) async {
    await _firestore
        .collection('lists')
        .doc(widget.listId)
        .collection('items')
        .doc(widget.itemId)
        .update(data);
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: Colors.green[800]!,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                    surface: Colors.grey[900]!,
                  )
                : ColorScheme.light(
                    primary: Colors.green[800]!,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: isDark
                  ? ColorScheme.dark(
                      primary: Colors.green[800]!,
                      onPrimary: Colors.white,
                      onSurface: Colors.white,
                      surface: Colors.grey[900]!,
                    )
                  : ColorScheme.light(
                      primary: Colors.green[800]!,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        final deadline = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        await _updateItem({'deadline': deadline});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Item Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('lists')
            .doc(widget.listId)
            .collection('items')
            .doc(widget.itemId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CustomLoadingSpinner(
                color: Colors.green,
                size: 60.0,
              ),
            );
          }

          final item = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final name = item['name'] ?? 'Untitled Item';
          final description = item['description'] ?? '';
          final addedByName = item['addedByName'] ?? 'Unknown';
          final addedAt = item['addedAt'].toDate();
          final completed = item['completed'] ?? false;
          _descriptionController.text = description;
          _selectedDeadline = item['deadline']?.toDate();
          _nameController.text = name;

          return SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Large icon display
                        FutureBuilder<bool>(
                          future: PermissionsHelper.isViewer(widget.listId),
                          builder: (context, snapshot) {
                            final isViewer =
                                snapshot.hasData && snapshot.data == true;

                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: isViewer
                                      ? null
                                      : () => _navigateToIconSelector(item),
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: _buildItemIcon(item),
                                  ),
                                ),
                                if (!isViewer)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _navigateToIconSelector(item),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.green[800],
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 11,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        // Item name field
                        Expanded(
                          child: FutureBuilder<bool>(
                            future: PermissionsHelper.isViewer(widget.listId),
                            builder: (context, snapshot) {
                              final isViewer =
                                  snapshot.hasData && snapshot.data == true;

                              return Stack(
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    enabled: !isViewer,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(bottom: 8),
                                    ),
                                    onSubmitted: isViewer
                                        ? null
                                        : (value) {
                                            if (value.trim().isNotEmpty) {
                                              _updateItem(
                                                  {'name': value.trim()});
                                            }
                                          },
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: CustomPaint(
                                      painter: DottedLinePainter(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[600]!
                                            : Colors.grey[300]!,
                                      ),
                                      size: Size(
                                          MediaQuery.of(context).size.width, 1),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildStatusCard(completed),
                    const SizedBox(height: 16),
                    _buildCategoryCard(item),
                    const SizedBox(height: 16),
                    _buildDeadlineCard(),
                    const SizedBox(height: 16),
                    _buildLocationCard(item),
                    const SizedBox(height: 16),
                    _buildCounterCard(item),
                    const SizedBox(height: 16),
                    _buildDescriptionCard(),
                    const SizedBox(height: 16),
                    _buildAddedByCard(addedByName),
                    const SizedBox(height: 16),
                    _buildAddedAtCard(addedAt),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(bool completed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: completed
                ? [Colors.green[400]!, Colors.green[600]!]
                : isDark
                    ? [Colors.grey[800]!, Colors.grey[700]!]
                    : [Colors.grey[100]!, Colors.grey[200]!],
          ),
        ),
        child: ListTile(
          title: Text(
            'Status',
            style: TextStyle(
              color: completed
                  ? Colors.white
                  : isDark
                      ? Colors.white
                      : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: FutureBuilder<bool>(
            future: PermissionsHelper.isViewer(widget.listId),
            builder: (context, snapshot) {
              final isViewer = snapshot.hasData && snapshot.data == true;

              return Switch.adaptive(
                value: completed,
                onChanged: isViewer
                    ? null
                    : (value) => _updateItem({'completed': value}),
                // ignore: deprecated_member_use
                activeColor: Colors.white,
                activeTrackColor: Colors.green[800],
                inactiveThumbColor: isDark ? Colors.grey[300] : Colors.grey[50],
                inactiveTrackColor:
                    isDark ? Colors.grey[600] : Colors.grey[300],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> item) {
    final categoryId = item['categoryId'] as String?;

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: FutureBuilder<bool>(
        future: PermissionsHelper.isViewer(widget.listId),
        builder: (context, snapshot) {
          final isViewer = snapshot.hasData && snapshot.data == true;

          return StreamBuilder<DocumentSnapshot>(
            stream: categoryId != null
                ? _firestore
                    .collection('lists')
                    .doc(widget.listId)
                    .collection('categories')
                    .doc(categoryId)
                    .snapshots()
                : null,
            builder: (context, categorySnapshot) {
              Map<String, dynamic>? categoryData;
              if (categorySnapshot.hasData && categorySnapshot.data!.exists) {
                categoryData =
                    categorySnapshot.data!.data() as Map<String, dynamic>;
              }

              return InkWell(
                onTap: isViewer
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CategoryPicker(
                            listId: widget.listId,
                            selectedCategoryId: categoryId,
                            onCategorySelected: (newCategoryId, categoryName) {
                              if (newCategoryId == null) {
                                _updateItem({
                                  'categoryId': FieldValue.delete(),
                                  'categoryName': FieldValue.delete(),
                                });
                              } else {
                                _updateItem({
                                  'categoryId': newCategoryId,
                                  'categoryName': categoryName,
                                });
                              }
                            },
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: categoryData != null
                              ? Colors.green[100]
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: categoryData != null
                            ? () {
                                final iconIdentifier =
                                    categoryData!['iconIdentifier'] as String?;
                                final categoryIcon = iconIdentifier != null
                                    ? FoodIconMap.getIcon(iconIdentifier)
                                    : null;

                                return categoryIcon != null
                                    ? categoryIcon.buildIcon(
                                        width: 24,
                                        height: 24,
                                        color: Colors.green[800],
                                      )
                                    : Icon(Icons.label,
                                        color: Colors.green[800]);
                              }()
                            : Icon(Icons.label, color: Colors.green[800]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categoryData != null
                                  ? categoryData['name'] ?? 'Unnamed Category'
                                  : 'No category',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildItemIcon(Map<String, dynamic> item) {
    final iconIdentifier = item['iconIdentifier'] as String?;
    final selectedIcon =
        iconIdentifier != null ? FoodIconMap.getIcon(iconIdentifier) : null;

    if (selectedIcon != null) {
      return selectedIcon.buildIcon(
        width: 32,
        height: 32,
        color: Colors.green[800],
      );
    } else {
      return Icon(
        Icons.check,
        color: Colors.green[800],
        size: 28,
      );
    }
  }

  Future<void> _navigateToIconSelector(Map<String, dynamic> item) async {
    final iconIdentifier = item['iconIdentifier'] as String?;
    final selectedIcon =
        iconIdentifier != null ? FoodIconMap.getIcon(iconIdentifier) : null;

    final result = await Navigator.push<FoodIconMapping>(
      context,
      MaterialPageRoute(
        builder: (context) => ChooseItemIconScreen(
          selectedIcon: selectedIcon,
        ),
      ),
    );
    if (result != null) {
      await _updateItem({'iconIdentifier': result.identifier});
    } else if (selectedIcon != null) {
      // User can clear the icon by returning null
      await _updateItem({'iconIdentifier': FieldValue.delete()});
    }
  }

  Widget _buildDeadlineCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: FutureBuilder<bool>(
        future: PermissionsHelper.isViewer(widget.listId),
        builder: (context, snapshot) {
          final isViewer = snapshot.hasData && snapshot.data == true;

          return InkWell(
            onTap: isViewer ? null : _selectDeadline,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.calendar_today, color: Colors.green[800]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deadline',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedDeadline != null
                              ? DateFormat('MMM dd, yyyy - hh:mm a')
                                  .format(_selectedDeadline!)
                              : 'Set deadline',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedDeadline != null && !isViewer)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          _updateItem({'deadline': FieldValue.delete()}),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> item) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: FutureBuilder<bool>(
        future: PermissionsHelper.isViewer(widget.listId),
        builder: (context, snapshot) {
          final isViewer = snapshot.hasData && snapshot.data == true;

          return InkWell(
            onTap: isViewer
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => LocationSelector(
                        initialLocation: item['location'],
                        onLocationSelected: (location) {
                          if (location.isEmpty) {
                            _updateItem({'location': FieldValue.delete()});
                          } else {
                            _updateItem({'location': location});
                          }
                        },
                      ),
                    );
                  },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on, color: Colors.green[800]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['location'] != null
                              ? '${item['location']['name']}\n${item['location']['address']}'
                              : 'Set location',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description, color: Colors.green[800]),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: PermissionsHelper.isViewer(widget.listId),
              builder: (context, snapshot) {
                final isViewer = snapshot.hasData && snapshot.data == true;

                return TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  enabled: !isViewer,
                  decoration: InputDecoration(
                    hintText: 'Add description...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.green[800]!, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.green[200]!),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: isViewer
                        ? Colors.grey[200]
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.grey[50],
                  ),
                  onChanged: isViewer
                      ? null
                      : (value) => _updateItem({'description': value}),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddedByCard(String addedByName) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person, color: Colors.green[800]),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Added by',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  addedByName,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddedAtCard(DateTime addedAt) {
    final formattedAddedAt =
        DateFormat('MMM dd, yyyy - hh:mm a').format(addedAt);

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.access_time, color: Colors.green[800]),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Added at',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedAddedAt,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard(Map<String, dynamic> item) {
    final counter = item['counter'] ?? 1;

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.tag, color: Colors.green[800]),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Counter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: PermissionsHelper.isViewer(widget.listId),
              builder: (context, snapshot) {
                final isViewer = snapshot.hasData && snapshot.data == true;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: !isViewer && counter > 1
                          ? () => _updateItem({'counter': counter - 1})
                          : null,
                      icon: Icon(
                        Icons.remove,
                        color: (!isViewer && counter > 1)
                            ? Colors.green[800]
                            : Colors.grey[400],
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: (!isViewer && counter > 1)
                            ? Colors.green[100]
                            : Colors.grey[200],
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green[200]!,
                        ),
                      ),
                      child: Text(
                        '$counter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: !isViewer && counter < 99
                          ? () => _updateItem({'counter': counter + 1})
                          : null,
                      icon: Icon(
                        Icons.add,
                        color: (!isViewer && counter < 99)
                            ? Colors.green[800]
                            : Colors.grey[400],
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: (!isViewer && counter < 99)
                            ? Colors.green[100]
                            : Colors.grey[200],
                        shape: const CircleBorder(),
                      ),
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
}
