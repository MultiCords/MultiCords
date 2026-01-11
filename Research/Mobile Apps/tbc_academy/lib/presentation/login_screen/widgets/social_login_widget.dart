import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Social login options widget with Google and Apple sign-in
class SocialLoginWidget extends StatelessWidget {
  final VoidCallback onGoogleLogin;
  final VoidCallback onAppleLogin;

  const SocialLoginWidget({
    super.key,
    required this.onGoogleLogin,
    required this.onAppleLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outlineVariant,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outlineVariant,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Social Login Buttons
        Row(
          children: [
            // Google Sign In
            Expanded(
              child: _SocialLoginButton(
                icon: 'g_logo',
                label: 'Google',
                onPressed: onGoogleLogin,
                backgroundColor: theme.colorScheme.surface,
                borderColor: theme.colorScheme.outline,
              ),
            ),
            SizedBox(width: 4.w),

            // Apple Sign In
            Expanded(
              child: _SocialLoginButton(
                icon: 'apple',
                label: 'Apple',
                onPressed: onAppleLogin,
                backgroundColor: theme.colorScheme.surface,
                borderColor: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual social login button
class _SocialLoginButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 6.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon == 'g_logo' ? 'g_translate' : 'apple',
              color: theme.colorScheme.onSurface,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
