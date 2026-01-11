import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Subject Performance Widget
/// Displays subject-wise breakdown with bar chart
class SubjectPerformanceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;

  const SubjectPerformanceWidget({
    super.key,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                iconName: 'bar_chart',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Subject-wise Performance',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Bar Chart
          SizedBox(
            height: 30.h,
            child: Semantics(
              label: 'Subject-wise Performance Bar Chart',
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final subject = subjects[groupIndex];
                        return BarTooltipItem(
                          '${subject["name"]}\n${rod.toY.toStringAsFixed(1)}%',
                          theme.textTheme.bodySmall!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < subjects.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 1.h),
                              child: Text(
                                subjects[value.toInt()]["name"] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(theme),
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Subject Details List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectCard(theme, subject);
            },
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(ThemeData theme) {
    return List.generate(subjects.length, (index) {
      final subject = subjects[index];
      final accuracy = subject["accuracy"] as double;
      final color = _getSubjectColor(subject["name"] as String, theme);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: accuracy,
            color: color,
            width: 20.w,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 100,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubjectCard(ThemeData theme, Map<String, dynamic> subject) {
    final name = subject["name"] as String;
    final score = subject["score"] as int;
    final maxScore = subject["maxScore"] as int;
    final correct = subject["correct"] as int;
    final incorrect = subject["incorrect"] as int;
    final unattempted = subject["unattempted"] as int;
    final accuracy = subject["accuracy"] as double;
    final timeTaken = subject["timeTaken"] as String;
    final avgTimePerQuestion = subject["avgTimePerQuestion"] as String;

    final color = _getSubjectColor(name, theme);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getSubjectIcon(name),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '$score / $maxScore marks',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Question Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme: theme,
                  icon: 'check_circle',
                  label: 'Correct',
                  value: correct.toString(),
                  color: theme.colorScheme.secondary,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatItem(
                  theme: theme,
                  icon: 'cancel',
                  label: 'Incorrect',
                  value: incorrect.toString(),
                  color: theme.colorScheme.error,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatItem(
                  theme: theme,
                  icon: 'remove_circle',
                  label: 'Skipped',
                  value: unattempted.toString(),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Time Stats
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      timeTaken,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Total Time',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: theme.colorScheme.outlineVariant,
                ),
                Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'timer',
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      avgTimePerQuestion,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Avg/Question',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required ThemeData theme,
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: color,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getSubjectColor(String subject, ThemeData theme) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return theme.colorScheme.primary;
      case 'chemistry':
        return theme.colorScheme.tertiary;
      case 'biology':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return 'science';
      case 'chemistry':
        return 'biotech';
      case 'biology':
        return 'eco';
      default:
        return 'book';
    }
  }
}
