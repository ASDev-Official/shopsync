import 'package:flutter/material.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import 'package:shopsync/services/data/completed_items_service.dart';

enum ClearCompletedMode {
  all,
  uncategorizedOnly,
  selectedCategories,
}

class ClearCompletedSelection {
  final ClearCompletedMode mode;
  final Set<String> selectedCategoryIds;

  const ClearCompletedSelection({
    required this.mode,
    required this.selectedCategoryIds,
  });
}

Future<ClearCompletedSelection?> showClearCompletedDialog({
  required BuildContext context,
  required String listId,
}) async {
  final buckets =
      await CompletedItemsService.getCompletedCategoryBuckets(listId);
  final listCategories = await CompletedItemsService.getListCategories(listId);

  if (!context.mounted) {
    return null;
  }

  final l10n = AppLocalizations.of(context)!;

  final uncategorizedCount = buckets
      .where((bucket) => bucket.categoryId == null)
      .fold<int>(0, (sum, bucket) => sum + bucket.completedCount);
  final totalCount =
      buckets.fold<int>(0, (sum, bucket) => sum + bucket.completedCount);

  final completedCountByCategoryId = <String, int>{
    for (final bucket in buckets)
      if (bucket.categoryId != null) bucket.categoryId!: bucket.completedCount,
  };

  ClearCompletedMode selectedMode = ClearCompletedMode.all;
  final Set<String> selectedCategoryIds = completedCountByCategoryId.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .toSet();

  return showModalBottomSheet<ClearCompletedSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final canSubmit = switch (selectedMode) {
            ClearCompletedMode.all => totalCount > 0,
            ClearCompletedMode.uncategorizedOnly => uncategorizedCount > 0,
            ClearCompletedMode.selectedCategories =>
              selectedCategoryIds.isNotEmpty,
          };

          final theme = Theme.of(context);

          return FractionallySizedBox(
            heightFactor: 0.88,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.clearCompletedItems,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.areYouSureYouWantToRemoveAllCompletedItems,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.45),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      selectedMode = ClearCompletedMode.all;
                                    });
                                  },
                                  leading: Icon(
                                    selectedMode == ClearCompletedMode.all
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(l10n.allCategory),
                                  subtitle: Text('$totalCount'),
                                ),
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      selectedMode =
                                          ClearCompletedMode.uncategorizedOnly;
                                    });
                                  },
                                  leading: Icon(
                                    selectedMode ==
                                            ClearCompletedMode.uncategorizedOnly
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(l10n.noCategory),
                                  subtitle: Text('$uncategorizedCount'),
                                ),
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      selectedMode =
                                          ClearCompletedMode.selectedCategories;
                                    });
                                  },
                                  leading: Icon(
                                    selectedMode ==
                                            ClearCompletedMode
                                                .selectedCategories
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: theme.colorScheme.primary,
                                  ),
                                  title: Text(l10n.category),
                                  subtitle: Text('${listCategories.length}'),
                                ),
                              ],
                            ),
                          ),
                          if (selectedMode ==
                              ClearCompletedMode.selectedCategories) ...[
                            const SizedBox(height: 12),
                            Text(
                              l10n.category,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                              child: listCategories.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(l10n.noCategoriesAvailable),
                                    )
                                  : Column(
                                      children: listCategories.map((category) {
                                        final completedCount =
                                            completedCountByCategoryId[
                                                    category.id] ??
                                                0;
                                        return CheckboxListTile(
                                          value: selectedCategoryIds
                                              .contains(category.id),
                                          title: Text(category.name),
                                          subtitle: Text('$completedCount'),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          onChanged: (selected) {
                                            setState(() {
                                              if (selected == true) {
                                                selectedCategoryIds
                                                    .add(category.id);
                                              } else {
                                                selectedCategoryIds
                                                    .remove(category.id);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: canSubmit
                              ? () => Navigator.pop(
                                    sheetContext,
                                    ClearCompletedSelection(
                                      mode: selectedMode,
                                      selectedCategoryIds:
                                          Set<String>.from(selectedCategoryIds),
                                    ),
                                  )
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l10n.clearItems),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
