import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../bookings/domain/booking.dart';
import '../../../bookings/domain/booking_catalog.dart';
import '../../../bookings/presentation/widgets/booking_sheet.dart';

/// Quick booking entry points for the four bookable areas.
class BookNowSection extends StatelessWidget {
  const BookNowSection({super.key});

  static const _tiles = [
    (type: BookingType.project, icon: Icons.folder_special_rounded, caption: 'Farm projects'),
    (type: BookingType.product, icon: Icons.storefront_rounded, caption: 'Farm inputs'),
    (type: BookingType.service, icon: Icons.design_services_rounded, caption: 'Expert support'),
    (type: BookingType.course, icon: Icons.school_rounded, caption: 'Training'),
  ];

  Future<void> _choose(BuildContext context, BookingType type) async {
    final options = bookingCatalog[type] ?? const <String>[];
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(type.sheetTitle,
                  style: Theme.of(ctx)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            for (final o in options)
              ListTile(
                title: Text(o),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.forestGreen),
                onTap: () => Navigator.pop(ctx, o),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null && context.mounted) {
      await showBookingSheet(context, type: type, itemTitle: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Book Now',
            style: theme.textTheme.headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text('Reserve a project, product, service or course',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: [
            for (final t in _tiles)
              Material(
                color: Colors.white,
                elevation: 1.5,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _choose(context, t.type),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.harvestGold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(t.icon,
                              color: AppColors.forestGreen, size: 24),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.type.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold)),
                              Text(t.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
