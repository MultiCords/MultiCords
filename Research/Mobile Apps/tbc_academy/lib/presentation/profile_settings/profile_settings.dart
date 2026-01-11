import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/custom_app_bar.dart';
import '../dashboard_home/widgets/performance_overview_card_widget.dart';
import './widgets/account_info_section_widget.dart';
import './widgets/achievements_showcase_widget.dart';
import './widgets/download_manager_widget.dart';
import './widgets/notification_preferences_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/security_section_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/subscription_management_widget.dart';
import './widgets/support_section_widget.dart';

/// Profile & Settings screen for TBC Academy
/// Centralizes user account management and app customization
class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  // User data
  final String _userName = 'Vijet Naik';
  final String _userEmail = 'priya.sharma@email.com';
  final String _userPhone = '+91 98765 43210';
  final String _currentClass = 'Class 12';
  final String _targetYear = '2026';
  final String _avatarUrl =
      'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png';

  // Subscription data
  final String _subscriptionStatus = 'Premium';
  final String _renewalDate = '15 Jan 2026';
  final bool _isSubscriptionActive = true;
  final int _studyStreak = 45;

  // Download manager data
  final double _usedStorage = 2.3;
  final double _totalStorage = 5.0;
  final int _downloadedItems = 127;

  // Settings state
  String _selectedTheme = 'Auto';
  String _videoQuality = 'Auto';
  bool _autoDownload = true;
  String _language = 'English';

  // Notification preferences
  bool _studyReminders = true;
  bool _newContentAlerts = true;
  bool _testNotifications = true;

  // Security settings
  bool _biometricEnabled = false;

  // Achievements data
  final List<Map<String, dynamic>> _achievements = [
    {
      'icon': 'emoji_events',
      'title': 'First Test',
      'date': '10 Dec 2024',
      'color': const Color(0xFFFFD700),
    },
    {
      'icon': 'local_fire_department',
      'title': '30 Day Streak',
      'date': '05 Dec 2024',
      'color': const Color(0xFFFF6B35),
    },
    {
      'icon': 'star',
      'title': 'Top Scorer',
      'date': '01 Dec 2024',
      'color': const Color(0xFF2E7D32),
    },
    {
      'icon': 'workspace_premium',
      'title': 'Premium Member',
      'date': '15 Nov 2024',
      'color': const Color(0xFF1B365D),
    },
  ];

  // Add performance data
  final Map<String, dynamic> _performanceData = {
    "physics": {"score": 82, "tests": 4, "color": 0xFF1B365D},
    "chemistry": {"score": 75, "tests": 4, "color": 0xFF2E7D32},
    "biology": {"score": 79, "tests": 4, "color": 0xFFFF6B35},
    "overall": 78.5,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(title: 'Profile & Settings'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(
              userName: _userName,
              userEmail: _userEmail,
              avatarUrl: _avatarUrl,
              subscriptionStatus: _subscriptionStatus,
              studyStreak: _studyStreak,
              onAvatarTap: _handleChangeAvatar,
            ),

            SizedBox(height: 2.h),

            // Performance Overview Section - NEW
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  PerformanceOverviewCardWidget(
                    performanceData: _performanceData,
                    onViewDetailsTap: () {
                      Navigator.pushNamed(context, '/test-results-analytics');
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Account Information
            AccountInfoSectionWidget(
              name: _userName,
              email: _userEmail,
              phone: _userPhone,
              currentClass: _currentClass,
              targetYear: _targetYear,
              onEditTap: _handleEditProfile,
            ),

            SizedBox(height: 2.h),

            // Settings Section
            SettingsSectionWidget(
              selectedTheme: _selectedTheme,
              videoQuality: _videoQuality,
              autoDownload: _autoDownload,
              language: _language,
              onThemeChanged: (value) {
                setState(() => _selectedTheme = value);
              },
              onVideoQualityChanged: (value) {
                setState(() => _videoQuality = value);
              },
              onAutoDownloadChanged: (value) {
                setState(() => _autoDownload = value);
              },
              onLanguageChanged: (value) {
                setState(() => _language = value);
              },
            ),

            SizedBox(height: 2.h),

            // Subscription management
            SubscriptionManagementWidget(
              currentPlan: _subscriptionStatus,
              renewalDate: _renewalDate,
              isActive: _isSubscriptionActive,
              onUpgradeTap: _handleUpgradeSubscription,
            ),

            // Download manager
            DownloadManagerWidget(
              usedStorage: _usedStorage,
              totalStorage: _totalStorage,
              downloadedItems: _downloadedItems,
              onManageTap: _handleManageDownloads,
            ),

            // Notification preferences
            NotificationPreferencesWidget(
              studyReminders: _studyReminders,
              newContentAlerts: _newContentAlerts,
              testNotifications: _testNotifications,
              onStudyRemindersChanged: (value) {
                setState(() => _studyReminders = value);
              },
              onNewContentAlertsChanged: (value) {
                setState(() => _newContentAlerts = value);
              },
              onTestNotificationsChanged: (value) {
                setState(() => _testNotifications = value);
              },
            ),

            // Security section
            SecuritySectionWidget(
              biometricEnabled: _biometricEnabled,
              onBiometricChanged: (value) {
                setState(() => _biometricEnabled = value);
              },
              onChangePasswordTap: _handleChangePassword,
              onManageSessionsTap: _handleManageSessions,
            ),

            // Support section
            SupportSectionWidget(
              onHelpCenterTap: _handleHelpCenter,
              onFeedbackTap: _handleFeedback,
              onContactTap: _handleContact,
              onYoutubeTap: _handleYoutubeTap,
            ),

            // Achievements showcase
            AchievementsShowcaseWidget(
              achievements: _achievements,
              onViewAllTap: _handleViewAllAchievements,
            ),

            // App version
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              padding: EdgeInsets.all(3.w),
              child: Column(
                children: [
                  Text(
                    'TBC Academy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    final routes = [
      '/dashboard-home',
      '/video-player',
      '/notes-library',
      '/mock-test-interface',
      '/profile-settings',
    ];

    if (index != 4) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  void _handleAvatarEdit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar editing feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleEditAccountInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account editing feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleUpgradeSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription upgrade feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleManageDownloads() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download management feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleChangePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password change feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleManageSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session management feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help center feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleYoutubeTap() async {
    const youtubeUrl = 'https://youtube.com/@thebraincord.academy';
    final uri = Uri.parse(youtubeUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open YouTube channel'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening YouTube channel'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleViewAllAchievements() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Achievements view feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogout() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login-screen');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _handleEditProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile editing feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleChangeAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar change feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDarkModeToggle() {
    setState(() {
      _selectedTheme = _selectedTheme == 'Dark' ? 'Auto' : 'Dark';
    });
  }

  void _handleNotificationsToggle() {
    setState(() {
      _studyReminders = !_studyReminders;
    });
  }
}
