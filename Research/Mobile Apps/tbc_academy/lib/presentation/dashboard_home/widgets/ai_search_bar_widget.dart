import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/openai_service.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Enhanced AI Q&A search bar widget for students
/// Provides quick access to AI assistance with subject selection and pre-made questions
class AiSearchBarWidget extends StatefulWidget {
  const AiSearchBarWidget({super.key});

  @override
  State<AiSearchBarWidget> createState() => _AiSearchBarWidgetState();
}

class _AiSearchBarWidgetState extends State<AiSearchBarWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isExpanded = false;
  bool _isLoading = false;
  String? _lastResponse;
  String _selectedSubject = 'General';
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  OpenAIClient? _openAIClient;

  // Subject categories with icons
  final Map<String, Map<String, dynamic>> _subjects = {
    'General': {
      'icon': 'psychology',
      'color': const Color(0xFF6366F1),
      'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    },
    'Physics': {
      'icon': 'flash_on',
      'color': const Color(0xFFEF4444),
      'gradient': [const Color(0xFFEF4444), const Color(0xFFEC4899)],
    },
    'Chemistry': {
      'icon': 'science',
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF10B981), const Color(0xFF06B6D4)],
    },
    'Biology': {
      'icon': 'local_florist',
      'color': const Color(0xFFF59E0B),
      'gradient': [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
    },
  };

  // Quick question suggestions for each subject
  final Map<String, List<String>> _quickQuestions = {
    'General': [
      'NEET exam pattern 2024',
      'Best preparation strategy',
      'Important topics for NEET',
      'Time management tips',
    ],
    'Physics': [
      'Laws of motion concepts',
      'Electromagnetic induction',
      'Optics and wave theory',
      'Thermodynamics basics',
    ],
    'Chemistry': [
      'Periodic table trends',
      'Chemical bonding types',
      'Organic reactions',
      'Coordination compounds',
    ],
    'Biology': [
      'Cell structure and function',
      'Genetics and evolution',
      'Human physiology',
      'Plant reproduction',
    ],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceOut),
    );

    try {
      _openAIClient = OpenAIClient(OpenAIService().dio);
    } catch (e) {
      // OpenAI not configured - will show friendly message
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch([String? predefinedQuery]) async {
    final query = predefinedQuery ?? _searchController.text.trim();
    if (query.isEmpty) return;

    // Set the text field if using predefined query
    if (predefinedQuery != null) {
      _searchController.text = predefinedQuery;
    }

    if (_openAIClient == null) {
      _showErrorMessage(
        'AI features are not configured. Please contact your administrator.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      // Enhanced system prompt based on selected subject
      final systemPrompt = _selectedSubject == 'General'
          ? 'You are a NEET exam preparation expert. Provide concise, accurate answers to help students. Keep responses under 150 words and focus on key concepts. Use bullet points when listing multiple items.'
          : 'You are a NEET ${_selectedSubject} expert. Provide concise, accurate answers specifically related to ${_selectedSubject} concepts for NEET preparation. Keep responses under 150 words, focus on key concepts, and use examples when helpful. Use bullet points when listing multiple items.';

      final messages = [
        Message(
          role: 'system',
          content: [
            {'type': 'text', 'text': systemPrompt},
          ],
        ),
        Message(
          role: 'user',
          content: [
            {'type': 'text', 'text': query},
          ],
        ),
      ];

      final response = await _openAIClient!.createChatCompletion(
        messages: messages,
        model: 'gpt-4o-mini',
        options: {'max_tokens': 200, 'temperature': 0.7},
      );

      if (mounted) {
        setState(() {
          _lastResponse = response.text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Unable to get AI response. ';
        if (e is OpenAIException) {
          if (e.statusCode == 401) {
            errorMessage += 'Please check API configuration.';
          } else if (e.statusCode == 429) {
            errorMessage += 'Too many requests. Please try again in a moment.';
          } else {
            errorMessage += 'Please try again later.';
          }
        } else {
          errorMessage += 'Please check your internet connection.';
        }

        _showErrorMessage(errorMessage);
      }
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _lastResponse = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _lastResponse = null;
        _searchController.clear();
      }
    });
  }

  void _selectSubject(String subject) {
    setState(() {
      _selectedSubject = subject;
      _lastResponse = null; // Clear previous response when changing subject
    });
  }

  Widget _buildSubjectChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _subjects.entries.map((entry) {
          final subject = entry.key;
          final data = entry.value;
          final isSelected = _selectedSubject == subject;

          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => _selectSubject(subject),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: data['gradient'] as List<Color>,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : data['color'].withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: data['color'] as Color,
                      width: isSelected ? 0 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (data['color'] as Color).withAlpha(
                                51,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: data['icon'] as String,
                        size: 18,
                        color:
                            isSelected ? Colors.white : data['color'] as Color,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        subject,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : data['color'] as Color,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickQuestions() {
    final questions = _quickQuestions[_selectedSubject] ?? [];
    final subjectData = _subjects[_selectedSubject]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Text(
            'Quick Questions',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: subjectData['color'] as Color,
            ),
          ),
        ),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: questions.map((question) {
            return GestureDetector(
              onTap: () => _handleSearch(question),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  color: (subjectData['color'] as Color).withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (subjectData['color'] as Color).withAlpha(51),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'help_outline',
                      size: 16,
                      color: subjectData['color'] as Color,
                    ),
                    SizedBox(width: 1.w),
                    Flexible(
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: subjectData['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectData = _subjects[_selectedSubject]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (subjectData['color'] as Color).withAlpha(26),
            (subjectData['gradient'] as List<Color>)[1].withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (subjectData['color'] as Color).withAlpha(77),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (subjectData['color'] as Color).withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subject selection chips
          _buildSubjectChips(),

          SizedBox(height: 2.h),

          // Search bar
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: subjectData['gradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (subjectData['color'] as Color).withAlpha(51),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: subjectData['icon'] as String,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ask any $_selectedSubject question...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _handleSearch(),
                  onTap: () {
                    if (!_isExpanded) _toggleExpansion();
                  },
                ),
              ),
              if (_isExpanded) ...[
                if (_isLoading)
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        subjectData['color'] as Color,
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () => _handleSearch(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: subjectData['color'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const CustomIconWidget(
                        iconName: 'send',
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                SizedBox(width: 2.w),
              ],
              IconButton(
                onPressed: _toggleExpansion,
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isExpanded ? 0.5 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (subjectData['color'] as Color).withAlpha(38),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _isExpanded ? 'expand_less' : 'expand_more',
                      size: 20,
                      color: subjectData['color'] as Color,
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // Expanded content with animations
          if (_isExpanded)
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Quick questions section
                      _buildQuickQuestions(),

                      SizedBox(height: 2.h),
                      Divider(
                        color: (subjectData['color'] as Color).withAlpha(51),
                        thickness: 1,
                      ),
                      SizedBox(height: 2.h),

                      // AI Response section
                      if (_lastResponse != null)
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withAlpha(230),
                                Colors.white.withAlpha(204),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (subjectData['color'] as Color).withAlpha(
                                77,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (subjectData['color'] as Color)
                                    .withAlpha(25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: subjectData['gradient']
                                            as List<Color>,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const CustomIconWidget(
                                      iconName: 'smart_toy',
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'AI Response',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: subjectData['color'] as Color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (subjectData['color'] as Color)
                                          .withAlpha(26),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _selectedSubject,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: subjectData['color'] as Color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _lastResponse!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!_isLoading)
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: (subjectData['color'] as Color)
                                      .withAlpha(26),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: CustomIconWidget(
                                  iconName: 'lightbulb_outline',
                                  size: 32,
                                  color: subjectData['color'] as Color,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Ask a question or tap a suggestion above',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
