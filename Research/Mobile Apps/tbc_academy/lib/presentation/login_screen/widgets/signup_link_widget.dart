import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Sign up link widget at the bottom of login screen
class SignupLinkWidget extends StatelessWidget {
  final VoidCallback onSignUpTap;

  const SignupLinkWidget({
    super.key,
    required this.onSignUpTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New to NEET prep? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: onSignUpTap,
            child: Text(
              'Sign Up',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
