import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Test header widget showing timer, question counter, and subject
class TestHeaderWidget extends StatelessWidget {
  final String timeRemaining;
  final int currentQuestion;
  final int totalQuestions;
  final String subject;
  final Color subjectColor;
  final VoidCallback onPalettePressed;

  const TestHeaderWidget({
    super.key,
    required this.timeRemaining,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.subject,
    required this.subjectColor,
    required this.onPalettePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timer
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'timer',
                    color: AppTheme.warningLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    timeRemaining,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warningLight,
                    ),
                  ),
                ],
              ),

              // Question Counter
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  '$currentQuestion / $totalQuestions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              // Palette Button
              IconButton(
                onPressed: onPalettePressed,
                icon: CustomIconWidget(
                  iconName: 'grid_view',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Subject Indicator
          Row(
            children: [
              Container(
                width: 1.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: subjectColor,
                  borderRadius: BorderRadius.circular(0.5.w),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                subject,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: subjectColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
