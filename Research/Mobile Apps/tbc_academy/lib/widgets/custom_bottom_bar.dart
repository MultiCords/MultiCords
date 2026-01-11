import 'package:flutter/material.dart';

/// Navigation item configuration for bottom bar
class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Custom bottom navigation bar for NEET preparation app
/// Implements bottom-heavy thumb zone strategy with persistent access to core learning modes
/// Follows Material Design 3 with educational branding
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final Function(int) onTap;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom selected item color
  final Color? selectedItemColor;

  /// Optional custom unselected item color
  final Color? unselectedItemColor;

  /// Optional elevation
  final double? elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
  });

  /// Navigation items mapped from Mobile Navigation Hierarchy
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/dashboard-home',
    ),
    BottomNavItem(
      label: 'Videos',
      icon: Icons.play_circle_outline,
      activeIcon: Icons.play_circle,
      route: '/video-player',
    ),
    BottomNavItem(
      label: 'Notes',
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      route: '/notes-library',
    ),
    BottomNavItem(
      label: 'Tests',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      route: '/mock-test-interface',
    ),
    BottomNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/profile-settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(
                context: context,
                item: _navItems[index],
                index: index,
                isSelected: currentIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required BottomNavItem item,
    required int index,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final itemColor = isSelected
        ? (selectedItemColor ?? colorScheme.primary)
        : (unselectedItemColor ?? colorScheme.onSurfaceVariant);

    return Expanded(
      child: InkWell(
        onTap: () {
          onTap(index);
          // Navigate to the corresponding route
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, item.route);
          }
        },
        splashColor: colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: colorScheme.primary.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with smooth transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                  color: itemColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label with smooth color transition
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: itemColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Active indicator
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 2,
                width: isSelected ? 24 : 0,
                decoration: BoxDecoration(
                  color: itemColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
