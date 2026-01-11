import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Account information section with editable fields
class AccountInfoSectionWidget extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String currentClass;
  final String targetYear;
  final VoidCallback onEditTap;

  const AccountInfoSectionWidget({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.currentClass,
    required this.targetYear,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
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
                'Account Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: onEditTap,
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                tooltip: 'Edit account information',
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            context: context,
            icon: 'person',
            label: 'Full Name',
            value: name,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            context: context,
            icon: 'email',
            label: 'Email',
            value: email,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            context: context,
            icon: 'phone',
            label: 'Phone',
            value: phone,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            context: context,
            icon: 'school',
            label: 'Current Class',
            value: currentClass,
          ),
          SizedBox(height: 1.5.h),
          _buildInfoRow(
            context: context,
            icon: 'calendar_today',
            label: 'Target Exam Year',
            value: targetYear,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
