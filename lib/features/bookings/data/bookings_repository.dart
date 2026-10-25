import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failures.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/result.dart';
import '../domain/booking.dart';

class BookingsRepository {
  final SupabaseClient _client;

  BookingsRepository(this._client);

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Success(await run());
    } on PostgrestException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  Future<Result<void>> create({
    required BookingType type,
    required String itemTitle,
    required String customerName,
    required String phone,
    DateTime? preferredDate,
    String? notes,
  }) =>
      _guard(() => _client.from('bookings').insert({
            'type': type.db,
            'item_title': itemTitle,
            'customer_name': customerName,
            'phone': phone,
            'preferred_date': preferredDate?.toIso8601String().substring(0, 10),
            'notes': (notes ?? '').trim().isEmpty ? null : notes!.trim(),
          }));

  Future<Result<List<Booking>>> mine() => _guard(() async {
        final rows = await _client
            .from('bookings')
            .select()
            .eq('user_id', _client.auth.currentUser!.id)
            .order('created_at', ascending: false);
        return rows.map(Booking.fromJson).toList();
      });

  Future<Result<void>> cancel(String id) =>
      _guard(() => _client.rpc('cancel_booking', params: {'p_id': id}));

  Future<Result<bool>> isAdmin() =>
      _guard(() async => (await _client.rpc('is_admin')) as bool);

  /// Admin only (enforced by RLS): every booking, newest first.
  Future<Result<List<Booking>>> all() => _guard(() async {
        final rows = await _client
            .from('bookings')
            .select()
            .order('created_at', ascending: false)
            .limit(500);
        return rows.map(Booking.fromJson).toList();
      });

  Future<Result<void>> update(
    String id, {
    required BookingStatus status,
    String? adminNotes,
  }) =>
      _guard(() => _client.from('bookings').update({
            'status': status.db,
            'admin_notes':
                (adminNotes ?? '').trim().isEmpty ? null : adminNotes!.trim(),
          }).eq('id', id));
}

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => BookingsRepository(ref.read(supabaseServiceProvider).client),
);
