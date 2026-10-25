import 'package:flutter_test/flutter_test.dart';
import 'package:india_green_app/core/error/failures.dart';
import 'package:india_green_app/core/utils/result.dart';

void main() {
  test('Success exposes its value', () {
    const r = Success<int>(1);
    expect(r.isSuccess, isTrue);
    expect(r.value, 1);
    expect(r.when(success: (v) => v + 1, failure: (_) => -1), 2);
  });

  test('Error exposes its failure', () {
    const r = Error<int>(AuthFailure('bad otp'));
    expect(r.isFailure, isTrue);
    expect(r.error.message, 'bad otp');
    expect(() => r.value, throwsStateError);
  });
}
