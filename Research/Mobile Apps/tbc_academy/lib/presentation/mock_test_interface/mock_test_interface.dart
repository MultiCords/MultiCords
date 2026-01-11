import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/answer_options_widget.dart';
import './widgets/navigation_controls_widget.dart';
import './widgets/question_display_widget.dart';
import './widgets/question_palette_widget.dart';
import './widgets/test_header_widget.dart';

/// Mock Test Interface Screen
/// Provides comprehensive AI-generated NEET examination experience
class MockTestInterface extends StatefulWidget {
  const MockTestInterface({super.key});

  @override
  State<MockTestInterface> createState() => _MockTestInterfaceState();
}

class _MockTestInterfaceState extends State<MockTestInterface> {
  // Test state management
  int _currentQuestionIndex = 0;
  Timer? _testTimer;
  int _remainingSeconds = 10800; // 3 hours in seconds
  bool _isPaletteVisible = false;

  // Question status tracking
  final Map<int, QuestionStatus> _questionStatuses = {};
  final Map<int, String> _selectedAnswers = {};

  // Mock test data
  final List<Map<String, dynamic>> _testQuestions = [
    {
      "id": 1,
      "subject": "Physics",
      "question":
          "A particle moves in a circular path with constant speed. What is the nature of its acceleration?",
      "options": [
        "Zero acceleration",
        "Constant acceleration directed towards center",
        "Variable acceleration directed tangentially",
        "Constant acceleration directed away from center"
      ],
      "correctAnswer": "B",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 2,
      "subject": "Chemistry",
      "question":
          "Which of the following elements has the highest electronegativity?",
      "options": ["Fluorine", "Oxygen", "Nitrogen", "Chlorine"],
      "correctAnswer": "A",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 3,
      "subject": "Biology",
      "question": "The process of conversion of glucose to pyruvate is called:",
      "options": [
        "Krebs cycle",
        "Glycolysis",
        "Electron transport chain",
        "Oxidative phosphorylation"
      ],
      "correctAnswer": "B",
      "hasImage": true,
      "imageUrl":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1870e3553-1765728578742.png",
      "semanticLabel":
          "Diagram showing the glycolysis pathway with glucose molecule breaking down into pyruvate molecules through multiple enzymatic steps"
    },
    {
      "id": 4,
      "subject": "Physics",
      "question": "The dimensional formula for angular momentum is:",
      "options": ["[ML²T⁻¹]", "[MLT⁻²]", "[ML²T⁻²]", "[MLT⁻¹]"],
      "correctAnswer": "A",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 5,
      "subject": "Chemistry",
      "question": "Which of the following is an example of a Lewis acid?",
      "options": ["NH₃", "H₂O", "BF₃", "OH⁻"],
      "correctAnswer": "C",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 6,
      "subject": "Biology",
      "question":
          "DNA replication occurs during which phase of the cell cycle?",
      "options": ["G1 phase", "S phase", "G2 phase", "M phase"],
      "correctAnswer": "B",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 7,
      "subject": "Physics",
      "question":
          "The work done in moving a charge between two points in an electric field depends on:",
      "options": [
        "The path taken",
        "Only the initial and final positions",
        "The speed of movement",
        "The mass of the charge"
      ],
      "correctAnswer": "B",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 8,
      "subject": "Chemistry",
      "question": "The hybridization of carbon in methane (CH₄) is:",
      "options": ["sp", "sp²", "sp³", "sp³d"],
      "correctAnswer": "C",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 9,
      "subject": "Biology",
      "question": "Which hormone regulates blood glucose levels?",
      "options": ["Thyroxine", "Insulin", "Adrenaline", "Growth hormone"],
      "correctAnswer": "B",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    },
    {
      "id": 10,
      "subject": "Physics",
      "question": "The SI unit of magnetic flux is:",
      "options": ["Tesla", "Weber", "Henry", "Ampere"],
      "correctAnswer": "B",
      "hasImage": false,
      "imageUrl": "",
      "semanticLabel": ""
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeTest();
    _startTimer();
  }

  @override
  void dispose() {
    _testTimer?.cancel();
    super.dispose();
  }

  void _initializeTest() {
    // Initialize all questions as not answered
    for (int i = 0; i < _testQuestions.length; i++) {
      _questionStatuses[i] = QuestionStatus.notAnswered;
    }
    // Mark first question as current
    _questionStatuses[0] = QuestionStatus.current;
  }

  void _startTimer() {
    _testTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _submitTest();
      }
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
      if (_questionStatuses[_currentQuestionIndex] !=
          QuestionStatus.markedForReview) {
        _questionStatuses[_currentQuestionIndex] = QuestionStatus.answered;
      }
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < _testQuestions.length) {
      setState(() {
        // Update previous question status
        if (_questionStatuses[_currentQuestionIndex] ==
            QuestionStatus.current) {
          if (_selectedAnswers.containsKey(_currentQuestionIndex)) {
            _questionStatuses[_currentQuestionIndex] = QuestionStatus.answered;
          } else {
            _questionStatuses[_currentQuestionIndex] =
                QuestionStatus.notAnswered;
          }
        }

        _currentQuestionIndex = index;

        // Update current question status
        if (_questionStatuses[_currentQuestionIndex] !=
                QuestionStatus.markedForReview &&
            _questionStatuses[_currentQuestionIndex] !=
                QuestionStatus.answered) {
          _questionStatuses[_currentQuestionIndex] = QuestionStatus.current;
        }
      });
    }
  }

  void _markForReview() {
    setState(() {
      _questionStatuses[_currentQuestionIndex] = QuestionStatus.markedForReview;
    });
    HapticFeedback.mediumImpact();
  }

  void _togglePalette() {
    setState(() {
      _isPaletteVisible = !_isPaletteVisible;
    });
  }

  void _submitTest() {
    _testTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Submit Test',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to submit the test?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 2.h),
            _buildSubmitSummary(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/test-results-analytics');
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitSummary() {
    final answered = _questionStatuses.values
        .where((s) => s == QuestionStatus.answered)
        .length;
    final notAnswered = _questionStatuses.values
        .where((s) =>
            s == QuestionStatus.notAnswered || s == QuestionStatus.current)
        .length;
    final marked = _questionStatuses.values
        .where((s) => s == QuestionStatus.markedForReview)
        .length;

    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Answered', answered, AppTheme.secondaryLight),
          SizedBox(height: 1.h),
          _buildSummaryRow(
              'Not Answered', notAnswered, theme.colorScheme.onSurfaceVariant),
          SizedBox(height: 1.h),
          _buildSummaryRow('Marked for Review', marked, AppTheme.warningLight),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'physics':
        return const Color(0xFF1976D2);
      case 'chemistry':
        return const Color(0xFF7B1FA2);
      case 'biology':
        return const Color(0xFF388E3C);
      default:
        return AppTheme.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = _testQuestions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit Test',
              style: theme.textTheme.titleLarge,
            ),
            content: Text(
              'Are you sure you want to exit? Your progress will be lost.',
              style: theme.textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // Swipe right - previous question
                if (_currentQuestionIndex > 0) {
                  _navigateToQuestion(_currentQuestionIndex - 1);
                }
              } else if (details.primaryVelocity! < 0) {
                // Swipe left - next question
                if (_currentQuestionIndex < _testQuestions.length - 1) {
                  _navigateToQuestion(_currentQuestionIndex + 1);
                }
              }
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    // Test Header
                    TestHeaderWidget(
                      timeRemaining: _formatTime(_remainingSeconds),
                      currentQuestion: _currentQuestionIndex + 1,
                      totalQuestions: _testQuestions.length,
                      subject: currentQuestion['subject'] as String,
                      subjectColor: _getSubjectColor(
                          currentQuestion['subject'] as String),
                      onPalettePressed: _togglePalette,
                    ),

                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Display
                            QuestionDisplayWidget(
                              questionNumber: _currentQuestionIndex + 1,
                              questionText:
                                  currentQuestion['question'] as String,
                              hasImage: currentQuestion['hasImage'] as bool,
                              imageUrl: currentQuestion['imageUrl'] as String,
                              semanticLabel:
                                  currentQuestion['semanticLabel'] as String,
                            ),

                            SizedBox(height: 3.h),

                            // Answer Options
                            AnswerOptionsWidget(
                              options: (currentQuestion['options'] as List)
                                  .cast<String>(),
                              selectedAnswer:
                                  _selectedAnswers[_currentQuestionIndex],
                              onAnswerSelected: _selectAnswer,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Navigation Controls
                    NavigationControlsWidget(
                      canGoPrevious: _currentQuestionIndex > 0,
                      canGoNext:
                          _currentQuestionIndex < _testQuestions.length - 1,
                      onPrevious: () =>
                          _navigateToQuestion(_currentQuestionIndex - 1),
                      onNext: () =>
                          _navigateToQuestion(_currentQuestionIndex + 1),
                      onMarkForReview: _markForReview,
                      onSubmit: _submitTest,
                      isLastQuestion:
                          _currentQuestionIndex == _testQuestions.length - 1,
                    ),
                  ],
                ),

                // Question Palette Overlay
                if (_isPaletteVisible)
                  QuestionPaletteWidget(
                    totalQuestions: _testQuestions.length,
                    currentQuestion: _currentQuestionIndex,
                    questionStatuses: _questionStatuses,
                    onQuestionSelected: (index) {
                      _navigateToQuestion(index);
                      _togglePalette();
                    },
                    onClose: _togglePalette,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Question status enum
enum QuestionStatus {
  notAnswered,
  answered,
  markedForReview,
  current,
}
