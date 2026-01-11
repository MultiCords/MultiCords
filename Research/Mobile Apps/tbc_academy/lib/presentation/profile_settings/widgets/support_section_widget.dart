import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Support section widget for help and feedback
class SupportSectionWidget extends StatelessWidget {
  final VoidCallback onHelpCenterTap;
  final VoidCallback onFeedbackTap;
  final VoidCallback onContactTap;
  final VoidCallback onYoutubeTap;

  const SupportSectionWidget({
    super.key,
    required this.onHelpCenterTap,
    required this.onFeedbackTap,
    required this.onContactTap,
    required this.onYoutubeTap,
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
          Text(
            'Support',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSupportTile(
            context: context,
            icon: 'help_outline',
            title: 'Help Center',
            subtitle: 'Browse FAQs and guides',
            onTap: onHelpCenterTap,
          ),
          Divider(height: 3.h),
          _buildSupportTile(
            context: context,
            icon: 'feedback',
            title: 'Send Feedback',
            subtitle: 'Share your thoughts and suggestions',
            onTap: onFeedbackTap,
          ),
          Divider(height: 3.h),
          _buildSupportTile(
            context: context,
            icon: 'contact_support',
            title: 'Contact Us',
            subtitle: 'Get in touch with our support team',
            onTap: onContactTap,
          ),
          Divider(height: 3.h),
          _buildSupportTile(
            context: context,
            icon: 'play_circle_outline',
            title: 'YouTube Tutorials',
            subtitle: 'Access TheBrainCord Academy video lessons',
            onTap: onYoutubeTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
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
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
