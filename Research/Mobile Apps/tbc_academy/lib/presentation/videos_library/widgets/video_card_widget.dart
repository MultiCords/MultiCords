import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class VideoCardWidget extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const VideoCardWidget({
    super.key,
    required this.video,
    required this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(theme),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubjectChip(theme),
                  const SizedBox(height: 8),
                  Text(
                    video["title"],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildTeacherInfo(theme),
                  const SizedBox(height: 8),
                  _buildVideoStats(theme),
                ],
              ),
            ),
            // Action buttons
            Row(
              children: [
                if (onBookmark != null)
                  IconButton(
                    onPressed: onBookmark,
                    icon: CustomIconWidget(
                      iconName: isBookmarked ? 'bookmark' : 'bookmark_border',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    tooltip: isBookmarked
                        ? 'Remove from Watch Later'
                        : 'Add to Watch Later',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: CustomImageWidget(
            imageUrl: video["thumbnail"],
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            semanticLabel: video["semanticLabel"],
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              video["duration"],
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              video["category"],
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(video["subjectColor"] as int).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        video["subject"],
        style: theme.textTheme.labelSmall?.copyWith(
          color: Color(video["subjectColor"] as int),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTeacherInfo(ThemeData theme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'person',
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            video["teacher"],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoStats(ThemeData theme) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'visibility',
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${video["views"]} views',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        CustomIconWidget(
          iconName: 'calendar_today',
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          video["uploadDate"],
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
