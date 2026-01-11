import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class VideoFilterChipsWidget extends StatelessWidget {
  final List<String> teachers;
  final List<String> subjects;
  final List<String> categories;
  final String? selectedTeacher;
  final String? selectedSubject;
  final String? selectedCategory;
  final Function(String) onTeacherSelected;
  final Function(String) onSubjectSelected;
  final Function(String) onCategorySelected;
  final VoidCallback onClearFilters;

  const VideoFilterChipsWidget({
    super.key,
    required this.teachers,
    required this.subjects,
    required this.categories,
    this.selectedTeacher,
    this.selectedSubject,
    this.selectedCategory,
    required this.onTeacherSelected,
    required this.onSubjectSelected,
    required this.onCategorySelected,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters =
        selectedTeacher != null ||
        selectedSubject != null ||
        selectedCategory != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const CustomIconWidget(iconName: 'clear', size: 16),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilterSection(
            theme: theme,
            label: 'Teachers',
            items: teachers,
            selectedItem: selectedTeacher,
            onSelected: onTeacherSelected,
          ),
          const SizedBox(height: 12),
          _buildFilterSection(
            theme: theme,
            label: 'Subjects',
            items: subjects,
            selectedItem: selectedSubject,
            onSelected: onSubjectSelected,
          ),
          const SizedBox(height: 12),
          _buildFilterSection(
            theme: theme,
            label: 'Categories',
            items: categories,
            selectedItem: selectedCategory,
            onSelected: onCategorySelected,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required ThemeData theme,
    required String label,
    required List<String> items,
    required String? selectedItem,
    required Function(String) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                items.map((item) {
                  final isSelected =
                      (selectedItem == item) ||
                      (selectedItem == null && item.startsWith('All'));

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: (_) => onSelected(item),
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.onPrimaryContainer,
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color:
                            isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
