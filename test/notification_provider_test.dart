import 'package:flutter_test/flutter_test.dart';
import 'package:india_green_app/features/notifications/providers/notification_provider.dart';

void main() {
  test('starts with only the welcome notification (no simulated alerts)', () {
    final n = NotificationNotifier();
    addTearDown(n.dispose);

    expect(n.state.notifications, hasLength(1));
    expect(n.state.notifications.single.isNew, isTrue);
  });

  test('markAllRead and clearAll update state', () {
    final n = NotificationNotifier();
    addTearDown(n.dispose);

    n.markAllRead();
    expect(n.state.notifications.every((x) => !x.isNew), isTrue);

    n.clearAll();
    expect(n.state.notifications, isEmpty);
  });

  test('welcome notification targets the home route', () {
    final n = NotificationNotifier();
    addTearDown(n.dispose);
    expect(n.state.notifications.single.targetRoute, '/home');
  });
}
