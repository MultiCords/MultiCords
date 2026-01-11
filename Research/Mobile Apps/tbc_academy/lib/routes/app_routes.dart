import 'package:flutter/material.dart';

import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/mock_test_interface/mock_test_interface.dart';
import '../presentation/neet_news_feed/neet_news_feed.dart';
import '../presentation/notes_library/notes_library.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/signup_screen/signup_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/test_results_analytics/test_results_analytics.dart';
import '../presentation/video_player/video_player.dart';
import '../presentation/videos_library/videos_library.dart';

class AppRoutes {
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String signupScreen = '/signup';
  static const String dashboardHome = '/dashboard-home';
  static const String videoPlayer = '/video-player';
  static const String notesLibrary = '/notes-library';
  static const String mockTestInterface = '/mock-test-interface';
  static const String neetNewsFeed = '/neet-news-feed';
  static const String profileSettings = '/profile-settings';
  static const String testResultsAnalytics = '/test-results-analytics';
  static const String videosLibrary = '/videos-library';

  static Map<String, WidgetBuilder> get routes => {
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    signupScreen: (context) => const SignupScreen(),
    dashboardHome: (context) => const DashboardHome(),
    videoPlayer: (context) => const VideoPlayer(),
    notesLibrary: (context) => const NotesLibrary(),
    mockTestInterface: (context) => const MockTestInterface(),
    neetNewsFeed: (context) => const NeetNewsFeed(),
    profileSettings: (context) => const ProfileSettings(),
    testResultsAnalytics: (context) => const TestResultsAnalytics(),
    videosLibrary: (context) => const VideosLibrary(),
  };
}
