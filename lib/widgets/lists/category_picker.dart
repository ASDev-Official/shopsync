import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/data/item_categories_service.dart';
import '/widgets/ui/loading_spinner.dart';
import '/utils/icons/food_icons_map.dart';

class CategoryPicker extends StatefulWidget {
  final String listId;
  final String? selectedCategoryId;
  final Function(String? categoryId, String? categoryName) onCategorySelected;

  const CategoryPicker({
    super.key,
    required this.listId,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // No Category Option
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.block,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            title: const Text('No Category'),
            trailing: _selectedCategoryId == null
                ? Icon(
                    Icons.check,
                    color: Colors.green[800],
                  )
                : null,
            onTap: () {
              setState(() {
                _selectedCategoryId = null;
              });
              widget.onCategorySelected(null, null);
              Navigator.pop(context);
            },
          ),

          const Divider(),

          // Categories List
          StreamBuilder<QuerySnapshot>(
            stream: CategoriesService.getListCategories(widget.listId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CustomLoadingSpinner(
                    color: Colors.green,
                    size: 40.0,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text('No categories available'),
                  ),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final category = doc.data() as Map<String, dynamic>;
                  final categoryName = category['name'] ?? 'Unnamed Category';
                  final iconIdentifier = category['iconIdentifier'] as String?;
                  final categoryIcon = iconIdentifier != null
                      ? FoodIconMap.getIcon(iconIdentifier)
                      : null;
                  final isSelected = _selectedCategoryId == doc.id;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: categoryIcon != null
                          ? categoryIcon.buildIcon(
                              width: 20,
                              height: 20,
                              color: Colors.green[800],
                            )
                          : Icon(
                              Icons.label,
                              color: Colors.green[800],
                              size: 20,
                            ),
                    ),
                    title: Text(categoryName),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.green[800],
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = doc.id;
                      });
                      widget.onCategorySelected(doc.id, categoryName);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 16),

          // Manage Categories Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/manage-categories',
                  arguments: widget.listId,
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Manage Categories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
