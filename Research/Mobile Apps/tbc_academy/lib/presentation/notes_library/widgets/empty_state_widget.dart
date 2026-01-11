import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Empty state widget for notes library
class EmptyStateWidget extends StatelessWidget {
  final String subject;
  final VoidCallback onExploreTap;

  const EmptyStateWidget({
    super.key,
    required this.subject,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageWidget(
              imageUrl: _getEmptyStateImage(subject),
              width: 60.w,
              height: 30.h,
              fit: BoxFit.contain,
              semanticLabel:
                  'Empty state illustration showing a student studying with books and notes',
            ),
            SizedBox(height: 3.h),
            Text(
              'No Notes Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              subject == 'All'
                  ? 'Start exploring our comprehensive collection of NEET preparation notes'
                  : 'No notes available for $subject at the moment',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: onExploreTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Explore All Notes',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateImage(String subject) {
    switch (subject.toLowerCase()) {
      case 'biology':
        return 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=800&q=80';
      case 'physics':
        return 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&q=80';
      case 'mathematics':
        return 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=800&q=80';
      default:
        return 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&q=80';
    }
  }
}
