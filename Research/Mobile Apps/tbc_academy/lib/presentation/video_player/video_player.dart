import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/comments_section_widget.dart';
import './widgets/notes_section_widget.dart';
import './widgets/related_videos_widget.dart';

class VideoPlayer extends StatefulWidget {
  const VideoPlayer({super.key});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late YoutubePlayerController _youtubeController;
  bool _isFullScreen = false;
  bool _isBookmarked = false;
  int _currentBottomNavIndex = 1;
  String? _videoId;

  String? _errorMessage;

  // Mock video data
  final Map<String, dynamic> _currentVideo = {
    "id": "video_001",
    "title": "Cell Structure and Functions - Complete Chapter",
    "subject": "Biology",
    "subjectColor": 0xFF2E7D32,
    "instructor": {
      "name": "Dr. Priya Sharma",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_11f41a407-1763296145583.png",
      "semanticLabel":
          "Professional photo of Dr. Priya Sharma, a woman with long black hair wearing a white lab coat",
      "qualification": "PhD in Molecular Biology"
    },
    "description":
        """This comprehensive lecture covers the complete chapter on Cell Structure and Functions for NEET preparation. We'll explore:

• Cell Theory and Cell Types
• Prokaryotic vs Eukaryotic Cells
• Cell Organelles and their Functions
• Cell Membrane Structure
• Transport Mechanisms
• Cell Division Process

Perfect for NEET aspirants looking to master this fundamental biology chapter with detailed explanations and exam-focused content.""",
    "duration": "2:45:30",
    "views": "125K",
    "uploadDate": "2025-12-10",
    "youtubeId": "dQw4w9WgXcQ", // Sample YouTube video ID
    "chapters": [
      {"time": "0:00", "title": "Introduction to Cells"},
      {"time": "15:30", "title": "Cell Theory"},
      {"time": "32:45", "title": "Prokaryotic Cells"},
      {"time": "58:20", "title": "Eukaryotic Cells"},
      {"time": "1:25:10", "title": "Cell Organelles"},
      {"time": "2:10:30", "title": "Cell Division"}
    ],
    "watchProgress": 0.35
  };

  final List<Map<String, dynamic>> _relatedVideos = [
    {
      "id": "video_002",
      "title": "Biomolecules - Carbohydrates and Proteins",
      "thumbnail":
          "https://images.unsplash.com/photo-1707862159452-0350f52248e5",
      "semanticLabel":
          "Microscopic view of molecular structures in blue and purple colors",
      "duration": "1:45:20",
      "subject": "Biology",
      "instructor": "Dr. Priya Sharma"
    },
    {
      "id": "video_003",
      "title": "Laws of Motion - Newton's Laws Explained",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1aa9ecef1-1764660290166.png",
      "semanticLabel":
          "Physics diagram showing force vectors and motion arrows on a blackboard",
      "duration": "2:15:45",
      "subject": "Physics",
      "instructor": "Prof. Rajesh Kumar"
    },
    {
      "id": "video_004",
      "title": "Chemical Bonding and Molecular Structure",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1878d104d-1765223515340.png",
      "semanticLabel":
          "3D molecular model showing chemical bonds between atoms",
      "duration": "1:55:30",
      "subject": "Chemistry",
      "instructor": "Dr. Anita Desai"
    },
    {
      "id": "video_005",
      "title": "Plant Physiology - Photosynthesis",
      "thumbnail":
          "https://images.unsplash.com/photo-1718414785956-0886ecfea5c4",
      "semanticLabel":
          "Close-up of green plant leaves with visible cellular structure",
      "duration": "2:05:15",
      "subject": "Biology",
      "instructor": "Dr. Priya Sharma"
    }
  ];

  final List<Map<String, dynamic>> _associatedNotes = [
    {
      "id": "note_001",
      "title": "Cell Structure - Complete Notes",
      "pages": 45,
      "price": "\$99",
      "isPaid": true,
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1df347543-1765728579555.png",
      "semanticLabel":
          "Study notes with diagrams of cell structures on white paper"
    },
    {
      "id": "note_002",
      "title": "Cell Division - Quick Revision",
      "pages": 12,
      "price": "Free",
      "isPaid": false,
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1961162f3-1765299596523.png",
      "semanticLabel": "Handwritten revision notes with colorful diagrams"
    },
    {
      "id": "note_003",
      "title": "Cell Organelles - Detailed Study",
      "pages": 28,
      "price": "\$49",
      "isPaid": true,
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_169928533-1765116211121.png",
      "semanticLabel":
          "Detailed biology notes with labeled cell organelle diagrams"
    }
  ];

  final List<Map<String, dynamic>> _comments = [
    {
      "id": "comment_001",
      "user": {
        "name": "Arjun Patel",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_16c380a60-1763294638826.png",
        "semanticLabel":
            "Profile photo of a young man with short black hair wearing a blue shirt"
      },
      "comment":
          "Excellent explanation! The cell organelles section really helped me understand the concepts clearly. Thank you Dr. Sharma!",
      "timestamp": "2 days ago",
      "likes": 45
    },
    {
      "id": "comment_002",
      "user": {
        "name": "Sneha Reddy",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1e3c616b4-1765003960787.png",
        "semanticLabel":
            "Profile photo of a young woman with long brown hair and glasses"
      },
      "comment":
          "Can you please make a video on cell membrane transport mechanisms in more detail?",
      "timestamp": "1 day ago",
      "likes": 23
    },
    {
      "id": "comment_003",
      "user": {
        "name": "Vikram Singh",
        "avatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1577ed5fc-1763296789570.png",
        "semanticLabel":
            "Profile photo of a young man with short hair wearing a white t-shirt"
      },
      "comment":
          "This is exactly what I needed for my NEET preparation. The chapter markers make it easy to revise specific topics.",
      "timestamp": "5 hours ago",
      "likes": 67
    }
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get YouTube video ID from route arguments
    final arguments = ModalRoute.of(context)!.settings.arguments;

    if (arguments is String) {
      _videoId = arguments;
      _initializeYoutubePlayer();
    } else {
      // Fallback to mock data if no arguments
      _videoId = _currentVideo["youtubeId"];
      _initializeYoutubePlayer();
    }
  }

  void _initializeYoutubePlayer() {
    if (_videoId == null || _videoId!.isEmpty) {
      setState(() {
        _errorMessage = 'Invalid video ID';
      });
      return;
    }

    _youtubeController = YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isFullScreen) {
      return _buildFullScreenPlayer(theme);
    }

    return Scaffold(
      appBar: CustomAppBar(
        variant: AppBarVariant.detail,
        title: 'Video Player',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: _isBookmarked ? 'bookmark' : 'bookmark_border',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoPlayer(theme),
            _buildVideoInfo(theme),
            const SizedBox(height: 16),
            RelatedVideosWidget(videos: _relatedVideos),
            const SizedBox(height: 16),
            NotesSectionWidget(notes: _associatedNotes),
            const SizedBox(height: 16),
            CommentsSectionWidget(comments: _comments),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);

          final routes = [
            '/dashboard-home',
            '/video-player',
            '/notes-library',
            '/mock-test-interface',
            '/profile-settings'
          ];

          if (index != _currentBottomNavIndex) {
            Navigator.pushReplacementNamed(context, routes[index]);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleBookmark,
        child: CustomIconWidget(
          iconName: _isBookmarked ? 'bookmark' : 'bookmark_border',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFullScreenPlayer(ThemeData theme) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: theme.colorScheme.primary,
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: CustomIconWidget(
                iconName: 'fullscreen_exit',
                color: Colors.white,
                size: 28,
              ),
              onPressed: _toggleFullScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: theme.colorScheme.primary,
              onReady: () {
                // Seek to saved progress
                final progress = _currentVideo["watchProgress"] as double;
                final duration = _youtubeController.metadata.duration.inSeconds;
                _youtubeController
                    .seekTo(Duration(seconds: (duration * progress).toInt()));
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: CustomIconWidget(
                  iconName: 'fullscreen',
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFullScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo(ThemeData theme) {
    final instructor = _currentVideo["instructor"] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(_currentVideo["subjectColor"] as int)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _currentVideo["subject"],
              style: theme.textTheme.labelMedium?.copyWith(
                color: Color(_currentVideo["subjectColor"] as int),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Video title
          Text(
            _currentVideo["title"],
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Video stats
          Row(
            children: [
              CustomIconWidget(
                iconName: 'visibility',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${_currentVideo["views"]} views',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _currentVideo["duration"],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Instructor info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomImageWidget(
                  imageUrl: instructor["avatar"],
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  semanticLabel: instructor["semanticLabel"],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor["name"],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      instructor["qualification"],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentVideo["description"],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Chapter markers
          Text(
            'Chapters',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...(_currentVideo["chapters"] as List).map((chapter) {
            return InkWell(
              onTap: () {
                final timeParts = (chapter["time"] as String).split(':');
                int seconds = 0;
                if (timeParts.length == 3) {
                  seconds = int.parse(timeParts[0]) * 3600 +
                      int.parse(timeParts[1]) * 60 +
                      int.parse(timeParts[2]);
                } else {
                  seconds =
                      int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
                }
                _youtubeController.seekTo(Duration(seconds: seconds));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        chapter["time"],
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        chapter["title"],
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'play_circle_outline',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
