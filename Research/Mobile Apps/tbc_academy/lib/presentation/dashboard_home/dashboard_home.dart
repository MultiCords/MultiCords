import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/ai_search_bar_widget.dart';
import './widgets/continue_watching_section_widget.dart';
import './widgets/creative_news_widget.dart';
import './widgets/featured_content_widget.dart';
import './widgets/neet_planner_widget.dart';
import './widgets/neet_subjects_section_widget.dart';
import './widgets/recommended_notes_section_widget.dart';
import './widgets/study_plan_card_widget.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int _currentBottomNavIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Mock data for student profile
  final Map<String, dynamic> _studentProfile = {
    "name": "Vijet Naik",
    "studyStreak": 15,
    "todayStudyTime": "3h 45m",
    "testsCompleted": 12,
    "averageScore": 78.5,
  };

  // Mock data for today's study plan
  final List<Map<String, dynamic>> _studyPlanItems = [
    {
      "id": 1,
      "subject": "Physics",
      "topic": "Electromagnetic Induction",
      "duration": "45 min",
      "type": "video",
      "completed": false,
      "icon": "play_circle",
      "color": 0xFF1B365D,
    },
    {
      "id": 2,
      "subject": "Chemistry",
      "topic": "Chemical Kinetics",
      "duration": "30 min",
      "type": "notes",
      "completed": false,
      "icon": "description",
      "color": 0xFF2E7D32,
    },
    {
      "id": 3,
      "subject": "Biology",
      "topic": "Human Reproduction",
      "duration": "60 min",
      "type": "test",
      "completed": true,
      "icon": "assignment",
      "color": 0xFFFF6B35,
    },
  ];

  // Mock data for recent activity
  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": 1,
      "title": "Thermodynamics - Laws and Applications",
      "subject": "Physics",
      "type": "video",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1d944a06b-1764664900237.png",
      "semanticLabel":
          "Physics textbook open on a wooden desk with equations and diagrams visible",
      "progress": 0.65,
      "duration": "45:30",
      "watchedTime": "29:30",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "title": "Organic Chemistry Reactions",
      "subject": "Chemistry",
      "type": "notes",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_106985329-1764681609661.png",
      "semanticLabel":
          "Chemistry laboratory glassware with colorful liquids on a white background",
      "downloadDate": DateTime.now().subtract(const Duration(days: 1)),
      "pages": 24,
    },
  ];

  // Mock data for performance overview
  final Map<String, dynamic> _performanceData = {
    "physics": {"score": 82, "tests": 4, "color": 0xFF1B365D},
    "chemistry": {"score": 75, "tests": 4, "color": 0xFF2E7D32},
    "biology": {"score": 79, "tests": 4, "color": 0xFFFF6B35},
    "overall": 78.5,
  };

  // Updated NEET news with external URLs
  final List<Map<String, dynamic>> _neetNews = [
    {
      "id": 1,
      "title": "NEET 2025 Registration Dates Announced",
      "excerpt":
          "National Testing Agency releases official notification for NEET-UG 2025 examination schedule...",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_109e0e4bc-1765304048912.png",
      "semanticLabel":
          "Student writing notes in a notebook with laptop and coffee cup on desk",
      "publishedDate": DateTime.now().subtract(const Duration(hours: 5)),
      "category": "Important Update",
      "externalUrl": "https://neet.nta.nic.in/",
    },
    {
      "id": 2,
      "title": "New Study Pattern for Biology Section",
      "excerpt":
          "Experts recommend revised approach for tackling NEET Biology questions based on recent trends...",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_169928533-1765116211121.png",
      "semanticLabel":
          "Open biology textbook showing detailed anatomical diagrams and illustrations",
      "publishedDate": DateTime.now().subtract(const Duration(days: 1)),
      "category": "Study Tips",
      "externalUrl": "https://neet.nta.nic.in/",
    },
    {
      "id": 3,
      "title": "NEET Counselling Process Updates",
      "excerpt":
          "Latest information on medical counselling process for NEET qualified candidates...",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_155412790-1765302671636.png",
      "semanticLabel":
          "Medical students in white coats attending counseling session",
      "publishedDate": DateTime.now().subtract(const Duration(days: 2)),
      "category": "Counselling",
      "externalUrl": "https://www.mcc.nic.in/",
    },
  ];

  // Mock data for continue watching
  final List<Map<String, dynamic>> _continueWatchingVideos = [
    {
      "id": 1,
      "title": "Newton's Laws of Motion",
      "subject": "Physics",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1208d1e24-1764693566640.png",
      "semanticLabel":
          "Physics concept illustration showing force and motion diagrams on a blackboard",
      "duration": "42:15",
      "progress": 0.45,
      "instructor": "Dr. Rajesh Kumar",
    },
    {
      "id": 2,
      "title": "Cell Division - Mitosis & Meiosis",
      "subject": "Biology",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_117b7f9f8-1764927447295.png",
      "semanticLabel":
          "Microscopic view of cells dividing showing chromosomes and cell structures",
      "duration": "38:50",
      "progress": 0.72,
      "instructor": "Dr. Meera Patel",
    },
    {
      "id": 3,
      "title": "Periodic Table Trends",
      "subject": "Chemistry",
      "thumbnail":
          "https://images.unsplash.com/photo-1580951830551-abe9be6a7f53",
      "semanticLabel":
          "Colorful periodic table of elements displayed on a modern digital screen",
      "duration": "35:20",
      "progress": 0.28,
      "instructor": "Prof. Amit Singh",
    },
  ];

  // Mock data for recommended notes
  final List<Map<String, dynamic>> _recommendedNotes = [
    {
      "id": 1,
      "title": "Electromagnetic Waves - Complete Notes",
      "subject": "Physics",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e8bf093e-1764663757317.png",
      "semanticLabel":
          "Physics notes with electromagnetic wave diagrams and equations on white paper",
      "pages": 18,
      "isPaid": false,
      "downloads": 1250,
      "rating": 4.8,
    },
    {
      "id": 2,
      "title": "Human Physiology - System Wise",
      "subject": "Biology",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_169928533-1765116211121.png",
      "semanticLabel":
          "Biology textbook showing detailed human body system diagrams and annotations",
      "pages": 32,
      "isPaid": true,
      "price": "\\₹99",
      "downloads": 2340,
      "rating": 4.9,
    },
    {
      "id": 3,
      "title": "Organic Reactions - Quick Revision",
      "subject": "Chemistry",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_16c46fae9-1764663760557.png",
      "semanticLabel":
          "Chemistry notes showing organic reaction mechanisms with molecular structures",
      "pages": 24,
      "isPaid": false,
      "downloads": 1890,
      "rating": 4.7,
    },
  ];

  // Mock data for featured content
  final List<Map<String, dynamic>> _featuredContent = [
    {
      "id": 1,
      "title": "Complete Human Anatomy - NEET Special Series",
      "subject": "Biology",
      "subjectColor": 0xFFFF6B35,
      "type": "video",
      "thumbnail":
          "https://images.pexels.com/photos/256262/pexels-photo-256262.jpeg",
      "semanticLabel":
          "Medical anatomy textbook with detailed human body diagrams and colorful illustrations",
      "views": "12.5K",
      "rating": 4.9,
      "instructor": "Dr. Meera Patel",
    },
    {
      "id": 2,
      "title": "Mechanics & Laws of Motion - Problem Solving",
      "subject": "Physics",
      "subjectColor": 0xFF1B365D,
      "type": "video",
      "thumbnail":
          "https://images.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg",
      "semanticLabel":
          "Physics classroom with student solving mechanics problems on whiteboard",
      "views": "8.2K",
      "rating": 4.8,
      "instructor": "Dr. Rajesh Kumar",
    },
    {
      "id": 3,
      "title": "Organic Chemistry Reactions - Quick Reference",
      "subject": "Chemistry",
      "subjectColor": 0xFF2E7D32,
      "type": "notes",
      "thumbnail": "https://images.unsplash.com/photo-1532634993-15f421e42ec0",
      "semanticLabel":
          "Chemistry notes with organic reaction mechanisms and molecular structures",
      "views": "15.8K",
      "rating": 4.9,
      "instructor": "Prof. Amit Singh",
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh with haptic feedback
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard updated successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Navigate to respective screens based on index
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.videosLibrary);
        break;
      case 2:
        Navigator.pushNamed(context, '/notes-library');
        break;
      case 3:
        Navigator.pushNamed(context, '/mock-test-interface');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile-settings');
        break;
    }
  }

  void _handleStartMockTest() {
    Navigator.pushNamed(context, AppRoutes.mockTestInterface);
  }

  void _handleNotificationTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening notifications...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // TODO: Navigate to notifications screen
  }

  void _handleStudyPlanItemTap(Map<String, dynamic> item) {
    final type = item['type'] as String;

    switch (type) {
      case 'video':
        Navigator.pushNamed(context, AppRoutes.videosLibrary);
        break;
      case 'notes':
        Navigator.pushNamed(context, AppRoutes.notesLibrary);
        break;
      case 'test':
        Navigator.pushNamed(context, AppRoutes.mockTestInterface);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${item['topic']}...'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _handleQuickStatTap(String statType) {
    switch (statType) {
      case 'study_time':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('View detailed study time breakdown'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'tests':
        Navigator.pushNamed(context, AppRoutes.testResultsAnalytics);
        break;
      case 'average':
        Navigator.pushNamed(context, AppRoutes.testResultsAnalytics);
        break;
    }
  }

  void _handleContentLongPress(String contentType, int contentId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                _buildQuickActionItem(
                  context,
                  icon: 'bookmark_border',
                  label: 'Bookmark',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to bookmarks')),
                    );
                  },
                ),
                _buildQuickActionItem(
                  context,
                  icon: 'share',
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share functionality coming soon'),
                      ),
                    );
                  },
                ),
                _buildQuickActionItem(
                  context,
                  icon: 'download',
                  label: 'Download',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download started')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSubjectTap(String subject) {
    // Navigate to subject-specific content page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $subject content...'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // TODO: Navigate to subject filter page
  }

  void _handleQuickActionTap(String actionType) {
    switch (actionType) {
      case 'videos':
        Navigator.pushNamed(context, AppRoutes.videosLibrary);
        break;
      case 'notes':
        Navigator.pushNamed(context, '/notes-library');
        break;
      case 'tests':
        Navigator.pushNamed(context, '/mock-test-interface');
        break;
      case 'analytics':
        Navigator.pushNamed(context, '/test-results-analytics');
        break;
    }
  }

  void _handleFeaturedContentTap(int contentId, String type) {
    if (type == 'video') {
      Navigator.pushNamed(context, AppRoutes.videosLibrary);
    } else {
      Navigator.pushNamed(context, '/notes-library');
    }
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
            SizedBox(width: 4.w),
            Text(label, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header with student info
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${_studentProfile["name"]}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'local_fire_department',
                                    size: 16,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${_studentProfile["studyStreak"]} day streak',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: _handleNotificationTap,
                              borderRadius: BorderRadius.circular(12),
                              child: CustomIconWidget(
                                iconName: 'notifications_outlined',
                                size: 24,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          _buildQuickStat(
                            context,
                            icon: 'schedule',
                            label: 'Today',
                            value: _studentProfile["todayStudyTime"],
                            onTap: () => _handleQuickStatTap('study_time'),
                          ),
                          SizedBox(width: 4.w),
                          _buildQuickStat(
                            context,
                            icon: 'assignment_turned_in',
                            label: 'Tests',
                            value: '${_studentProfile["testsCompleted"]}',
                            onTap: () => _handleQuickStatTap('tests'),
                          ),
                          SizedBox(width: 4.w),
                          _buildQuickStat(
                            context,
                            icon: 'trending_up',
                            label: 'Avg Score',
                            value: '${_studentProfile["averageScore"]}%',
                            onTap: () => _handleQuickStatTap('average'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // AI Search Bar - NEW POSITION
              const SliverToBoxAdapter(
                child: AiSearchBarWidget(),
              ),

              // Main content - UPDATED ORDER
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 2.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // NEET Subjects Section - FIRST POSITION
                    NeetSubjectsSectionWidget(onSubjectTap: _handleSubjectTap),
                    SizedBox(height: 3.h),

                    // AI Planner - MOVED UP (AI QA Action Button removed)
                    const NeetPlannerWidget(),
                    SizedBox(height: 3.h),

                    // Featured Content - EXISTING
                    FeaturedContentWidget(
                      featuredItems: _featuredContent,
                      onContentTap: _handleFeaturedContentTap,
                    ),
                    SizedBox(height: 3.h),

                    // Today's Study Plan - EXISTING
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: StudyPlanCardWidget(
                        studyPlanItems: _studyPlanItems,
                        onItemTap: _handleStudyPlanItemTap,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Continue Watching Section - EXISTING
                    ContinueWatchingSectionWidget(
                      videos: _continueWatchingVideos,
                      onVideoTap: (videoId) {
                        Navigator.pushNamed(context, AppRoutes.videosLibrary);
                      },
                      onVideoLongPress: (videoId) {
                        _handleContentLongPress('video', videoId);
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Recommended Notes Section - EXISTING
                    RecommendedNotesSectionWidget(
                      notes: _recommendedNotes,
                      onNoteTap: (noteId) {
                        Navigator.pushNamed(context, '/notes-library');
                      },
                      onNoteLongPress: (noteId) {
                        _handleContentLongPress('note', noteId);
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Creative NEET News - EXISTING
                    CreativeNewsWidget(
                      newsItems: _neetNews,
                      onViewAllTap: () {
                        Navigator.pushNamed(context, '/neet-news-feed');
                      },
                    ),
                    SizedBox(height: 10.h),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
