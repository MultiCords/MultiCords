import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Note card widget with slidable actions
class NoteCardWidget extends StatelessWidget {
  final Map<String, dynamic> note;
  final VoidCallback onTap;
  final VoidCallback onPreview;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onDownload;

  const NoteCardWidget({
    super.key,
    required this.note,
    required this.onTap,
    required this.onPreview,
    required this.onBookmark,
    required this.onShare,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFree = note['price'] == 'Free';
    final isDownloaded = note['isDownloaded'] ?? false;

    return Slidable(
      key: ValueKey(note['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onPreview(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.visibility_outlined,
            label: 'Preview',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onBookmark(),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.bookmark_outline,
            label: 'Bookmark',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onShare(),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            icon: Icons.share_outlined,
            label: 'Share',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageWidget(
                    imageUrl: note['thumbnail'],
                    width: 20.w,
                    height: 12.h,
                    fit: BoxFit.cover,
                    semanticLabel: note['semanticLabel'],
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note['title'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getSubjectColor(note['subject'], theme)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          note['subject'],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getSubjectColor(note['subject'], theme),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            note['rating'].toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          CustomIconWidget(
                            iconName: 'download',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${note['downloads']}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isFree ? 'Free' : note['price'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isFree
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isDownloaded)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 0.8.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Downloaded',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: isFree ? onDownload : onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFree
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.primary,
                                foregroundColor: isFree
                                    ? theme.colorScheme.onSecondary
                                    : theme.colorScheme.onPrimary,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4.w, vertical: 1.h),
                                minimumSize: Size(20.w, 4.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                isFree ? 'Download' : 'Buy Now',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject, ThemeData theme) {
    switch (subject.toLowerCase()) {
      case 'biology':
        return theme.colorScheme.secondary;
      case 'physics':
        return theme.colorScheme.primary;
      case 'mathematics':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility_outlined',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Preview', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                onPreview();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bookmark_outline',
                color: theme.colorScheme.secondary,
                size: 24,
              ),
              title: Text('Bookmark', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                onBookmark();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share_outlined',
                color: theme.colorScheme.tertiary,
                size: 24,
              ),
              title: Text('Share', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              title: Text('Download', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                onDownload();
              },
            ),
          ],
        ),
      ),
    );
  }
}
