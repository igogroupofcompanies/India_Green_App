import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/asset_photo.dart';
import '../../../bookings/presentation/widgets/booking_sheet.dart';
import '../../../bookings/domain/booking.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/theme/app_colors.dart';

/// IGO service offerings.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _services = [
    (title: 'Farm Planning & Consulting', desc: 'Expert guidance on crop selection, layout, and yield optimization.', photo: 'service_planning.jpg'),
    (title: 'Farming Project Setup', desc: 'End-to-end setup of modern farms, greenhouses, and livestock units.', photo: 'service_setup.jpg'),
    (title: 'Farm Infrastructure', desc: 'Irrigation systems, fencing, solar power, and smart farm structures.', photo: 'service_infrastructure.jpg'),
    (title: 'Maintenance & Support', desc: 'Ongoing technical support, equipment maintenance, and crop monitoring.', photo: 'service_support.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Services'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final s = _services[i];
              return Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Color(0xFFE9ECEA)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => showBookingSheet(context,
                      type: BookingType.service, itemTitle: s.title),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFD5DDD8), width: 3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AssetPhoto(s.photo),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(s.desc,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.forestGreen, size: 28),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
