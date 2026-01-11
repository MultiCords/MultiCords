import 'package:dio/dio.dart';

/// OpenAI Service for managing API interactions
/// Singleton pattern ensures single instance manages all OpenAI API calls
class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');

  /// Factory constructor to return the singleton instance
  factory OpenAIService() {
    return _instance;
  }

  /// Private constructor for singleton pattern
  OpenAIService._internal() {
    _initializeService();
  }

  void _initializeService() {
    // Load API key from environment variables
    if (apiKey.isEmpty) {
      throw Exception(
        'OPENAI_API_KEY must be provided via --dart-define',
      );
    }

    // Configure Dio with base URL and headers
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Dio get dio => _dio;
}

/// OpenAI Client for interacting with OpenAI API endpoints
class OpenAIClient {
  final Dio dio;

  OpenAIClient(this.dio);

  /// Create chat completion with GPT models
  /// Uses gpt-4o-mini (GPT-4 optimized mini) for educational Q&A
  Future<Completion> createChatCompletion({
    required List<Message> messages,
    String model = 'gpt-4o-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList(),
      };

      // Handle options based on model type
      if (options != null) {
        final filteredOptions = Map<String, dynamic>.from(options);

        // For o-series models (o1, o3, o4), remove unsupported parameters
        if (model.startsWith('o1') ||
            model.startsWith('o3') ||
            model.startsWith('o4')) {
          filteredOptions.removeWhere((key, value) => [
                'temperature',
                'top_p',
                'presence_penalty',
                'frequency_penalty',
                'logit_bias',
              ].contains(key));

          // Convert max_tokens to max_completion_tokens for o-series
          if (filteredOptions.containsKey('max_tokens')) {
            filteredOptions['max_completion_tokens'] =
                filteredOptions.remove('max_tokens');
          }
        }

        requestData.addAll(filteredOptions);
      }

      // Add o-series specific parameters
      if (model.startsWith('o1') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        if (reasoningEffort != null) {
          requestData['reasoning_effort'] = reasoningEffort;
        }
        if (verbosity != null) requestData['verbosity'] = verbosity;
      }

      final response = await dio.post('/chat/completions', data: requestData);

      final text = response.data['choices'][0]['message']['content'];
      return Completion(text: text);
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  /// Stream chat completion for real-time responses
  Stream<String> streamContentOnly({
    required List<Message> messages,
    String model = 'gpt-4o-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async* {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {
                  'role': m.role,
                  'content': m.content,
                })
            .toList(),
        'stream': true,
        if (options != null) ...options,
      };

      // Add o-series specific parameters
      if (model.startsWith('o1') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        if (reasoningEffort != null) {
          requestData['reasoning_effort'] = reasoningEffort;
        }
        if (verbosity != null) requestData['verbosity'] = verbosity;
      }

      final response = await dio.post(
        '/chat/completions',
        data: requestData,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      await for (var chunk in stream) {
        final lines = String.fromCharCodes(chunk).split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;

            try {
              final json =
                  Map<String, dynamic>.from(Uri.splitQueryString(data));
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null && content.isNotEmpty) {
                yield content as String;
              }
            } catch (_) {
              // Skip malformed chunks
              continue;
            }
          }
        }
      }
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }
}

/// Message class for chat completions
class Message {
  final String role;
  final dynamic content;

  Message({required this.role, required this.content});
}

/// Completion response class
class Completion {
  final String text;

  Completion({required this.text});
}

/// OpenAI exception class
class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException: $statusCode - $message';
}
