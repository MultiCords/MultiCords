import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Question Review Widget
/// Displays filterable list of questions with detailed explanations
class QuestionReviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final Function(String) onFilterChanged;
  final String selectedFilter;

  const QuestionReviewWidget({
    super.key,
    required this.questions,
    required this.onFilterChanged,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredQuestions = _getFilteredQuestions();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'rate_review',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Question Review',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  theme: theme,
                  label: 'All',
                  count: questions.length,
                  isSelected: selectedFilter == 'All',
                ),
                SizedBox(width: 2.w),
                _buildFilterChip(
                  theme: theme,
                  label: 'Correct',
                  count:
                      questions.where((q) => q["status"] == "correct").length,
                  isSelected: selectedFilter == 'Correct',
                  color: theme.colorScheme.secondary,
                ),
                SizedBox(width: 2.w),
                _buildFilterChip(
                  theme: theme,
                  label: 'Incorrect',
                  count:
                      questions.where((q) => q["status"] == "incorrect").length,
                  isSelected: selectedFilter == 'Incorrect',
                  color: theme.colorScheme.error,
                ),
                SizedBox(width: 2.w),
                _buildFilterChip(
                  theme: theme,
                  label: 'Unattempted',
                  count: questions
                      .where((q) => q["status"] == "unattempted")
                      .length,
                  isSelected: selectedFilter == 'Unattempted',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Questions List
          filteredQuestions.isEmpty
              ? _buildEmptyState(theme)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredQuestions.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(theme, filteredQuestions[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeData theme,
    required String label,
    required int count,
    required bool isSelected,
    Color? color,
  }) {
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(label);
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: chipColor.withValues(alpha: 0.2),
      checkmarkColor: chipColor,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: isSelected ? chipColor : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected
            ? chipColor
            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
    );
  }

  Widget _buildQuestionCard(ThemeData theme, Map<String, dynamic> question) {
    final status = question["status"] as String;
    final statusColor = _getStatusColor(status, theme);
    final statusIcon = _getStatusIcon(status);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${question["id"]}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question["subject"] as String,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      question["topic"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: statusIcon,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      status == "unattempted" ? "Skipped" : status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Question Text
          Text(
            question["question"] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),

          SizedBox(height: 2.h),

          // Options
          ...(question["options"] as List).asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value as String;
            final correctAnswer = question["correctAnswer"] as int;
            final userAnswer = question["userAnswer"] as int?;

            final isCorrectAnswer = index == correctAnswer;
            final isUserAnswer = index == userAnswer;

            Color? optionColor;
            IconData? optionIcon;

            if (isCorrectAnswer) {
              optionColor = theme.colorScheme.secondary;
              optionIcon = Icons.check_circle;
            } else if (isUserAnswer && !isCorrectAnswer) {
              optionColor = theme.colorScheme.error;
              optionIcon = Icons.cancel;
            }

            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: optionColor?.withValues(alpha: 0.1) ??
                    theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: optionColor?.withValues(alpha: 0.5) ??
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: optionColor != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: optionColor?.withValues(alpha: 0.2) ??
                          theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: optionColor ?? theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      option,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: optionColor ?? theme.colorScheme.onSurface,
                        fontWeight: optionColor != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (optionIcon != null)
                    CustomIconWidget(
                      iconName: optionIcon == Icons.check_circle
                          ? 'check_circle'
                          : 'cancel',
                      color: optionColor!,
                      size: 20,
                    ),
                ],
              ),
            );
          }),

          SizedBox(height: 2.h),

          // Time Taken
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                'Time taken: ${question["timeTaken"]}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Explanation
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Explanation',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  question["explanation"] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Related Video Link
          TextButton.icon(
            onPressed: () {
              // Navigate to related video
            },
            icon: CustomIconWidget(
              iconName: 'play_circle',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            label: Text(
              'Watch Related Video',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: theme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No questions found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try changing the filter',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredQuestions() {
    if (selectedFilter == 'All') {
      return questions;
    }
    return questions
        .where((q) =>
            q["status"] == selectedFilter.toLowerCase() ||
            (selectedFilter == 'Unattempted' && q["status"] == "unattempted"))
        .toList();
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'correct':
        return theme.colorScheme.secondary;
      case 'incorrect':
        return theme.colorScheme.error;
      case 'unattempted':
        return theme.colorScheme.onSurfaceVariant;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'correct':
        return 'check_circle';
      case 'incorrect':
        return 'cancel';
      case 'unattempted':
        return 'remove_circle';
      default:
        return 'help';
    }
  }
}