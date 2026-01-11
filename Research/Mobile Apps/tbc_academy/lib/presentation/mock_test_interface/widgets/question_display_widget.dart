import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Widget to display question text and optional image
class QuestionDisplayWidget extends StatelessWidget {
  final int questionNumber;
  final String questionText;
  final bool hasImage;
  final String imageUrl;
  final String semanticLabel;

  const QuestionDisplayWidget({
    super.key,
    required this.questionNumber,
    required this.questionText,
    required this.hasImage,
    required this.imageUrl,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1.5.w),
            ),
            child: Text(
              'Question $questionNumber',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Question Text
          Text(
            questionText,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 15.sp,
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),

          // Question Image (if available)
          if (hasImage && imageUrl.isNotEmpty) ...[
            SizedBox(height: 2.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.w),
              child: CustomImageWidget(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 25.h,
                fit: BoxFit.contain,
                semanticLabel: semanticLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
