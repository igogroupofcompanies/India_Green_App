import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/route_names.dart';

/// Notification type severity levels.
enum NotificationType { info, warning, success, urgent }

/// A single in-app notification.
class IgoNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationType type;
  final String targetRoute;
  final bool isNew;

  const IgoNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.targetRoute,
    this.isNew = true,
  });

  IgoNotification copyWith({bool? isNew}) => IgoNotification(
        id: id,
        title: title,
        description: description,
        timestamp: timestamp,
        type: type,
        targetRoute: targetRoute,
        isNew: isNew ?? this.isNew,
      );

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// State holding the notification list shown in the bell tray.
class NotificationState {
  final List<IgoNotification> notifications;

  const NotificationState({this.notifications = const []});

  NotificationState copyWith({List<IgoNotification>? notifications}) =>
      NotificationState(notifications: notifications ?? this.notifications);
}

/// Manages the in-app notification list. No pop-up bubble is shown; new items
/// appear as the unread badge on the bell.
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState()) {
    // Initial welcome notification
    push(IgoNotification(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      title: '🌱 Welcome to INDIA GREEN APP',
      description:
          'Successfully logged in. Explore AgriMart or check Live Mandi prices.',
      timestamp: DateTime.now(),
      type: NotificationType.success,
      targetRoute: Routes.home,
    ));
  }

  void push(IgoNotification notification) {
    state = state.copyWith(notifications: [notification, ...state.notifications]);
  }

  void markRead(String id) {
    final updated = state.notifications.map((n) {
      return n.id == id ? n.copyWith(isNew: false) : n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllRead() {
    final updated =
        state.notifications.map((n) => n.copyWith(isNew: false)).toList();
    state = state.copyWith(notifications: updated);
  }

  void clearAll() {
    state = state.copyWith(notifications: []);
  }
}

final notificationStateProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
