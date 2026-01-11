import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/comparison_section_widget.dart';
import './widgets/detailed_analysis_widget.dart';
import './widgets/overall_score_card_widget.dart';
import './widgets/question_review_widget.dart';
import './widgets/subject_performance_widget.dart';
import './widgets/time_analysis_widget.dart';

/// Test Results & Analytics Screen
/// Provides comprehensive performance analysis for NEET aspirants
class TestResultsAnalytics extends StatefulWidget {
  const TestResultsAnalytics({super.key});

  @override
  State<TestResultsAnalytics> createState() => _TestResultsAnalyticsState();
}

class _TestResultsAnalyticsState extends State<TestResultsAnalytics>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3; // Tests tab
  String _selectedFilter = 'All';

  // Mock test results data
  final Map<String, dynamic> _testResults = {
    "testId": "NEET_MOCK_2024_12_14",
    "testName": "NEET Full Length Mock Test - 14",
    "completedAt": "2025-12-14T14:30:00",
    "overallScore": 650,
    "maxScore": 720,
    "percentile": 94.5,
    "timeTaken": "02:45:30",
    "totalTime": "03:00:00",
    "rank": 1250,
    "totalAttempts": 23450,
    "subjects": [
      {
        "name": "Physics",
        "score": 160,
        "maxScore": 180,
        "correct": 40,
        "incorrect": 5,
        "unattempted": 0,
        "accuracy": 88.9,
        "timeTaken": "00:52:15",
        "avgTimePerQuestion": "01:10"
      },
      {
        "name": "Chemistry",
        "score": 168,
        "maxScore": 180,
        "correct": 42,
        "incorrect": 3,
        "unattempted": 0,
        "accuracy": 93.3,
        "timeTaken": "00:48:20",
        "avgTimePerQuestion": "01:04"
      },
      {
        "name": "Biology",
        "score": 322,
        "maxScore": 360,
        "correct": 82,
        "incorrect": 7,
        "unattempted": 1,
        "accuracy": 92.1,
        "timeTaken": "01:04:55",
        "avgTimePerQuestion": "00:43"
      }
    ],
    "detailedAnalysis": {
      "totalQuestions": 180,
      "correct": 164,
      "incorrect": 15,
      "unattempted": 1,
      "positiveMarks": 656,
      "negativeMarks": -6
    },
    "timeAnalysis": {
      "fastQuestions": 45,
      "optimalQuestions": 120,
      "slowQuestions": 14,
      "avgTimePerQuestion": "00:55",
      "recommendation":
          "Good pacing overall. Focus on reducing time for Physics numerical problems."
    },
    "comparison": {
      "previousAttempts": [
        {"testName": "Mock Test 13", "score": 620, "percentile": 92.1},
        {"testName": "Mock Test 12", "score": 595, "percentile": 89.5},
        {"testName": "Mock Test 11", "score": 610, "percentile": 90.8}
      ],
      "peerAverage": 545,
      "topperScore": 705,
      "improvement": "+30 marks from last attempt"
    },
    "achievements": [
      {
        "title": "Biology Master",
        "description": "Scored above 90% in Biology",
        "icon": "eco"
      },
      {
        "title": "Consistent Performer",
        "description": "Improved score in last 3 attempts",
        "icon": "trending_up"
      },
      {
        "title": "Speed Champion",
        "description": "Completed test 15 minutes early",
        "icon": "speed"
      }
    ],
    "recommendations": [
      "Focus on Physics numerical problems - average time is 20% higher",
      "Excellent Chemistry performance - maintain this consistency",
      "Review unattempted Biology question for concept clarity",
      "Consider attempting more mock tests to improve speed further"
    ]
  };

  // Mock questions data for review
  final List<Map<String, dynamic>> _questions = [
    {
      "id": 1,
      "subject": "Physics",
      "topic": "Mechanics",
      "question":
          "A body of mass 2 kg is moving with velocity 10 m/s. What is its kinetic energy?",
      "options": ["50 J", "100 J", "150 J", "200 J"],
      "correctAnswer": 1,
      "userAnswer": 1,
      "status": "correct",
      "timeTaken": "01:15",
      "explanation":
          "Kinetic Energy = (1/2)mv² = (1/2)(2)(10)² = 100 J. The formula for kinetic energy is derived from work-energy theorem.",
      "relatedVideoUrl": "https://example.com/physics/mechanics/kinetic-energy"
    },
    {
      "id": 2,
      "subject": "Chemistry",
      "topic": "Organic Chemistry",
      "question": "Which of the following is an aromatic compound?",
      "options": ["Cyclohexane", "Benzene", "Cyclohexene", "Hexane"],
      "correctAnswer": 1,
      "userAnswer": 1,
      "status": "correct",
      "timeTaken": "00:45",
      "explanation":
          "Benzene is aromatic as it follows Hückel's rule (4n+2 π electrons) with 6 π electrons in a planar cyclic structure.",
      "relatedVideoUrl":
          "https://example.com/chemistry/organic/aromatic-compounds"
    },
    {
      "id": 3,
      "subject": "Biology",
      "topic": "Cell Biology",
      "question": "Which organelle is known as the powerhouse of the cell?",
      "options": [
        "Nucleus",
        "Mitochondria",
        "Ribosome",
        "Endoplasmic Reticulum"
      ],
      "correctAnswer": 1,
      "userAnswer": 1,
      "status": "correct",
      "timeTaken": "00:30",
      "explanation":
          "Mitochondria produce ATP through cellular respiration, providing energy for cellular processes. They have their own DNA and double membrane.",
      "relatedVideoUrl": "https://example.com/biology/cell/mitochondria"
    },
    {
      "id": 4,
      "subject": "Physics",
      "topic": "Electrostatics",
      "question":
          "Two charges of +2μC and -3μC are placed 10 cm apart. What is the nature of force between them?",
      "options": [
        "Repulsive",
        "Attractive",
        "No force",
        "Cannot be determined"
      ],
      "correctAnswer": 1,
      "userAnswer": 0,
      "status": "incorrect",
      "timeTaken": "02:10",
      "explanation":
          "Unlike charges attract each other. The force is attractive as per Coulomb's law. Opposite charges always experience attractive force.",
      "relatedVideoUrl":
          "https://example.com/physics/electrostatics/coulomb-law"
    },
    {
      "id": 5,
      "subject": "Chemistry",
      "topic": "Chemical Bonding",
      "question": "What type of bond is present in NaCl?",
      "options": ["Covalent", "Ionic", "Metallic", "Hydrogen"],
      "correctAnswer": 1,
      "userAnswer": null,
      "status": "unattempted",
      "timeTaken": "00:00",
      "explanation":
          "NaCl has ionic bonding formed by electron transfer from Na to Cl, creating Na⁺ and Cl⁻ ions held by electrostatic attraction.",
      "relatedVideoUrl": "https://example.com/chemistry/bonding/ionic-compounds"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Test Results & Analytics',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _shareResults,
            tooltip: 'Share Results',
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'download',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _exportPDF,
            tooltip: 'Export PDF',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Score Card
            OverallScoreCardWidget(testResults: _testResults),

            SizedBox(height: 2.h),

            // Subject Performance
            SubjectPerformanceWidget(
              subjects: (_testResults["subjects"] as List)
                  .cast<Map<String, dynamic>>(),
            ),

            SizedBox(height: 2.h),

            // Detailed Analysis
            DetailedAnalysisWidget(
              analysis:
                  _testResults["detailedAnalysis"] as Map<String, dynamic>,
            ),

            SizedBox(height: 2.h),

            // Time Analysis
            TimeAnalysisWidget(
              timeAnalysis:
                  _testResults["timeAnalysis"] as Map<String, dynamic>,
            ),

            SizedBox(height: 2.h),

            // Comparison Section
            ComparisonSectionWidget(
              comparison: _testResults["comparison"] as Map<String, dynamic>,
            ),

            SizedBox(height: 2.h),

            // Achievements Section
            _buildAchievementsSection(theme),

            SizedBox(height: 2.h),

            // Recommendations Section
            _buildRecommendationsSection(theme),

            SizedBox(height: 2.h),

            // Question Review Section
            QuestionReviewWidget(
              questions: _questions,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedFilter: _selectedFilter,
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildAchievementsSection(ThemeData theme) {
    final achievements =
        (_testResults["achievements"] as List).cast<Map<String, dynamic>>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'emoji_events',
                color: theme.colorScheme.tertiary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Achievements Unlocked',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: achievement["icon"] as String,
                        color: theme.colorScheme.onTertiary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement["title"] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            achievement["description"] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(ThemeData theme) {
    final recommendations =
        (_testResults["recommendations"] as List).cast<String>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: theme.colorScheme.secondary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Personalized Recommendations',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 0.5.h),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      recommendations[index],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Navigate based on index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard-home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/video-player');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/notes-library');
        break;
      case 3:
        // Current screen - do nothing
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile-settings');
        break;
    }
  }

  void _shareResults() {
    // Share functionality implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Results shared successfully!',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exportPDF() {
    // PDF export functionality implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'PDF report generated successfully!',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}