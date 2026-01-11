import 'package:flutter/material.dart';

/// Tab item configuration
class TabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;

  const TabItem({
    required this.label,
    this.icon,
    this.customIcon,
  });
}

/// Tab bar variant types
enum TabBarVariant {
  /// Standard text-only tabs
  text,

  /// Tabs with icons and labels
  iconWithLabel,

  /// Icon-only tabs
  iconOnly,

  /// Scrollable tabs for many items
  scrollable,
}

/// Custom tab bar for NEET preparation app
/// Implements adaptive tab navigation with educational content hierarchy
/// Supports multiple variants for different content organization needs
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// Tab items to display
  final List<TabItem> tabs;

  /// Tab controller
  final TabController controller;

  /// Tab bar variant
  final TabBarVariant variant;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Custom indicator color
  final Color? indicatorColor;

  /// Custom label color
  final Color? labelColor;

  /// Custom unselected label color
  final Color? unselectedLabelColor;

  /// Custom background color
  final Color? backgroundColor;

  /// Indicator weight
  final double indicatorWeight;

  /// Padding around tabs
  final EdgeInsetsGeometry? padding;

  /// Tab alignment for scrollable tabs
  final TabAlignment? tabAlignment;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.controller,
    this.variant = TabBarVariant.text,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.backgroundColor,
    this.indicatorWeight = 3.0,
    this.padding,
    this.tabAlignment,
  });

  @override
  Size get preferredSize {
    // Height varies based on variant
    double height = 48.0;
    if (variant == TabBarVariant.iconWithLabel) {
      height = 64.0;
    }
    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveIndicatorColor = indicatorColor ?? colorScheme.primary;
    final effectiveLabelColor = labelColor ?? colorScheme.primary;
    final effectiveUnselectedLabelColor =
        unselectedLabelColor ?? colorScheme.onSurfaceVariant;

    return Container(
      color: backgroundColor ?? colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: TabBar(
            controller: controller,
            isScrollable: isScrollable || variant == TabBarVariant.scrollable,
            tabAlignment: tabAlignment ??
                (isScrollable ? TabAlignment.start : TabAlignment.fill),
            indicatorColor: effectiveIndicatorColor,
            indicatorWeight: indicatorWeight,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: effectiveLabelColor,
            unselectedLabelColor: effectiveUnselectedLabelColor,
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
            dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
            dividerHeight: 1,
            tabs: _buildTabs(context),
            splashFactory: InkRipple.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.pressed)) {
                  return effectiveLabelColor.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.hovered)) {
                  return effectiveLabelColor.withValues(alpha: 0.08);
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    return tabs.map((tab) {
      switch (variant) {
        case TabBarVariant.text:
          return Tab(
            text: tab.label,
            height: 48,
          );

        case TabBarVariant.iconWithLabel:
          return Tab(
            icon: tab.customIcon ?? Icon(tab.icon),
            text: tab.label,
            height: 64,
            iconMargin: const EdgeInsets.only(bottom: 4),
          );

        case TabBarVariant.iconOnly:
          return Tab(
            icon: tab.customIcon ?? Icon(tab.icon),
            height: 48,
          );

        case TabBarVariant.scrollable:
          return Tab(
            text: tab.label,
            height: 48,
          );
      }
    }).toList();
  }
}

/// Helper class to create subject-specific tabs for NEET content
class SubjectTabs {
  /// Creates tabs for NEET subjects
  static List<TabItem> neetSubjects() {
    return const [
      TabItem(
        label: 'Physics',
        icon: Icons.science_outlined,
      ),
      TabItem(
        label: 'Chemistry',
        icon: Icons.biotech_outlined,
      ),
      TabItem(
        label: 'Biology',
        icon: Icons.eco_outlined,
      ),
    ];
  }

  /// Creates tabs for content types
  static List<TabItem> contentTypes() {
    return const [
      TabItem(
        label: 'All',
        icon: Icons.grid_view_outlined,
      ),
      TabItem(
        label: 'Videos',
        icon: Icons.play_circle_outline,
      ),
      TabItem(
        label: 'Notes',
        icon: Icons.description_outlined,
      ),
      TabItem(
        label: 'Tests',
        icon: Icons.assignment_outlined,
      ),
    ];
  }

  /// Creates tabs for test categories
  static List<TabItem> testCategories() {
    return const [
      TabItem(label: 'All Tests'),
      TabItem(label: 'Mock Tests'),
      TabItem(label: 'Chapter Tests'),
      TabItem(label: 'Previous Year'),
      TabItem(label: 'Practice'),
    ];
  }

  /// Creates tabs for video categories
  static List<TabItem> videoCategories() {
    return const [
      TabItem(label: 'Continue Watching'),
      TabItem(label: 'Recommended'),
      TabItem(label: 'New Releases'),
      TabItem(label: 'Bookmarked'),
    ];
  }
}

/// Tab view wrapper that works with CustomTabBar
class CustomTabView extends StatelessWidget {
  /// Tab controller
  final TabController controller;

  /// Tab views
  final List<Widget> children;

  /// Physics for scrolling
  final ScrollPhysics? physics;

  const CustomTabView({
    super.key,
    required this.controller,
    required this.children,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(),
      children: children,
    );
  }
}
