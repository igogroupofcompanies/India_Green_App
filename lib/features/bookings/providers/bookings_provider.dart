import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/providers/auth_provider.dart';
import '../data/bookings_repository.dart';
import '../domain/booking.dart';

final myBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) async {
  final res = await ref.watch(bookingsRepositoryProvider).mine();
  return res.when(success: (d) => d, failure: (f) => throw f);
});

/// Whether the signed-in user is in the server-side `admins` table.
final isAdminProvider = FutureProvider<bool>((ref) async {
  // Re-check when the signed-in user changes.
  final userId = ref.watch(authProvider.select((a) => a.profile?.id));
  if (userId == null) return false;
  final res = await ref.watch(bookingsRepositoryProvider).isAdmin();
  return res.when(success: (d) => d, failure: (_) => false);
});

final adminBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) async {
  final res = await ref.watch(bookingsRepositoryProvider).all();
  return res.when(success: (d) => d, failure: (f) => throw f);
});
