import 'dart:async';
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

/// State holding the notification list and heads-up display state.
class NotificationState {
  final List<IgoNotification> notifications;
  final IgoNotification? currentHeadsUp;
  final bool isHeadsUpVisible;

  const NotificationState({
    this.notifications = const [],
    this.currentHeadsUp,
    this.isHeadsUpVisible = false,
  });

  NotificationState copyWith({
    List<IgoNotification>? notifications,
    IgoNotification? currentHeadsUp,
    bool? isHeadsUpVisible,
  }) =>
      NotificationState(
        notifications: notifications ?? this.notifications,
        currentHeadsUp: currentHeadsUp ?? this.currentHeadsUp,
        isHeadsUpVisible: isHeadsUpVisible ?? this.isHeadsUpVisible,
      );
}

/// Manages the in-app notification list and the heads-up banner.
class NotificationNotifier extends StateNotifier<NotificationState> {
  Timer? _dismissTimer;

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
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
      currentHeadsUp: notification,
      isHeadsUpVisible: true,
    );

    // Auto-dismiss heads-up after 6.5 seconds
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(milliseconds: 6500), dismissHeadsUp);
  }

  void dismissHeadsUp() {
    state = state.copyWith(isHeadsUpVisible: false);
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

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }
}

final notificationStateProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
