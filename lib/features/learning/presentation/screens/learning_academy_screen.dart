import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/asset_photo.dart';
import '../../../bookings/presentation/widgets/booking_sheet.dart';
import '../../../bookings/domain/booking.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/theme/app_colors.dart';

/// IGO Academy course catalogue.
class LearningAcademyScreen extends StatelessWidget {
  const LearningAcademyScreen({super.key});

  static const _courses = [
    (title: 'Polyhouse Training', desc: 'Complete training on polyhouse construction, operation, and crop management.', duration: '5 DAYS', level: 'All Levels', icon: Icons.home_work_outlined, photo: 'course_polyhouse.jpg'),
    (title: 'Hydroponics Training', desc: 'Hands-on training in soilless farming techniques and commercial NFT/DWC systems.', duration: '5 DAYS', level: 'Beginner to Advanced', icon: Icons.water_drop_rounded, photo: 'course_hydroponics.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader('IGO Academy'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _courses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final c = _courses[i];
              return _CourseCard(
                title: c.title,
                desc: c.desc,
                duration: c.duration,
                level: c.level,
                icon: c.icon,
                photo: c.photo,
                onTap: () => showBookingSheet(context,
                    type: BookingType.course, itemTitle: c.title),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final String title;
  final String desc;
  final String duration;
  final String level;
  final IconData icon;
  final String photo;
  final VoidCallback onTap;

  const _CourseCard({
    required this.title,
    required this.desc,
    required this.duration,
    required this.level,
    required this.icon,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2.2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AssetPhoto(photo, fallbackIcon: icon),
                  // Fade the photo into the white card body.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.transparent, Colors.white],
                        stops: [0, 0.7, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.lightGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.forestGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Pill(
                              label: duration,
                              icon: Icons.schedule_rounded,
                              color: const Color(0xFFB8741A),
                              fill: const Color(0xFFFBEFD9),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: _Pill(
                                label: level,
                                color: AppColors.forestGreen,
                                fill: AppColors.lightGreenBg,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(title,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        Text(desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.forestGreen, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color fill;

  const _Pill({required this.label, this.icon, required this.color, required this.fill});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
