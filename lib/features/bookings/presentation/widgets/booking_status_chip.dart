import 'package:flutter/material.dart';

import '../../domain/booking.dart';

class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusChip(this.status, {super.key});

  static Color colorOf(BookingStatus s) => switch (s) {
        BookingStatus.pending => const Color(0xFFB8741A),
        BookingStatus.confirmed => const Color(0xFF1565C0),
        BookingStatus.completed => const Color(0xFF2E7D32),
        BookingStatus.cancelled => const Color(0xFF9E9E9E),
      };

  @override
  Widget build(BuildContext context) {
    final c = colorOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: c, fontWeight: FontWeight.w600)),
    );
  }
}
