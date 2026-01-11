import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PerformanceOverviewCardWidget extends StatelessWidget {
  final Map<String, dynamic> performanceData;
  final VoidCallback onViewDetailsTap;

  const PerformanceOverviewCardWidget({
    super.key,
    required this.performanceData,
    required this.onViewDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'analytics',
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Performance Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onViewDetailsTap,
                  child: Text(
                    'View Details',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubjectPerformance(
                  context,
                  subject: 'Physics',
                  score: performanceData["physics"]["score"] as int,
                  tests: performanceData["physics"]["tests"] as int,
                  color: Color(performanceData["physics"]["color"] as int),
                ),
                _buildSubjectPerformance(
                  context,
                  subject: 'Chemistry',
                  score: performanceData["chemistry"]["score"] as int,
                  tests: performanceData["chemistry"]["tests"] as int,
                  color: Color(performanceData["chemistry"]["color"] as int),
                ),
                _buildSubjectPerformance(
                  context,
                  subject: 'Biology',
                  score: performanceData["biology"]["score"] as int,
                  tests: performanceData["biology"]["tests"] as int,
                  color: Color(performanceData["biology"]["color"] as int),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Average',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${performanceData["overall"]}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: 'trending_up',
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformance(
    BuildContext context, {
    required String subject,
    required int score,
    required int tests,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 12.w,
          lineWidth: 8,
          percent: score / 100,
          center: Text(
            '$score%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        SizedBox(height: 1.h),
        Text(
          subject,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          '$tests tests',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
