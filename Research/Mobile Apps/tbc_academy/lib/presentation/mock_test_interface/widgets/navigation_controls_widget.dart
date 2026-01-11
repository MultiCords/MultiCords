import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget for test navigation controls
class NavigationControlsWidget extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onMarkForReview;
  final VoidCallback onSubmit;
  final bool isLastQuestion;

  const NavigationControlsWidget({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onMarkForReview,
    required this.onSubmit,
    required this.isLastQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mark for Review Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onMarkForReview,
              icon: const Icon(Icons.bookmark_border, size: 20),
              label: const Text('Mark for Review'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                side: BorderSide(
                  color: theme.colorScheme.tertiary,
                ),
                foregroundColor: theme.colorScheme.tertiary,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Navigation Buttons
          Row(
            children: [
              // Previous Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canGoPrevious ? onPrevious : null,
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Next/Submit Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isLastQuestion ? onSubmit : (canGoNext ? onNext : null),
                  icon: Icon(
                    isLastQuestion ? Icons.check : Icons.arrow_forward,
                    size: 20,
                  ),
                  label: Text(isLastQuestion ? 'Submit' : 'Next'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    backgroundColor: isLastQuestion
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
