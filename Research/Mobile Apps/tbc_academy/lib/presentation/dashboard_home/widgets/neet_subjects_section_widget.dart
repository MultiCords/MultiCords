import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NeetSubjectsSectionWidget extends StatelessWidget {
  final Function(String subject) onSubjectTap;

  const NeetSubjectsSectionWidget({super.key, required this.onSubjectTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> neetSubjects = [
      {
        "id": "biology",
        "name": "Biology",
        "icon": "biotech",
        "color": 0xFFFF6B35,
        "gradient": [0xFFFF6B35, 0xFFFF8C42],
        "topics": 38,
        "videos": 245,
        "notes": 128,
        "image":
            "https://images.pexels.com/photos/256262/pexels-photo-256262.jpeg",
        "semanticLabel": "Microscope on laboratory desk with biology samples",
        "description": "Botany, Zoology & Human Biology",
      },
      {
        "id": "physics",
        "name": "Physics",
        "icon": "science",
        "color": 0xFF1B365D,
        "gradient": [0xFF1B365D, 0xFF2D5A8F],
        "topics": 32,
        "videos": 198,
        "notes": 142,
        "image":
            "https://images.pixabay.com/photo/2017/08/30/12/45/girl-2696947_1280.jpg",
        "semanticLabel":
            "Physics equipment with formulas on blackboard background",
        "description": "Mechanics, Optics & Modern Physics",
      },
      {
        "id": "chemistry",
        "name": "Chemistry",
        "icon": "science",
        "color": 0xFF2E7D32,
        "gradient": [0xFF2E7D32, 0xFF4CAF50],
        "topics": 35,
        "videos": 210,
        "notes": 156,
        "image": "https://images.unsplash.com/photo-1532634993-15f421e42ec0",
        "semanticLabel":
            "Chemistry laboratory with colorful solutions in beakers",
        "description": "Physical, Organic & Inorganic Chemistry",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEET Subjects',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Master the core medical entrance subjects',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 24.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: neetSubjects.length,
            itemBuilder: (context, index) {
              final subject = neetSubjects[index];
              return Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: _buildSubjectCard(context, subject),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onSubjectTap(subject['id']),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 75.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Color(subject['gradient'][0]),
              Color(subject['gradient'][1]),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(subject['color']).withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image with overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: subject['image'],
                      fit: BoxFit.cover,
                      semanticLabel: subject['semanticLabel'],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(subject['color']).withValues(alpha: 0.85),
                            Color(subject['color']).withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: subject['icon'],
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'trending_up',
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${subject['topics']} Topics',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    subject['name'],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subject['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    children: [
                      _buildSubjectStat(
                        context,
                        icon: 'play_circle',
                        value: '${subject['videos']}',
                        label: 'Videos',
                      ),
                      SizedBox(width: 4.w),
                      _buildSubjectStat(
                        context,
                        icon: 'description',
                        value: '${subject['notes']}',
                        label: 'Notes',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectStat(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 16,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        SizedBox(width: 1.w),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
              TextSpan(
                text: ' $label',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
