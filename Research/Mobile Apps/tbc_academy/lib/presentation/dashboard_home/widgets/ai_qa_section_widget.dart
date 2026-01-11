import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/openai_service.dart';
import '../../../widgets/custom_icon_widget.dart';

/// AI-powered Q&A section widget for students
/// Allows students to ask NEET-related questions and get AI responses
class AiQaSectionWidget extends StatefulWidget {
  const AiQaSectionWidget({super.key});

  @override
  State<AiQaSectionWidget> createState() => _AiQaSectionWidgetState();
}

class _AiQaSectionWidgetState extends State<AiQaSectionWidget> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _selectedSubject = 'All Subjects';

  final List<String> _subjects = [
    'All Subjects',
    'Biology',
    'Physics',
    'Chemistry',
  ];

  late final OpenAIClient _openAIClient;

  @override
  void initState() {
    super.initState();
    try {
      _openAIClient = OpenAIClient(OpenAIService().dio);
    } catch (e) {
      // OpenAI not configured - show user friendly message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'AI features require OpenAI API key. Please configure it to use this feature.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleAskQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': question});
      _isLoading = true;
      _questionController.clear();
    });

    _scrollToBottom();

    try {
      final contextPrompt = _selectedSubject != 'All Subjects'
          ? 'As a NEET ${_selectedSubject} expert, '
          : 'As a NEET preparation expert, ';

      final messages = [
        Message(
          role: 'system',
          content: [
            {
              'type': 'text',
              'text': '${contextPrompt}provide clear, '
                  'accurate answers to help students prepare for NEET. '
                  'Include relevant concepts, examples, and tips.',
            },
          ],
        ),
        ..._messages
            .map((m) => Message(
                  role: m['role']!,
                  content: [
                    {'type': 'text', 'text': m['content']!},
                  ],
                ))
            .toList(),
      ];

      final response = await _openAIClient.createChatCompletion(
        messages: messages,
        model: 'gpt-5-mini',
        reasoningEffort: 'medium',
        options: {'max_completion_tokens': 500},
      );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': response.text});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Sorry, I encountered an error. Please try again.',
          });
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomIconWidget(
                  iconName: 'psychology',
                  size: 24,
                  color: Color(0xFF6366F1),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Assistant',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ask your NEET preparation questions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Subject filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _subjects.map((subject) {
                final isSelected = subject == _selectedSubject;
                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(subject),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSubject = subject);
                      }
                    },
                    selectedColor:
                        const Color(0xFF6366F1).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF6366F1),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 2.h),

          // Messages area
          Container(
            height: 30.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomIconWidget(
                          iconName: 'chat_bubble_outline',
                          size: 48,
                          color: Color(0xFF6366F1),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Ask me anything about NEET!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(3.w),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingMessage(theme);
                      }

                      final message = _messages[index];
                      final isUser = message['role'] == 'user';

                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    const Color(0xFF6366F1).withValues(
                                  alpha: 0.1,
                                ),
                                child: const CustomIconWidget(
                                  iconName: 'smart_toy',
                                  size: 20,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                              SizedBox(width: 2.w),
                            ],
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF6366F1)
                                      : theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['content']!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isUser
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              SizedBox(width: 2.w),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF6366F1),
                                child: const CustomIconWidget(
                                  iconName: 'person',
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),

          SizedBox(height: 2.h),

          // Input area
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'Type your question here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleAskQuestion(),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _handleAskQuestion,
                  icon: const CustomIconWidget(
                    iconName: 'send',
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
            child: const CustomIconWidget(
              iconName: 'smart_toy',
              size: 20,
              color: Color(0xFF6366F1),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Thinking...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
