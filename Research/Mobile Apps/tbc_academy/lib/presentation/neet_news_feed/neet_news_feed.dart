import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/news_card_widget.dart';
import './widgets/trending_news_widget.dart';

/// NEET News Feed Screen
/// Delivers timely educational updates and exam-related information
class NeetNewsFeed extends StatefulWidget {
  const NeetNewsFeed({super.key});

  @override
  State<NeetNewsFeed> createState() => _NeetNewsFeedState();
}

class _NeetNewsFeedState extends State<NeetNewsFeed> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All';
  bool _isRefreshing = false;
  bool _isSearching = false;
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Exam Updates',
    'Study Tips',
    'College News',
    'Syllabus Changes',
    'Success Stories'
  ];

  // Mock news data
  final List<Map<String, dynamic>> _newsArticles = [
    {
      "id": 1,
      "title":
          "NEET 2025 Registration Dates Announced - Apply Before January 15th",
      "excerpt":
          "National Testing Agency (NTA) has officially announced the registration dates for NEET 2025. Students can apply online from December 20th to January 15th through the official website.",
      "category": "Exam Updates",
      "publishedDate": DateTime(2024, 12, 10),
      "imageUrl":
          "https://img.rocket.new/generatedImages/rocket_gen_img_12d4c1d0b-1764678959447.png",
      "semanticLabel":
          "Students studying together at a desk with books and laptops in a bright classroom",
      "isVerified": true,
      "readTime": "3 min read",
      "isBookmarked": false,
      "isTrending": true
    },
    {
      "id": 2,
      "title": "Top 10 Study Techniques That Helped NEET Toppers Score 720+",
      "excerpt":
          "Learn from the best! We interviewed NEET 2024 toppers to understand their study strategies, time management techniques, and revision methods that led to their exceptional scores.",
      "category": "Study Tips",
      "publishedDate": DateTime(2024, 12, 9),
      "imageUrl":
          "https://img.rocket.new/generatedImages/rocket_gen_img_112ecac68-1765373390452.png",
      "semanticLabel":
          "Open notebook with colorful study notes and highlighters on a wooden desk",
      "isVerified": true,
      "readTime": "5 min read",
      "isBookmarked": false,
      "isTrending": true
    },
    {
      "id": 3,
      "title": "AIIMS Delhi Announces New Seat Matrix for 2025 Admissions",
      "excerpt":
          "AIIMS Delhi has released the updated seat matrix for MBBS admissions 2025, including reserved category seats and state-wise quota distribution details.",
      "category": "College News",
      "publishedDate": DateTime(2024, 12, 8),
      "imageUrl":
          "https://img.rocket.new/generatedImages/rocket_gen_img_145f7a36b-1765477774898.png",
      "semanticLabel":
          "Modern medical college building exterior with glass facade and students walking",
      "isVerified": true,
      "readTime": "4 min read",
      "isBookmarked": false,
      "isTrending": true
    },
    {
      "id": 4,
      "title": "Biology Chapter-wise Weightage Analysis for NEET 2025",
      "excerpt":
          "Detailed analysis of previous year NEET papers reveals which Biology chapters carry maximum weightage. Focus your preparation on these high-scoring topics.",
      "category": "Study Tips",
      "publishedDate": DateTime(2024, 12, 7),
      "imageUrl":
          "https://img.rocket.new/generatedImages/rocket_gen_img_169928533-1765116211121.png",
      "semanticLabel":
          "Biology textbook open showing diagrams of human anatomy with colored pencils",
      "isVerified": true,
      "readTime": "6 min read",
      "isBookmarked": false,
      "isTrending": false
    },
    {
      "id": 5,
      "title":
          "NTA Clarifies NEET 2025 Exam Pattern - No Major Changes Expected",
      "excerpt":
          "National Testing Agency has confirmed that NEET 2025 will follow the same exam pattern as previous years with 200 questions across Physics, Chemistry, and Biology.",
      "category": "Exam Updates",
      "publishedDate": DateTime(2024, 12, 6),
      "imageUrl":
          "https://images.unsplash.com/photo-1606326608606-aa0b62935f2b",
      "semanticLabel":
          "Student filling OMR answer sheet with pencil during examination",
      "isVerified": true,
      "readTime": "3 min read",
      "isBookmarked": false,
      "isTrending": false
    },
    {
      "id": 6,
      "title":
          "From 450 to 680: How Consistent Practice Transformed My NEET Score",
      "excerpt":
          "A motivating success story of a student who improved their NEET score by 230 marks through dedicated practice, mock tests, and strategic revision over 12 months.",
      "category": "Success Stories",
      "publishedDate": DateTime(2024, 12, 5),
      "imageUrl":
          "https://images.unsplash.com/photo-1621310814711-56ccead6e1fe",
      "semanticLabel":
          "Happy student celebrating success with raised arms in graduation gown",
      "isVerified": true,
      "readTime": "7 min read",
      "isBookmarked": false,
      "isTrending": false
    },
    {
      "id": 7,
      "title": "Important Changes in NEET Physics Syllabus for 2025",
      "excerpt":
          "NTA has made minor modifications to the Physics syllabus for NEET 2025. Here's a comprehensive list of topics added and removed from the curriculum.",
      "category": "Syllabus Changes",
      "publishedDate": DateTime(2024, 12, 4),
      "imageUrl":
          "https://images.unsplash.com/photo-1509869175650-a1d97972541a",
      "semanticLabel":
          "Physics formulas and equations written on blackboard with chalk",
      "isVerified": true,
      "readTime": "4 min read",
      "isBookmarked": false,
      "isTrending": false
    },
    {
      "id": 8,
      "title": "Top Medical Colleges Accepting NEET Scores Below 600",
      "excerpt":
          "Don't lose hope! Here's a comprehensive list of reputed medical colleges across India that accept NEET scores in the 500-600 range for various categories.",
      "category": "College News",
      "publishedDate": DateTime(2024, 12, 3),
      "imageUrl":
          "https://images.unsplash.com/photo-1600344247837-155758c193bc",
      "semanticLabel":
          "Medical college campus with students in white coats walking between buildings",
      "isVerified": true,
      "readTime": "5 min read",
      "isBookmarked": false,
      "isTrending": false
    }
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Implement infinite scroll logic here if needed
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('News feed updated'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _handleCategoryChange(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _handleBookmark(int articleId) {
    setState(() {
      final article = _newsArticles.firstWhere((a) => a['id'] == articleId);
      article['isBookmarked'] = !(article['isBookmarked'] as bool);
    });

    final article = _newsArticles.firstWhere((a) => a['id'] == articleId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(article['isBookmarked']
            ? 'Article bookmarked'
            : 'Bookmark removed'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleShare(Map<String, dynamic> article) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${article['title']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleArticleTap(Map<String, dynamic> article) {
    // Navigate to article detail screen
    Navigator.pushNamed(
      context,
      '/article-detail',
      arguments: article,
    );
  }

  void _showArticleOptions(Map<String, dynamic> article) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName:
                      article['isBookmarked'] ? 'bookmark' : 'bookmark_border',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  article['isBookmarked']
                      ? 'Remove Bookmark'
                      : 'Save for Later',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleBookmark(article['id'] as int);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text('Share Article', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _handleShare(article);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'visibility_off',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                title: Text('Hide Article', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Article hidden'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'report',
                  color: theme.colorScheme.error,
                  size: 24,
                ),
                title: Text(
                  'Report Content',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Content reported'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredArticles() {
    var filtered = _newsArticles;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((article) => article['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((article) {
        final title = (article['title'] as String).toLowerCase();
        final excerpt = (article['excerpt'] as String).toLowerCase();
        return title.contains(_searchQuery) || excerpt.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> _getTrendingArticles() {
    return _newsArticles
        .where((article) => article['isTrending'] == true)
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredArticles = _getFilteredArticles();
    final trendingArticles = _getTrendingArticles();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _isSearching
          ? CustomAppBar(
              searchController: _searchController,
              onSearchChanged: _handleSearch,
              onSearchSubmitted: _handleSearch,
            )
          : CustomAppBar(
              title: 'NEET News',
              actions: [
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: _toggleSearch,
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'bookmarks',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () {
                    // Navigate to bookmarked articles
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Opening bookmarked articles'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 2.w),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Category Filter
            SliverToBoxAdapter(
              child: CategoryFilterWidget(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: _handleCategoryChange,
              ),
            ),

            // Trending News Section
            if (trendingArticles.isNotEmpty &&
                _selectedCategory == 'All' &&
                _searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: TrendingNewsWidget(
                  articles: trendingArticles,
                  onArticleTap: _handleArticleTap,
                ),
              ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Search Results (${filteredArticles.length})'
                          : _selectedCategory == 'All'
                              ? 'Latest Updates'
                              : _selectedCategory,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (filteredArticles.length > 5)
                      TextButton(
                        onPressed: () {
                          // Show all articles
                        },
                        child: Text(
                          'View All',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // News Articles List
            if (filteredArticles.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'article',
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                        size: 64,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No articles found'
                            : 'No articles in this category',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try different keywords'
                            : 'Check back later for updates',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = filteredArticles[index];
                      return NewsCardWidget(
                        article: article,
                        onTap: () => _handleArticleTap(article),
                        onBookmark: () => _handleBookmark(article['id'] as int),
                        onShare: () => _handleShare(article),
                        onLongPress: () => _showArticleOptions(article),
                      );
                    },
                    childCount: filteredArticles.length,
                  ),
                ),
              ),

            // Bottom Spacing
            SliverToBoxAdapter(
              child: SizedBox(height: 10.h),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}