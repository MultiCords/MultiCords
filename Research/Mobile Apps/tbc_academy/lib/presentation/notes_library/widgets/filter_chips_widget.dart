import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Filter chips widget for subject and price filtering
class FilterChipsWidget extends StatelessWidget {
  final String selectedSubject;
  final String selectedPrice;
  final String selectedType;
  final Function(String) onSubjectChanged;
  final Function(String) onPriceChanged;
  final Function(String) onTypeChanged;

  const FilterChipsWidget({
    super.key,
    required this.selectedSubject,
    required this.selectedPrice,
    required this.selectedType,
    required this.onSubjectChanged,
    required this.onPriceChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                    context, 'All', selectedSubject, onSubjectChanged),
                SizedBox(width: 2.w),
                _buildFilterChip(
                    context, 'Biology', selectedSubject, onSubjectChanged),
                SizedBox(width: 2.w),
                _buildFilterChip(
                    context, 'Physics', selectedSubject, onSubjectChanged),
                SizedBox(width: 2.w),
                _buildFilterChip(
                    context, 'Mathematics', selectedSubject, onSubjectChanged),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Price',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildFilterChip(context, 'All', selectedPrice, onPriceChanged),
              SizedBox(width: 2.w),
              _buildFilterChip(context, 'Free', selectedPrice, onPriceChanged),
              SizedBox(width: 2.w),
              _buildFilterChip(context, 'Paid', selectedPrice, onPriceChanged),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Type',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildFilterChip(context, 'All', selectedType, onTypeChanged),
              SizedBox(width: 2.w),
              _buildFilterChip(
                  context, 'Handwritten', selectedType, onTypeChanged),
              SizedBox(width: 2.w),
              _buildFilterChip(context, 'Typed', selectedType, onTypeChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedValue == label;

    return InkWell(
      onTap: () => onSelected(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
