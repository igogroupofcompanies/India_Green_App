import 'package:flutter_test/flutter_test.dart';
import 'package:india_green_app/features/bookings/domain/booking.dart';

void main() {
  test('Booking.fromJson maps database values', () {
    final b = Booking.fromJson({
      'id': 'b1',
      'user_id': 'u1',
      'type': 'course',
      'item_title': 'Polyhouse Training',
      'customer_name': 'Vignesh A',
      'phone': '919876543210',
      'preferred_date': '2026-11-05',
      'notes': null,
      'status': 'confirmed',
      'admin_notes': 'See you then',
      'created_at': '2026-10-26T04:00:00Z',
    });

    expect(b.type, BookingType.course);
    expect(b.status, BookingStatus.confirmed);
    expect(b.preferredDate, DateTime(2026, 11, 5));
    expect(b.notes, isNull);
  });

  test('unknown database values fall back safely', () {
    expect(BookingStatus.fromDb('weird'), BookingStatus.pending);
    expect(BookingType.fromDb('weird'), BookingType.product);
  });
}
