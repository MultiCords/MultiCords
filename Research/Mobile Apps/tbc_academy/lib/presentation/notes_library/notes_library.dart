import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/subscription_banner_widget.dart';

/// Notes Library screen for browsing and purchasing educational materials
class NotesLibrary extends StatefulWidget {
  const NotesLibrary({super.key});

  @override
  State<NotesLibrary> createState() => _NotesLibraryState();
}

class _NotesLibraryState extends State<NotesLibrary>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  String _selectedSubject = 'All';
  String _selectedPrice = 'All';
  String _selectedType = 'All';
  String _searchQuery = '';
  bool _showFilters = false;
  int _currentBottomIndex = 2; // Notes tab active

  // Mock data for notes
  final List<Map<String, dynamic>> _allNotes = [
    {
      "id": 1,
      "title": "Cell Biology - Complete Notes",
      "subject": "Biology",
      "price": "Free",
      "rating": 4.8,
      "downloads": 1250,
      "type": "Typed",
      "thumbnail":
          "https://images.unsplash.com/photo-1714844437236-de8ef1c7286f",
      "semanticLabel":
          "Microscopic view of biological cells with visible nucleus and cell membrane structures in blue and purple tones",
      "isDownloaded": false,
    },
    {
      "id": 2,
      "title": "Human Anatomy & Physiology",
      "subject": "Biology",
      "price": "₹99",
      "rating": 4.9,
      "downloads": 2340,
      "type": "Handwritten",
      "thumbnail":
          "https://images.unsplash.com/photo-1725399459301-20d51fb18194",
      "semanticLabel":
          "Anatomical diagram showing human body systems with detailed organ illustrations and medical annotations",
      "isDownloaded": false,
    },
    {
      "id": 3,
      "title": "Genetics & Evolution Notes",
      "subject": "Biology",
      "price": "₹149",
      "rating": 4.7,
      "downloads": 890,
      "type": "Typed",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_173399831-1764664029631.png",
      "semanticLabel":
          "DNA double helix structure illustration with genetic code sequences and molecular bonds in vibrant colors",
      "isDownloaded": true,
    },
    {
      "id": 4,
      "title": "Mechanics - Laws of Motion",
      "subject": "Physics",
      "price": "Free",
      "rating": 4.6,
      "downloads": 1560,
      "type": "Typed",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_11547ab02-1765243012935.png",
      "semanticLabel":
          "Physics concept illustration showing Newton's laws with force diagrams and motion vectors on blackboard",
      "isDownloaded": false,
    },
    {
      "id": 5,
      "title": "Electromagnetism Complete Guide",
      "subject": "Physics",
      "price": "₹199",
      "rating": 4.9,
      "downloads": 1890,
      "type": "Handwritten",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_169d8c999-1764690407810.png",
      "semanticLabel":
          "Electromagnetic field visualization with magnetic field lines and electric current flow diagrams",
      "isDownloaded": false,
    },
    {
      "id": 6,
      "title": "Optics & Wave Theory",
      "subject": "Physics",
      "price": "₹129",
      "rating": 4.5,
      "downloads": 1120,
      "type": "Typed",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1daadcc86-1765645363384.png",
      "semanticLabel":
          "Light refraction and wave interference patterns with prism dispersion creating rainbow spectrum",
      "isDownloaded": true,
    },
    {
      "id": 7,
      "title": "Calculus - Differentiation & Integration",
      "subject": "Mathematics",
      "price": "Free",
      "rating": 4.7,
      "downloads": 2100,
      "type": "Typed",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_13e0b5f24-1764664027878.png",
      "semanticLabel":
          "Mathematical equations and calculus formulas written on blackboard with graphs and derivative notations",
      "isDownloaded": false,
    },
    {
      "id": 8,
      "title": "Coordinate Geometry Mastery",
      "subject": "Mathematics",
      "price": "₹179",
      "rating": 4.8,
      "downloads": 1670,
      "type": "Handwritten",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1c606c4f1-1765018281491.png",
      "semanticLabel":
          "Coordinate plane with geometric shapes, lines, and parabolas plotted with precise measurements",
      "isDownloaded": false,
    },
    {
      "id": 9,
      "title": "Trigonometry - Complete Notes",
      "subject": "Mathematics",
      "price": "₹99",
      "rating": 4.6,
      "downloads": 1340,
      "type": "Typed",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_18080844b-1764676765566.png",
      "semanticLabel":
          "Trigonometric circle with sine, cosine, and tangent functions illustrated with angle measurements",
      "isDownloaded": true,
    },
    {
      "id": 10,
      "title": "Plant Physiology & Botany",
      "subject": "Biology",
      "price": "₹159",
      "rating": 4.7,
      "downloads": 980,
      "type": "Handwritten",
      "thumbnail":
          "https://img.rocket.new/generatedImages/rocket_gen_img_10a56806b-1765277016871.png",
      "semanticLabel":
          "Botanical illustration of plant cell structure with chloroplasts and photosynthesis process diagrams",
      "isDownloaded": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNotes {
    return _allNotes.where((note) {
      final matchesSearch = _searchQuery.isEmpty ||
          note['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          note['subject']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesSubject =
          _selectedSubject == 'All' || note['subject'] == _selectedSubject;
      final matchesPrice = _selectedPrice == 'All' ||
          (_selectedPrice == 'Free' && note['price'] == 'Free') ||
          (_selectedPrice == 'Paid' && note['price'] != 'Free');
      final matchesType =
          _selectedType == 'All' || note['type'] == _selectedType;

      return matchesSearch && matchesSubject && matchesPrice && matchesType;
    }).toList();
  }

  List<Map<String, dynamic>> get _downloadedNotes {
    return _allNotes.where((note) => note['isDownloaded'] == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with tabs
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
                          'Notes Library',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile-settings');
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
                      Tab(text: 'All Notes'),
                      Tab(text: 'Downloaded'),
                    ],
                  ),
                ],
              ),
            ),

            // Search bar
            SearchBarWidget(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterTap: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),

            // Filter chips
            if (_showFilters)
              FilterChipsWidget(
                selectedSubject: _selectedSubject,
                selectedPrice: _selectedPrice,
                selectedType: _selectedType,
                onSubjectChanged: (value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
                onPriceChanged: (value) {
                  setState(() {
                    _selectedPrice = value;
                  });
                },
                onTypeChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllNotesTab(),
                  _buildDownloadedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildAllNotesTab() {
    final theme = Theme.of(context);

    if (_filteredNotes.isEmpty) {
      return EmptyStateWidget(
        subject: _selectedSubject,
        onExploreTap: () {
          setState(() {
            _selectedSubject = 'All';
            _selectedPrice = 'All';
            _selectedType = 'All';
            _searchQuery = '';
            _searchController.clear();
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        Fluttertoast.showToast(
          msg: "Notes updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      },
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 2.h),
        itemCount: _filteredNotes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return SubscriptionBannerWidget(
              onSubscribeTap: () {
                _showSubscriptionDialog();
              },
            );
          }

          final note = _filteredNotes[index - 1];
          return NoteCardWidget(
            note: note,
            onTap: () {
              _handleNoteTap(note);
            },
            onPreview: () {
              _handlePreview(note);
            },
            onBookmark: () {
              _handleBookmark(note);
            },
            onShare: () {
              _handleShare(note);
            },
            onDownload: () {
              _handleDownload(note);
            },
          );
        },
      ),
    );
  }

  Widget _buildDownloadedTab() {
    final theme = Theme.of(context);

    if (_downloadedNotes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'download_outlined',
                color: theme.colorScheme.onSurfaceVariant,
                size: 80,
              ),
              SizedBox(height: 3.h),
              Text(
                'No Downloaded Notes',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Download notes to access them offline',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Browse Notes',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      itemCount: _downloadedNotes.length,
      itemBuilder: (context, index) {
        final note = _downloadedNotes[index];
        return NoteCardWidget(
          note: note,
          onTap: () {
            _handleOpenNote(note);
          },
          onPreview: () {
            _handlePreview(note);
          },
          onBookmark: () {
            _handleBookmark(note);
          },
          onShare: () {
            _handleShare(note);
          },
          onDownload: () {
            _handleDownload(note);
          },
        );
      },
    );
  }

  void _handleNoteTap(Map<String, dynamic> note) {
    if (note['price'] == 'Free') {
      _handleDownload(note);
    } else {
      _showPurchaseDialog(note);
    }
  }

  void _handlePreview(Map<String, dynamic> note) {
    Fluttertoast.showToast(
      msg: "Opening preview for ${note['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleBookmark(Map<String, dynamic> note) {
    Fluttertoast.showToast(
      msg: "Bookmarked: ${note['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleShare(Map<String, dynamic> note) {
    Fluttertoast.showToast(
      msg: "Sharing: ${note['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleDownload(Map<String, dynamic> note) {
    if (note['isDownloaded'] == true) {
      Fluttertoast.showToast(
        msg: "Already downloaded",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    setState(() {
      note['isDownloaded'] = true;
    });

    Fluttertoast.showToast(
      msg: "Downloaded: ${note['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleOpenNote(Map<String, dynamic> note) {
    Fluttertoast.showToast(
      msg: "Opening: ${note['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showPurchaseDialog(Map<String, dynamic> note) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Purchase Note',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note['title'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price:',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  note['price'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'This note will be available for offline access after purchase.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(note);
            },
            child: Text('Buy Now'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(Map<String, dynamic> note) {
    Fluttertoast.showToast(
      msg: "Processing payment for ${note['title']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        note['isDownloaded'] = true;
      });

      Fluttertoast.showToast(
        msg: "Purchase successful! Note downloaded.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void _showSubscriptionDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose Your Plan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlanOption(
              context,
              'Monthly Plan',
              '₹499',
              'per month',
              'Access all notes, videos, and tests',
            ),
            SizedBox(height: 2.h),
            _buildPlanOption(
              context,
              'Yearly Plan',
              '₹4,999',
              'per year',
              'Save ₹1,000 with annual billing',
              isPopular: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Maybe Later'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(
    BuildContext context,
    String title,
    String price,
    String period,
    String description, {
    bool isPopular = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Processing subscription for $title",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isPopular
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isPopular)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'POPULAR',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  period,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
