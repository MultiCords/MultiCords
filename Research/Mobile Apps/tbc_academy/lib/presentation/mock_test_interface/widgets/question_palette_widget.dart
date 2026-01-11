import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../mock_test_interface.dart';

/// Question palette overlay showing all questions with status
class QuestionPaletteWidget extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;
  final Map<int, QuestionStatus> questionStatuses;
  final Function(int) onQuestionSelected;
  final VoidCallback onClose;

  const QuestionPaletteWidget({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
    required this.questionStatuses,
    required this.onQuestionSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside
            child: Container(
              width: 90.w,
              constraints: BoxConstraints(maxHeight: 70.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question Palette',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: theme
                                .colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Legend
                  Container(
                    padding: EdgeInsets.all(4.w),
                    child: Wrap(
                      spacing: 3.w,
                      runSpacing: 1.h,
                      children: [
                        _buildLegendItem(
                          context,
                          'Answered',
                          theme.colorScheme.secondary,
                        ),
                        _buildLegendItem(
                          context,
                          'Not Answered',
                          theme.colorScheme.onSurfaceVariant,
                        ),
                        _buildLegendItem(
                          context,
                          'Marked',
                          theme.colorScheme.tertiary,
                        ),
                        _buildLegendItem(
                          context,
                          'Current',
                          theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  // Question Grid
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(4.w),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 2.w,
                          childAspectRatio: 1,
                        ),
                        itemCount: totalQuestions,
                        itemBuilder: (context, index) {
                          return _buildQuestionButton(
                            context: context,
                            questionNumber: index + 1,
                            status: questionStatuses[index] ??
                                QuestionStatus.notAnswered,
                            isCurrent: index == currentQuestion,
                            onTap: () => onQuestionSelected(index),
                            theme: theme,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildQuestionButton({
    required BuildContext context,
    required int questionNumber,
    required QuestionStatus status,
    required bool isCurrent,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case QuestionStatus.answered:
        backgroundColor = theme.colorScheme.secondary;
        textColor = theme.colorScheme.onSecondary;
        break;
      case QuestionStatus.markedForReview:
        backgroundColor = theme.colorScheme.tertiary;
        textColor = theme.colorScheme.onTertiary;
        break;
      case QuestionStatus.current:
        backgroundColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimary;
        break;
      case QuestionStatus.notAnswered:
      default:
        backgroundColor =
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
        textColor = theme.colorScheme.onSurface;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2.w),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(2.w),
          border: isCurrent
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          questionNumber.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
