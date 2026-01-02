import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import '/services/data/item_categories_service.dart';
import '/widgets/ui/loading_spinner.dart';
import '/utils/icons/food_icons_map.dart';
import '/screens/lists/choose_item_icon.dart';

class ManageCategoriesScreen extends StatefulWidget {
  final String listId;

  const ManageCategoriesScreen({super.key, required this.listId});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _nameController = TextEditingController();
  FoodIconMapping? _selectedIcon;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterACategoryName),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red[800],
        ),
      );
      return;
    }

    try {
      await CategoriesService.createCategory(
        listId: widget.listId,
        name: _nameController.text.trim(),
        iconIdentifier: _selectedIcon?.identifier,
      );

      _nameController.clear();
      setState(() {
        _selectedIcon = null;
      });

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.categoryCreatedSuccessfully),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green[800],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorCreatingCategoryE(e.toString())),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red[800],
        ),
      );
    }
  }

  Future<void> _editCategory(
      String categoryId, Map<String, dynamic> category) async {
    final nameController = TextEditingController(text: category['name']);
    final iconIdentifier = category['iconIdentifier'] as String?;
    FoodIconMapping? selectedIcon =
        iconIdentifier != null ? FoodIconMap.getIcon(iconIdentifier) : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final l10n = AppLocalizations.of(context)!;

            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(l10n.editCategory),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Icon',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final result = await Navigator.push<FoodIconMapping>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChooseItemIconScreen(
                              selectedIcon: selectedIcon,
                            ),
                          ),
                        );
                        if (result != null) {
                          setDialogState(() {
                            selectedIcon = result;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: selectedIcon != null
                                  ? selectedIcon!.buildIcon(
                                      width: 24,
                                      height: 24,
                                      color: Colors.green[800],
                                    )
                                  : Icon(
                                      Icons.category,
                                      color: Colors.green[800],
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                selectedIcon?.displayName ?? 'Choose an icon',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.pleaseEnterACategoryName),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red[800],
                        ),
                      );
                      return;
                    }

                    await CategoriesService.updateCategory(
                      listId: widget.listId,
                      categoryId: categoryId,
                      data: {
                        'name': nameController.text.trim(),
                        'iconIdentifier': selectedIcon?.identifier,
                      },
                    );

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.categoryUpdatedSuccessfully),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green[800],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(String categoryId, String categoryName) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(
          'Are you sure you want to delete "$categoryName"? This will remove the category from all items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CategoriesService.deleteCategory(widget.listId, categoryId);
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.categoryDeletedSuccessfully),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green[800],
          ),
        );
      } catch (e) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingCategoryE(e.toString())),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[800],
          ),
        );
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
          'Manage Categories',
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
      body: Column(
        children: [
          // Create Category Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.label,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Icon Selector
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push<FoodIconMapping>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChooseItemIconScreen(
                          selectedIcon: _selectedIcon,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _selectedIcon = result;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedIcon != null
                              ? _selectedIcon!.buildIcon(
                                  width: 24,
                                  height: 24,
                                  color: Colors.green[800],
                                )
                              : Icon(
                                  Icons.category,
                                  color: Colors.green[800],
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Icon',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedIcon?.displayName ?? 'Choose an icon',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _createCategory,
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.createCategory),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: CategoriesService.getListCategories(widget.listId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CustomLoadingSpinner(
                      color: Colors.green,
                      size: 60.0,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first category above',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final category = doc.data() as Map<String, dynamic>;
                    final categoryName = category['name'] ?? 'Unnamed';
                    final iconIdentifier =
                        category['iconIdentifier'] as String?;
                    final categoryIcon = iconIdentifier != null
                        ? FoodIconMap.getIcon(iconIdentifier)
                        : null;

                    return Card(
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
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
                                ),
                        ),
                        title: Text(
                          categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                              ),
                              onPressed: () => _editCategory(doc.id, category),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.red[800],
                              ),
                              onPressed: () =>
                                  _deleteCategory(doc.id, categoryName),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
