import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget to display answer options as selectable buttons
class AnswerOptionsWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const AnswerOptionsWidget({
    super.key,
    required this.options,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final optionLabels = ['A', 'B', 'C', 'D'];

    return Column(
      children: List.generate(
        options.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: _buildOptionButton(
            context: context,
            label: optionLabels[index],
            text: options[index],
            isSelected: selectedAnswer == optionLabels[index],
            theme: theme,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required String text,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => onAnswerSelected(label),
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option Label
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Option Text
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),

            // Selection Indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
