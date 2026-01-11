import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Settings section widget for app customization
class SettingsSectionWidget extends StatelessWidget {
  final String selectedTheme;
  final String videoQuality;
  final bool autoDownload;
  final String language;
  final Function(String) onThemeChanged;
  final Function(String) onVideoQualityChanged;
  final Function(bool) onAutoDownloadChanged;
  final Function(String) onLanguageChanged;

  const SettingsSectionWidget({
    super.key,
    required this.selectedTheme,
    required this.videoQuality,
    required this.autoDownload,
    required this.language,
    required this.onThemeChanged,
    required this.onVideoQualityChanged,
    required this.onAutoDownloadChanged,
    required this.onLanguageChanged,
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
            'App Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Theme selection
          _buildSettingTile(
            context: context,
            icon: 'palette',
            title: 'Theme',
            subtitle: selectedTheme,
            onTap: () => _showThemeDialog(context),
          ),

          Divider(height: 3.h),

          // Video quality
          _buildSettingTile(
            context: context,
            icon: 'high_quality',
            title: 'Video Quality',
            subtitle: videoQuality,
            onTap: () => _showVideoQualityDialog(context),
          ),

          Divider(height: 3.h),

          // Auto-download toggle
          _buildSwitchTile(
            context: context,
            icon: 'download',
            title: 'Auto-download Notes',
            subtitle: 'Download new notes automatically',
            value: autoDownload,
            onChanged: onAutoDownloadChanged,
          ),

          Divider(height: 3.h),

          // Language selection
          _buildSettingTile(
            context: context,
            icon: 'language',
            title: 'Language',
            subtitle: language,
            onTap: () => _showLanguageDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
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

  Widget _buildSwitchTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
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
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption(context, 'Light', selectedTheme == 'Light'),
            _buildRadioOption(context, 'Dark', selectedTheme == 'Dark'),
            _buildRadioOption(context, 'Auto', selectedTheme == 'Auto'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showVideoQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Video Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption(context, 'Auto', videoQuality == 'Auto'),
            _buildRadioOption(context, '1080p', videoQuality == '1080p'),
            _buildRadioOption(context, '720p', videoQuality == '720p'),
            _buildRadioOption(context, '480p', videoQuality == '480p'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption(context, 'English', language == 'English'),
            _buildRadioOption(context, 'Hindi', language == 'Hindi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(
      BuildContext context, String value, bool isSelected) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (value == 'Light' || value == 'Dark' || value == 'Auto') {
          onThemeChanged(value);
        } else if (value == '1080p' ||
            value == '720p' ||
            value == '480p' ||
            value == 'Auto') {
          onVideoQualityChanged(value);
        } else {
          onLanguageChanged(value);
        }
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) {},
            ),
            SizedBox(width: 2.w),
            Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
