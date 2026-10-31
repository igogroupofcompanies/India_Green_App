import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/asset_photo.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';

/// Projects hub — photo cards for the four project categories.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final categories = [
      (
        title: l10n.agriFarmingProjects,
        subtitle: 'Crops, orchards & greenhouse farming',
        icon: Icons.grass_rounded,
        color: const Color(0xFF2E7D32),
        photo: 'project_agri.jpg',
        route: Routes.agriProjects,
      ),
      (
        title: l10n.aquacultureProjects,
        subtitle: 'Fish, shrimp & aquatic farming',
        icon: Icons.waves_rounded,
        color: const Color(0xFF0277BD),
        photo: 'project_aqua.jpg',
        route: Routes.aquacultureProjects,
      ),
      (
        title: l10n.livestockFarmingProjects,
        subtitle: 'Cattle, poultry & dairy farming',
        icon: Icons.pets_rounded,
        color: const Color(0xFFE65100),
        photo: 'project_livestock.jpg',
        route: Routes.livestockProjects,
      ),
      (
        title: l10n.farmEngineeringProjects,
        subtitle: 'Irrigation, machinery & infrastructure',
        icon: Icons.engineering_rounded,
        color: const Color(0xFF6A1B9A),
        photo: 'project_engineering.jpg',
        route: Routes.farmEngineeringProjects,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final c = categories[i];
        return _ProjectCard(
          title: c.title,
          subtitle: c.subtitle,
          icon: c.icon,
          color: c.color,
          photo: c.photo,
          onTap: () => context.go(c.route),
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String photo;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.photo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AssetPhoto(photo, fallbackIcon: icon),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 12,
              bottom: 18,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
