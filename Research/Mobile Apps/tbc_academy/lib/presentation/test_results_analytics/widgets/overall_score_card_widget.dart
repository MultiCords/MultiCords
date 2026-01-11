import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Overall Score Card Widget
/// Displays overall test performance with circular progress indicator
class OverallScoreCardWidget extends StatelessWidget {
  final Map<String, dynamic> testResults;

  const OverallScoreCardWidget({
    super.key,
    required this.testResults,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = testResults["overallScore"] as int;
    final maxScore = testResults["maxScore"] as int;
    final percentile = testResults["percentile"] as double;
    final timeTaken = testResults["timeTaken"] as String;
    final rank = testResults["rank"] as int;
    final totalAttempts = testResults["totalAttempts"] as int;

    final percentage = (score / maxScore) * 100;
    final performanceColor = _getPerformanceColor(percentage, theme);

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            performanceColor.withValues(alpha: 0.1),
            performanceColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: performanceColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: performanceColor.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Performance',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Completed on ${_formatDate(testResults["completedAt"] as String)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: performanceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPerformanceLabel(percentage),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Circular Progress Indicator
          CircularPercentIndicator(
            radius: 25.w,
            lineWidth: 12.0,
            percent: score / maxScore,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: performanceColor,
                  ),
                ),
                Text(
                  'out of $maxScore',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: performanceColor,
                  ),
                ),
              ],
            ),
            progressColor: performanceColor,
            backgroundColor: performanceColor.withValues(alpha: 0.2),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1500,
          ),

          SizedBox(height: 3.h),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  icon: 'trending_up',
                  label: 'Percentile',
                  value: '${percentile.toStringAsFixed(1)}%',
                  color: theme.colorScheme.secondary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  icon: 'timer',
                  label: 'Time Taken',
                  value: timeTaken,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  icon: 'military_tech',
                  label: 'Rank',
                  value: '$rank',
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  theme: theme,
                  icon: 'people',
                  label: 'Total Attempts',
                  value: _formatNumber(totalAttempts),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required ThemeData theme,
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(double percentage, ThemeData theme) {
    if (percentage >= 85) {
      return theme.colorScheme.secondary; // Green for excellent
    } else if (percentage >= 70) {
      return AppTheme.warningLight; // Orange for good
    } else {
      return theme.colorScheme.error; // Red for needs improvement
    }
  }

  String _getPerformanceLabel(double percentage) {
    if (percentage >= 85) {
      return 'Excellent';
    } else if (percentage >= 70) {
      return 'Good';
    } else if (percentage >= 50) {
      return 'Average';
    } else {
      return 'Needs Improvement';
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
