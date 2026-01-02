import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import '/services/migration/migration_service.dart';
import 'package:shopsync/l10n/app_localizations.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  List<QueryDocumentSnapshot> _userLists = [];
  List<MigrationGroup> _suggestedGroups = [];
  bool _isLoading = true;
  bool _isMigrating = false;
  bool _showCustomGroupForm = false;
  final TextEditingController _customGroupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _customGroupController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lists = await MigrationService.getUserLists();
      final suggestedGroups = MigrationService.suggestGroups(lists);

      setState(() {
        _userLists = lists;
        _suggestedGroups = suggestedGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCustomGroup() {
    if (_customGroupController.text.trim().isEmpty) return;

    setState(() {
      _suggestedGroups.add(MigrationGroup(
        name: _customGroupController.text.trim(),
        lists: [],
        isCustom: true,
        isSelected: true,
      ));
      _customGroupController.clear();
      _showCustomGroupForm = false;
    });
  }

  void _toggleGroupSelection(int index) {
    setState(() {
      _suggestedGroups[index] = _suggestedGroups[index].copyWith(
        isSelected: !_suggestedGroups[index].isSelected,
      );
    });
  }

  void _editGroupName(int index) {
    final controller =
        TextEditingController(text: _suggestedGroups[index].name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editGroupName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter group name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _suggestedGroups[index] = _suggestedGroups[index].copyWith(
                    name: controller.text.trim(),
                  );
                });
              }
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _moveListToGroup(
      QueryDocumentSnapshot list, int fromGroupIndex, int toGroupIndex) {
    setState(() {
      // Remove from current group
      if (fromGroupIndex >= 0) {
        _suggestedGroups[fromGroupIndex] =
            _suggestedGroups[fromGroupIndex].copyWith(
          lists: List.from(_suggestedGroups[fromGroupIndex].lists)
            ..remove(list),
        );
      }

      // Add to new group
      if (toGroupIndex >= 0) {
        _suggestedGroups[toGroupIndex] =
            _suggestedGroups[toGroupIndex].copyWith(
          lists: List.from(_suggestedGroups[toGroupIndex].lists)..add(list),
        );
      }
    });
  }

  Future<void> _executeMigration() async {
    setState(() {
      _isMigrating = true;
    });

    final selectedGroups = _suggestedGroups
        .where((group) => group.isSelected && group.lists.isNotEmpty)
        .toList();

    final success = await MigrationService.executeMigration(selectedGroups);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!
              .successfullyOrganizedSelectedgroupslengthGroups(
                  selectedGroups.length.toString())),
          backgroundColor: Colors.green[800],
        ),
      );
    } else {
      setState(() {
        _isMigrating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.failedToMigrateListsPleaseTryAgain),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _skipMigration() async {
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.skipOrganization),
        content: const Text(
          'You can organize your lists into groups later from the home screen. Continue without organizing?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(AppLocalizations.of(context)!.skipForNow),
          ),
        ],
      ),
    );

    if (shouldSkip == true) {
      await MigrationService.skipMigration();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // Get lists that are currently not assigned to any group
  List<QueryDocumentSnapshot> get _ungroupedLists {
    final Set<String> groupedListIds = {};

    // Collect all list IDs that are in groups
    for (final group in _suggestedGroups) {
      if (group.isSelected) {
        for (final list in group.lists) {
          groupedListIds.add(list.id);
        }
      }
    }

    // Return lists that are not in any group
    return _userLists
        .where((list) => !groupedListIds.contains(list.id))
        .toList();
  }

  Widget _buildListItem(QueryDocumentSnapshot listDoc, int groupIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = listDoc.data() as Map<String, dynamic>;
    final listName = data['name'] ?? 'Unnamed List';
    final timestamp = data['createdAt'] as Timestamp?;
    final createdAt = timestamp != null
        ? DateFormat('MMM dd').format(timestamp.toDate())
        : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.shopping_cart,
            color: Colors.blue[700],
            size: 14,
          ),
        ),
        title: Text(
          listName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Created $createdAt',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert, size: 16),
          onSelected: (newGroupIndex) {
            if (newGroupIndex == -1) {
              // Remove from group (leave ungrouped)
              _moveListToGroup(listDoc, groupIndex, -1);
            } else {
              _moveListToGroup(listDoc, groupIndex, newGroupIndex);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: -1,
              child: Text(AppLocalizations.of(context)!.leaveUngrouped),
            ),
            ..._suggestedGroups
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final group = entry.value;
                  if (index == groupIndex) return null;

                  return PopupMenuItem(
                    value: index,
                    child: Text('Move to ${group.name}'),
                  );
                })
                .where((item) => item != null)
                .cast<PopupMenuItem<int>>(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(MigrationGroup group, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          color: group.isSelected
              ? Colors.green[600]!
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: group.isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Group header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Checkbox(
                  value: group.isSelected,
                  onChanged: (value) => _toggleGroupSelection(index),
                  activeColor: Colors.green[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      Text(
                        '${group.lists.length} list${group.lists.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!group.isCustom)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Suggested',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editGroupName(index),
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),

          // Lists in group
          if (group.lists.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: group.lists.map((list) {
                  return _buildListItem(list, index);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUngroupedListsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ungroupedLists = _ungroupedLists;

    if (ungroupedLists.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.orange[900]!.withAlpha(76),
                  Colors.orange[800]!.withAlpha(51)
                ]
              : [Colors.orange[50]!, Colors.orange[25]!],
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
          color:
              isDark ? Colors.orange[800]!.withAlpha(127) : Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.orange[800] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.list,
                    color: isDark ? Colors.orange[200] : Colors.orange[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ungrouped Lists',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.orange[200] : Colors.orange[900],
                        ),
                      ),
                      Text(
                        '${ungroupedLists.length} list${ungroupedLists.length != 1 ? 's' : ''} not assigned to any group',
                        style: TextStyle(
                          color:
                              isDark ? Colors.orange[300] : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ungrouped lists
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drag these lists to a group above or create a new group for them:',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.orange[300] : Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                ...ungroupedLists.map((list) {
                  return _buildListItem(
                      list, -1); // Use -1 to indicate ungrouped
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'ShopSync Migration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CustomLoadingSpinner())
          : Column(
              children: [
                // Header info
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.green[900] : Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.layers,
                          size: 32,
                          color: isDark ? Colors.green[200] : Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Organize with List Groups',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ve suggested some groups for your ${_userLists.length} lists. You can edit, remove, or add new groups.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Groups list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      ..._suggestedGroups.asMap().entries.map((entry) {
                        final index = entry.key;
                        final group = entry.value;
                        return _buildGroupCard(group, index);
                      }),

                      // Ungrouped Lists Section
                      if (_ungroupedLists.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildUngroupedListsSection(),
                      ],

                      // Add custom group
                      if (_showCustomGroupForm)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[200]!,
                            ),
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _customGroupController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: 'Enter group name',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addCustomGroup(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showCustomGroupForm = false;
                                        _customGroupController.clear();
                                      });
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.cancel),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _addCustomGroup,
                                    child: Text(
                                        AppLocalizations.of(context)!.addGroup),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showCustomGroupForm = true;
                              });
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: Text(
                                AppLocalizations.of(context)!.addCustomGroup),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[400]!,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: _isMigrating ? null : _skipMigration,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Skip for Now',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isMigrating ? null : _executeMigration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: _isMigrating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CustomLoadingSpinner(),
                      )
                    : const Text(
                        'Organize Lists',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
