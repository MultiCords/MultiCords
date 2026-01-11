import './supabase_service.dart';

/// Service for managing video content operations with Supabase
class VideoContentService {
  final client = SupabaseService.instance.client;

  /// Fetches video content with filtering and pagination
  ///
  /// Parameters:
  /// - subjectCategory: Filter by subject (neet_biology, neet_physics, neet_chemistry)
  /// - teacherId: Filter by specific teacher
  /// - searchQuery: Search in title and description
  /// - limit: Number of results to return
  /// - offset: Pagination offset
  Future<List<Map<String, dynamic>>> getVideoContent({
    String? subjectCategory,
    String? teacherId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = client
          .from('course_content')
          .select('''
            id,
            title,
            description,
            thumbnail_url,
            duration_minutes,
            views_count,
            subject_category,
            status,
            created_at,
            teacher_id,
            user_profiles!course_content_teacher_id_fkey(
              id,
              full_name,
              avatar_url
            )
          ''')
          .eq('content_type', 'video')
          .eq('status', 'published');

      // Apply filters
      if (subjectCategory != null && subjectCategory.isNotEmpty) {
        query = query.eq('subject_category', subjectCategory);
      }

      if (teacherId != null && teacherId.isNotEmpty) {
        query = query.eq('teacher_id', teacherId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
        );
      }

      // Apply sorting and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch video content: $error');
    }
  }

  /// Gets unique list of teachers who have published video content
  Future<List<Map<String, dynamic>>> getTeachersWithVideos() async {
    try {
      final response = await client
          .from('user_profiles')
          .select('id, full_name, avatar_url')
          .eq('user_type', 'teacher')
          .order('full_name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch teachers: $error');
    }
  }

  /// Gets video sections for a specific course content
  Future<List<Map<String, dynamic>>> getVideoSections(String contentId) async {
    try {
      final response = await client
          .from('content_section')
          .select('*')
          .eq('content_id', contentId)
          .order('order_index', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch video sections: $error');
    }
  }

  /// Increments view count for a video
  Future<void> incrementViewCount(String contentId) async {
    try {
      final currentData =
          await client
              .from('course_content')
              .select('views_count')
              .eq('id', contentId)
              .single();

      final currentViews = currentData['views_count'] ?? 0;

      await client
          .from('course_content')
          .update({'views_count': currentViews + 1})
          .eq('id', contentId);
    } catch (error) {
      // Silently fail - view count is not critical
      print('Failed to increment view count: $error');
    }
  }

  /// Formats duration in minutes to human-readable string
  String formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '0:00';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '$hours:${mins.toString().padLeft(2, '0')}:00';
    } else {
      return '${mins.toString()}:00';
    }
  }

  /// Formats view count to readable string (e.g., 1.2K, 15K)
  String formatViewCount(int? views) {
    if (views == null || views == 0) return '0';

    if (views >= 1000) {
      final thousands = views / 1000;
      return '${thousands.toStringAsFixed(1)}K';
    }

    return views.toString();
  }

  /// Maps subject_category enum to display name
  String getSubjectDisplayName(String? category) {
    switch (category) {
      case 'neet_biology':
        return 'Biology';
      case 'neet_physics':
        return 'Physics';
      case 'neet_chemistry':
        return 'Chemistry';
      default:
        return 'Other';
    }
  }

  /// Gets subject filter value for database query
  String? getSubjectCategoryValue(String displayName) {
    switch (displayName) {
      case 'Biology':
        return 'neet_biology';
      case 'Physics':
        return 'neet_physics';
      case 'Chemistry':
        return 'neet_chemistry';
      default:
        return null;
    }
  }
}
