import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Download manager widget showing offline content storage
class DownloadManagerWidget extends StatelessWidget {
  final double usedStorage;
  final double totalStorage;
  final int downloadedItems;
  final VoidCallback onManageTap;

  const DownloadManagerWidget({
    super.key,
    required this.usedStorage,
    required this.totalStorage,
    required this.downloadedItems,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storagePercentage = (usedStorage / totalStorage * 100).clamp(0, 100);

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
                'Download Manager',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onManageTap,
                child: Text('Manage'),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Storage usage card
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'storage',
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Storage Used',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${usedStorage.toStringAsFixed(1)} GB / ${totalStorage.toStringAsFixed(0)} GB',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: storagePercentage / 100,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      storagePercentage > 80
                          ? Colors.red
                          : storagePercentage > 60
                              ? Colors.orange
                              : theme.colorScheme.secondary,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${storagePercentage.toStringAsFixed(1)}% used',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Downloaded items
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: 'download',
                  label: 'Downloaded Items',
                  value: downloadedItems.toString(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: 'folder',
                  label: 'Available Space',
                  value:
                      '${(totalStorage - usedStorage).toStringAsFixed(1)} GB',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Clear cache button
          OutlinedButton(
            onPressed: () {
              _showClearCacheDialog(context);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'delete_outline',
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Clear Cache',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 0.3.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache?'),
        content: Text(
          'This will remove temporary files and free up storage space. Your downloaded notes will not be affected.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}
