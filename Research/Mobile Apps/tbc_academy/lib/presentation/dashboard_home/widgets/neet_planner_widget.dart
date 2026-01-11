import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/openai_service.dart';
import '../../../widgets/custom_icon_widget.dart';

/// NEET study planner widget with AI-powered recommendations
/// Helps students create personalized study plans based on their goals
class NeetPlannerWidget extends StatefulWidget {
  const NeetPlannerWidget({super.key});

  @override
  State<NeetPlannerWidget> createState() => _NeetPlannerWidgetState();
}

class _NeetPlannerWidgetState extends State<NeetPlannerWidget> {
  bool _isExpanded = false;
  bool _isGenerating = false;
  String? _generatedPlan;

  final Map<String, bool> _weakSubjects = {
    'Biology': false,
    'Physics': false,
    'Chemistry': false,
  };

  int _dailyHours = 4;
  String _preparationLevel = 'Intermediate';

  late final OpenAIClient _openAIClient;

  @override
  void initState() {
    super.initState();
    try {
      _openAIClient = OpenAIClient(OpenAIService().dio);
    } catch (e) {
      // OpenAI not configured
    }
  }

  Future<void> _generateStudyPlan() async {
    setState(() {
      _isGenerating = true;
      _generatedPlan = null;
    });

    try {
      final weakSubjects = _weakSubjects.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      if (weakSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one subject to focus on'),
          ),
        );
        setState(() => _isGenerating = false);
        return;
      }

      final prompt = '''
Create a personalized NEET study plan with these details:
- Preparation Level: $_preparationLevel
- Daily Study Hours: $_dailyHours hours
- Focus Subjects: ${weakSubjects.join(', ')}
- Target Exam: NEET 2026

Please provide:
1. Weekly study schedule with specific topics
2. Daily routine breakdown
3. Topic prioritization strategy
4. Revision schedule recommendations
5. Practice test frequency

Keep it concise and actionable (max 400 words).
''';

      final messages = [
        Message(
          role: 'system',
          content: [
            {
              'type': 'text',
              'text': 'You are an expert NEET preparation advisor. '
                  'Create practical, achievable study plans that help '
                  'students succeed in NEET exams.',
            },
          ],
        ),
        Message(
          role: 'user',
          content: [
            {'type': 'text', 'text': prompt},
          ],
        ),
      ];

      final response = await _openAIClient.createChatCompletion(
        messages: messages,
        model: 'gpt-5-mini',
        reasoningEffort: 'medium',
        options: {'max_completion_tokens': 600},
      );

      if (mounted) {
        setState(() {
          _generatedPlan = response.text;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating plan: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomIconWidget(
                  iconName: 'event_note',
                  size: 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI NEET Planner',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Get personalized study plan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: CustomIconWidget(
                  iconName: _isExpanded ? 'expand_less' : 'expand_more',
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          if (_isExpanded) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preparation Level',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Beginner',
                        label: Text('Beginner'),
                      ),
                      ButtonSegment(
                        value: 'Intermediate',
                        label: Text('Intermediate'),
                      ),
                      ButtonSegment(
                        value: 'Advanced',
                        label: Text('Advanced'),
                      ),
                    ],
                    selected: {_preparationLevel},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _preparationLevel = newSelection.first;
                      });
                    },
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Daily Study Hours: $_dailyHours',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _dailyHours.toDouble(),
                    min: 2,
                    max: 8,
                    divisions: 6,
                    label: '$_dailyHours hours',
                    onChanged: (value) {
                      setState(() => _dailyHours = value.toInt());
                    },
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Focus Subjects',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ..._weakSubjects.entries.map((entry) {
                    return CheckboxListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      onChanged: (bool? value) {
                        setState(() {
                          _weakSubjects[entry.key] = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateStudyPlan,
                      icon: _isGenerating
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const CustomIconWidget(
                              iconName: 'auto_awesome',
                              size: 20,
                              color: Colors.white,
                            ),
                      label: Text(
                        _isGenerating ? 'Generating...' : 'Generate Plan',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                  if (_generatedPlan != null) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CustomIconWidget(
                                iconName: 'check_circle',
                                size: 20,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Your Personalized Plan',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _generatedPlan!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
