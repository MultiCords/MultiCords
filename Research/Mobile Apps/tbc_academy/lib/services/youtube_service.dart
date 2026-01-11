import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to fetch and manage YouTube content from TheBrainCord.Academy channel
class YouTubeService {
  // YouTube Channel ID: UC4a7sCM3Osr3Hz587QB9pMw
  static const String _channelId = 'UC4a7sCM3Osr3Hz587QB9pMw';

  // YouTube Data API v3 key - MUST be set as environment variable
  static const String _apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Validate API key configuration
  void validateConfiguration() {
    if (_apiKey.isEmpty) {
      throw Exception(
          'YOUTUBE_API_KEY environment variable is not configured.');
    }
  }

  /// Fetch videos from TheBrainCord.Academy YouTube channel
  ///
  /// Returns list of video data maps containing:
  /// - id: YouTube video ID
  /// - title: Video title
  /// - description: Video description
  /// - thumbnail: Video thumbnail URL
  /// - publishedAt: Publication date
  /// - duration: Video duration in ISO 8601 format
  /// - viewCount: Number of views
  /// - likeCount: Number of likes
  Future<List<Map<String, dynamic>>> fetchChannelVideos({
    int maxResults = 50,
    String? pageToken,
  }) async {
    validateConfiguration();

    try {
      // Fetch video list from channel
      final searchUrl = Uri.parse(
        '$_baseUrl/search?key=$_apiKey&channelId=$_channelId&part=snippet&type=video&order=date&maxResults=$maxResults${pageToken != null ? "&pageToken=$pageToken" : ""}',
      );

      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch channel videos: ${searchResponse.statusCode}');
      }

      final searchData = json.decode(searchResponse.body);
      final items = searchData['items'] as List;

      if (items.isEmpty) {
        return [];
      }

      // Extract video IDs
      final videoIds =
          items.map((item) => item['id']['videoId'] as String).toList();

      // Fetch detailed video information
      final videosUrl = Uri.parse(
        '$_baseUrl/videos?key=$_apiKey&id=${videoIds.join(",")}&part=snippet,contentDetails,statistics',
      );

      final videosResponse = await http.get(videosUrl);

      if (videosResponse.statusCode != 200) {
        throw Exception(
            'Failed to fetch video details: ${videosResponse.statusCode}');
      }

      final videosData = json.decode(videosResponse.body);
      final videoItems = videosData['items'] as List;

      // Process and return video data
      return videoItems.map((item) {
        final snippet = item['snippet'];
        final contentDetails = item['contentDetails'];
        final statistics = item['statistics'];

        return {
          'id': item['id'],
          'youtubeId': item['id'],
          'title': snippet['title'] ?? 'Untitled Video',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']['high']['url'] ??
              snippet['thumbnails']['medium']['url'] ??
              snippet['thumbnails']['default']['url'],
          'semanticLabel': 'YouTube video thumbnail for ${snippet['title']}',
          'publishedAt': snippet['publishedAt'],
          'duration': _parseDuration(contentDetails['duration'] ?? 'PT0S'),
          'views': statistics['viewCount'] ?? '0',
          'likes': statistics['likeCount'] ?? '0',
          'channelTitle': snippet['channelTitle'] ?? 'The Brain Cord Academy',
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching YouTube videos: $e');
    }
  }

  /// Parse ISO 8601 duration format to readable string
  /// Example: PT1H30M45S -> 1:30:45
  String _parseDuration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return '0:00';

    final hours = match.group(1);
    final minutes = match.group(2) ?? '0';
    final seconds = match.group(3) ?? '0';

    if (hours != null) {
      return '$hours:${minutes.padLeft(2, '0')}:${seconds.padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.padLeft(2, '0')}';
    }
  }

  /// Format view count for display
  /// Example: 1250 -> 1.2K, 125000 -> 125K
  String formatViewCount(String viewCountStr) {
    try {
      final count = int.parse(viewCountStr);
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      } else if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1)}K';
      }
      return viewCountStr;
    } catch (e) {
      return viewCountStr;
    }
  }

  /// Search videos by query within the channel
  Future<List<Map<String, dynamic>>> searchChannelVideos(
    String query, {
    int maxResults = 20,
  }) async {
    validateConfiguration();

    try {
      final searchUrl = Uri.parse(
        '$_baseUrl/search?key=$_apiKey&channelId=$_channelId&part=snippet&type=video&q=${Uri.encodeComponent(query)}&maxResults=$maxResults',
      );

      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        throw Exception(
            'Failed to search videos: ${searchResponse.statusCode}');
      }

      final searchData = json.decode(searchResponse.body);
      final items = searchData['items'] as List;

      return items.map((item) {
        final snippet = item['snippet'];
        return {
          'id': item['id']['videoId'],
          'youtubeId': item['id']['videoId'],
          'title': snippet['title'] ?? 'Untitled Video',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']['high']['url'] ??
              snippet['thumbnails']['medium']['url'] ??
              snippet['thumbnails']['default']['url'],
          'semanticLabel': 'YouTube video thumbnail for ${snippet['title']}',
          'publishedAt': snippet['publishedAt'],
          'channelTitle': snippet['channelTitle'] ?? 'The Brain Cord Academy',
        };
      }).toList();
    } catch (e) {
      throw Exception('Error searching YouTube videos: $e');
    }
  }

  /// Extract YouTube video ID from URL
  String? extractVideoId(String url) {
    final regex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }
}
