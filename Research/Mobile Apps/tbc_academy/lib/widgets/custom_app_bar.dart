import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types for different screen contexts
enum AppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with search functionality
  search,

  /// App bar with back button and title
  detail,

  /// Transparent app bar for video player overlay
  transparent,

  /// App bar with progress indicator for tests
  progress,
}

/// Custom app bar for NEET preparation app
/// Implements clean, focused design with minimal elevation
/// Supports multiple variants for different screen contexts
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar variant type
  final AppBarVariant variant;

  /// Title text
  final String? title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (defaults to back button if canPop is true)
  final Widget? leading;

  /// Action widgets
  final List<Widget>? actions;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color
  final Color? foregroundColor;

  /// Elevation
  final double? elevation;

  /// Center title
  final bool centerTitle;

  /// Progress value for progress variant (0.0 to 1.0)
  final double? progressValue;

  /// Search controller for search variant
  final TextEditingController? searchController;

  /// Search callback for search variant
  final Function(String)? onSearchChanged;

  /// Search submit callback
  final Function(String)? onSearchSubmitted;

  const CustomAppBar({
    super.key,
    this.variant = AppBarVariant.standard,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.progressValue,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize {
    // Add extra height for progress indicator if needed
    final baseHeight = variant == AppBarVariant.progress ? 56.0 + 4.0 : 56.0;
    return Size.fromHeight(baseHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor = variant == AppBarVariant.transparent
        ? Colors.transparent
        : (backgroundColor ?? colorScheme.surface);

    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;

    // System UI overlay style based on background brightness
    final brightness =
        ThemeData.estimateBrightnessForColor(effectiveBackgroundColor);
    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AppBar(
      systemOverlayStyle: overlayStyle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: variant == AppBarVariant.transparent ? 0 : (elevation ?? 0),
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: _buildTitle(context),
      actions: variant == AppBarVariant.search ? null : actions,
      bottom: variant == AppBarVariant.progress
          ? PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: _buildProgressIndicator(context),
            )
          : null,
    );
  }

  Widget? _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case AppBarVariant.search:
        return _buildSearchField(context);

      case AppBarVariant.standard:
      case AppBarVariant.detail:
      case AppBarVariant.transparent:
      case AppBarVariant.progress:
        if (title == null) return null;

        if (subtitle != null) {
          return Column(
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }

        return Text(
          title!,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search videos, notes, tests...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: searchController?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    searchController?.clear();
                    onSearchChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LinearProgressIndicator(
      value: progressValue,
      backgroundColor:
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
      minHeight: 4,
    );
  }
}

/// Helper extension to create common app bar configurations
extension CustomAppBarFactory on CustomAppBar {
  /// Creates a standard app bar with title and actions
  static CustomAppBar standard({
    required String title,
    List<Widget>? actions,
    bool centerTitle = false,
  }) {
    return CustomAppBar(
      variant: AppBarVariant.standard,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  /// Creates a detail screen app bar with back button
  static CustomAppBar detail({
    required String title,
    String? subtitle,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      variant: AppBarVariant.detail,
      title: title,
      subtitle: subtitle,
      actions: actions,
    );
  }

  /// Creates a search app bar
  static CustomAppBar search({
    required TextEditingController searchController,
    required Function(String) onSearchChanged,
    Function(String)? onSearchSubmitted,
  }) {
    return CustomAppBar(
      variant: AppBarVariant.search,
      searchController: searchController,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
    );
  }

  /// Creates a transparent app bar for video player
  static CustomAppBar transparent({
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      variant: AppBarVariant.transparent,
      actions: actions,
      foregroundColor: Colors.white,
    );
  }

  /// Creates a progress app bar for tests
  static CustomAppBar progress({
    required String title,
    required double progressValue,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      variant: AppBarVariant.progress,
      title: title,
      progressValue: progressValue,
      actions: actions,
    );
  }
}
