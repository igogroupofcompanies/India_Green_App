import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/bookings_repository.dart';
import '../../domain/booking.dart';
import '../../providers/bookings_provider.dart';
import '../widgets/booking_status_chip.dart';

/// The signed-in user's own booking requests.
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  Future<void> _cancel(BuildContext context, WidgetRef ref, Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel request?'),
        content: Text(b.itemTitle),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel request')),
        ],
      ),
    );
    if (ok != true) return;
    final res = await ref.read(bookingsRepositoryProvider).cancel(b.id);
    ref.invalidate(myBookingsProvider);
    if (context.mounted && res.isFailure) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.error.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        const SectionHeader('My Bookings'),
        Expanded(
          child: bookings.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(myBookingsProvider),
                child: const Text('Could not load bookings. Tap to retry.'),
              ),
            ),
            data: (list) => list.isEmpty
                ? Center(
                    child: Text('No bookings yet',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: AppColors.textMuted)))
                : RefreshIndicator(
                    onRefresh: () async => ref.refresh(myBookingsProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final b = list[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(b.type.label.toUpperCase(),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                                color: AppColors.textMuted)),
                                    const Spacer(),
                                    BookingStatusChip(b.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(b.itemTitle,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  'Requested ${DateFormat('d MMM yyyy').format(b.createdAt)}'
                                  '${b.preferredDate == null ? '' : ' • Preferred ${DateFormat('d MMM yyyy').format(b.preferredDate!)}'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                                if (b.adminNotes != null) ...[
                                  const SizedBox(height: 8),
                                  Text('Team note: ${b.adminNotes}',
                                      style: theme.textTheme.bodyMedium),
                                ],
                                if (b.status == BookingStatus.pending)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _cancel(context, ref, b),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
