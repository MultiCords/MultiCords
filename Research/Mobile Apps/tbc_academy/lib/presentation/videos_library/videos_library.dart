import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/youtube_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/video_card_widget.dart';

/// Videos Library Screen - Fetches real videos from TheBrainCord.Academy YouTube channel
/// UI pattern similar to notes_library.dart with tabs, search, and filtering (NO subscription options)
class VideosLibrary extends StatefulWidget {
  const VideosLibrary({super.key});

  @override
  State<VideosLibrary> createState() => _VideosLibraryState();
}

class _VideosLibraryState extends State<VideosLibrary>
    with SingleTickerProviderStateMixin {
  final YouTubeService _youtubeService = YouTubeService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<Map<String, dynamic>> _allVideos = [];
  List<Map<String, dynamic>> _filteredVideos = [];
  List<Map<String, dynamic>> _watchLaterVideos = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _showFilters = false;
  String _selectedSubject = 'All';
  int _currentBottomIndex = 1; // Videos tab active

  final List<String> _subjects = [
    'All',
    'Biology',
    'Physics',
    'Chemistry',
    'Mathematics'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVideosFromYouTube();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Load videos from TheBrainCord.Academy YouTube channel
  Future<void> _loadVideosFromYouTube() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final videos = await _youtubeService.fetchChannelVideos(maxResults: 50);

      setState(() {
        _allVideos = videos;
        _filteredVideos = videos;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  /// Apply search and subject filters
  void _applyFilters() {
    setState(() {
      _filteredVideos = _allVideos.where((video) {
        // Search filter
        final matchesSearch = _searchQuery.isEmpty ||
            video['title']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            video['description']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        // Subject filter (based on keywords in title/description)
        final matchesSubject = _selectedSubject == 'All' ||
            _detectSubject(video) == _selectedSubject;

        return matchesSearch && matchesSubject;
      }).toList();
    });
  }

  /// Detect subject from video title/description
  String _detectSubject(Map<String, dynamic> video) {
    final text = '${video['title']} ${video['description']}'.toLowerCase();

    if (text.contains('biology') ||
        text.contains('cell') ||
        text.contains('genetics') ||
        text.contains('anatomy')) {
      return 'Biology';
    } else if (text.contains('physics') ||
        text.contains('motion') ||
        text.contains('mechanics') ||
        text.contains('energy')) {
      return 'Physics';
    } else if (text.contains('chemistry') ||
        text.contains('chemical') ||
        text.contains('molecule') ||
        text.contains('reaction')) {
      return 'Chemistry';
    } else if (text.contains('math') ||
        text.contains('calculus') ||
        text.contains('algebra') ||
        text.contains('geometry')) {
      return 'Mathematics';
    }

    return 'All';
  }

  /// Toggle watch later status
  void _toggleWatchLater(Map<String, dynamic> video) {
    setState(() {
      final videoId = video['id'];
      final isInWatchLater = _watchLaterVideos.any((v) => v['id'] == videoId);

      if (isInWatchLater) {
        _watchLaterVideos.removeWhere((v) => v['id'] == videoId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from Watch Later')),
        );
      } else {
        _watchLaterVideos.add(video);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Watch Later')),
        );
      }
    });
  }

  /// Navigate to video player with YouTube video ID
  void _playVideo(Map<String, dynamic> video) {
    Navigator.pushNamed(
      context,
      AppRoutes.videoPlayer,
      arguments: video['youtubeId'], // Pass YouTube video ID to player
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs (similar to notes_library)
            Container(
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Video Library',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.profileSettings);
                          },
                          icon: CustomIconWidget(
                            iconName: 'account_circle',
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'All Videos'),
                      Tab(text: 'Watch Later'),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar (similar to notes_library)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search videos...',
                        prefixIcon: const CustomIconWidget(
                          iconName: 'search',
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _applyFilters();
                      },
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    onPressed: () {
                      setState(() => _showFilters = !_showFilters);
                    },
                    icon: CustomIconWidget(
                      iconName: _showFilters ? 'filter_alt' : 'filter_alt_off',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Subject filter chips
            if (_showFilters)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _subjects.map((subject) {
                      final isSelected = _selectedSubject == subject;
                      return Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: FilterChip(
                          label: Text(subject),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSubject = selected ? subject : 'All';
                            });
                            _applyFilters();
                          },
                          backgroundColor: theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Content with tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllVideosTab(theme),
                  _buildWatchLaterTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() => _currentBottomIndex = index);
        },
      ),
    );
  }

  Widget _buildAllVideosTab(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: theme.colorScheme.error,
                size: 64,
              ),
              SizedBox(height: 3.h),
              Text(
                'Failed to Load Videos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: _loadVideosFromYouTube,
                icon: const CustomIconWidget(iconName: 'refresh', size: 20),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredVideos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'video_library',
                color: theme.colorScheme.onSurfaceVariant,
                size: 80,
              ),
              SizedBox(height: 3.h),
              Text(
                'No Videos Found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Try adjusting your search or filters',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVideosFromYouTube,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _filteredVideos.length,
        itemBuilder: (context, index) {
          final video = _filteredVideos[index];
          final isInWatchLater =
              _watchLaterVideos.any((v) => v['id'] == video['id']);

          return VideoCardWidget(
            video: {
              'id': video['id'],
              'title': video['title'],
              'thumbnail': video['thumbnail'],
              'semanticLabel': video['semanticLabel'],
              'duration': video['duration'],
              'views': _youtubeService.formatViewCount(video['views']),
              'teacher': video['channelTitle'],
              'subject': _detectSubject(video),
              'uploadDate': DateTime.parse(video['publishedAt']),
            },
            onTap: () => _playVideo(video),
            onBookmark: () => _toggleWatchLater(video),
            isBookmarked: isInWatchLater,
          );
        },
      ),
    );
  }

  Widget _buildWatchLaterTab(ThemeData theme) {
    if (_watchLaterVideos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'watch_later',
                color: theme.colorScheme.onSurfaceVariant,
                size: 80,
              ),
              SizedBox(height: 3.h),
              Text(
                'No Videos Saved',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Save videos to watch them later',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () => _tabController.animateTo(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                ),
                child: const Text('Browse Videos'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _watchLaterVideos.length,
      itemBuilder: (context, index) {
        final video = _watchLaterVideos[index];

        return VideoCardWidget(
          video: {
            'id': video['id'],
            'title': video['title'],
            'thumbnail': video['thumbnail'],
            'semanticLabel': video['semanticLabel'],
            'duration': video['duration'],
            'views': _youtubeService.formatViewCount(video['views']),
            'teacher': video['channelTitle'],
            'subject': _detectSubject(video),
            'uploadDate': DateTime.parse(video['publishedAt']),
          },
          onTap: () => _playVideo(video),
          onBookmark: () => _toggleWatchLater(video),
          isBookmarked: true,
        );
      },
    );
  }
}
