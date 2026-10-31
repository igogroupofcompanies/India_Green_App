import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../bookings/providers/bookings_provider.dart';
import '../../../onboarding/providers/auth_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../../../l10n/app_localizations.dart';

/// Main app shell with bottom navigation, app bar, and heads-up notification overlay.
class DashboardShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardShell({super.key, required this.navigationShell});

  // Order must match the shell branches in app_router.dart.
  List<({IconData icon, String label})> _getNavItems(AppLocalizations l10n) {
    return [
      (icon: Icons.home_rounded, label: l10n.navHome),
      (icon: Icons.folder_special_rounded, label: l10n.navProjects),
      (icon: Icons.storefront_rounded, label: 'Products'),
      (icon: Icons.design_services_rounded, label: 'Services'),
      (icon: Icons.school_rounded, label: 'Course'),
    ];
  }

  static String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'IG';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifState = ref.watch(notificationStateProvider);
    final unreadCount = notifState.notifications.where((n) => n.isNew).length;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // ── App Bar ─────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.forestGreen,
        toolbarHeight: 72,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/logo_mark.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.spa_rounded,
                  color: AppColors.forestGreen,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              l10n.appTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Account',
            onSelected: context.go,
            offset: const Offset(0, 48),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: Routes.profile, child: Text('My Profile')),
              const PopupMenuItem(
                  value: Routes.myBookings, child: Text('My Bookings')),
              if (ref.watch(isAdminProvider).valueOrNull ?? false)
                const PopupMenuItem(
                    value: Routes.admin, child: Text('Admin Panel')),
            ],
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.harvestGold,
              child: Text(
                _initials(ref.watch(authProvider).profile?.name),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Notification bell with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showNotificationTray(context, ref);
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: navigationShell,

      // ── Bottom Navigation ───────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: _getNavItems(l10n)
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  void _showNotificationTray(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notificationStateProvider.notifier);
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          // Watch so the tray reflects new/cleared notifications while open.
          final notifState = ref.watch(notificationStateProvider);
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollCtrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.forestGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.notifications,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          notifier.markAllRead();
                          Navigator.pop(ctx);
                        },
                        child: Text(l10n.markAllRead),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: notifState.notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off_rounded,
                                size: 48,
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noNotifications,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          itemCount: notifState.notifications.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 56),
                          itemBuilder: (_, i) {
                            final n = notifState.notifications[i];
                            final iconColor = switch (n.type) {
                              NotificationType.success => AppColors.success,
                              NotificationType.warning => AppColors.warning,
                              NotificationType.urgent => AppColors.error,
                              NotificationType.info => AppColors.info,
                            };
                            final icon = switch (n.type) {
                              NotificationType.success =>
                                Icons.check_circle_rounded,
                              NotificationType.warning =>
                                Icons.warning_amber_rounded,
                              NotificationType.urgent =>
                                Icons.notifications_active_rounded,
                              NotificationType.info => Icons.info_rounded,
                            };

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: iconColor.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(icon, color: iconColor, size: 20),
                              ),
                              title: Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: n.isNew
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                n.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Text(
                                n.timeAgo,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              onTap: () {
                                notifier.markRead(n.id);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
