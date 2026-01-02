import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shopsync/widgets/ui/loading_spinner.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import '/services/data/list_groups_service.dart';

class AddListGroupBottomSheet extends StatefulWidget {
  const AddListGroupBottomSheet({super.key});

  @override
  State<AddListGroupBottomSheet> createState() =>
      _AddListGroupBottomSheetState();
}

class _AddListGroupBottomSheetState extends State<AddListGroupBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterAGroupName),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final groupId =
        await ListGroupsService.createListGroup(_nameController.text.trim());

    if (!mounted) return;

    if (groupId != null) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Group "${_nameController.text.trim()}" created successfully'),
          backgroundColor: Colors.green[800],
        ),
      );
    } else {
      setState(() {
        _isCreating = false;
      });
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToCreateGroupPleaseTryAgain),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.green[900] : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.layers,
                    color: isDark ? Colors.green[200] : Colors.green[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create List Group',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Organize your lists into groups',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Name input
            Text(
              'Group Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              enabled: !_isCreating,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Grocery Lists, Work Projects',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.green[600]!,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => _createGroup(),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ButtonM3E(
                    onPressed:
                        _isCreating ? null : () => Navigator.pop(context),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ButtonM3EStyle.text,
                    size: ButtonM3ESize.lg,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ButtonM3E(
                    onPressed: _isCreating ? null : _createGroup,
                    label: _isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CustomLoadingSpinner(),
                          )
                        : const Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    style: ButtonM3EStyle.filled,
                    size: ButtonM3ESize.lg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
