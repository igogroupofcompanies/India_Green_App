import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/asset_photo.dart';
import '../../../../core/presentation/widgets/coming_soon_snack.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// Product catalogue categories as a two-column photo grid.
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  static const _categories = [
    (title: 'Agri Farming Inputs', subtitle: 'Seeds, Nutrition & Protection', photo: 'product_inputs.jpg', route: Routes.agrimart),
    (title: 'Polyhouse Structure', subtitle: 'Greenhouse & Structures', photo: 'product_polyhouse.jpg', route: null),
    (title: 'Horticulture Catalog', subtitle: 'Exotics, Fruits & Flowers', photo: 'product_horticulture.jpg', route: null),
    (title: 'Control & Automation', subtitle: 'Dosing & Automation Systems', photo: 'product_automation.jpg', route: null),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 236,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) {
        final c = _categories[i];
        return _ProductCard(
          title: c.title,
          subtitle: c.subtitle,
          photo: c.photo,
          onExplore: () => c.route != null
              ? context.go(c.route!)
              : showComingSoon(context, c.title),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String photo;
  final VoidCallback onExplore;

  const _ProductCard({
    required this.title,
    required this.subtitle,
    required this.photo,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 108, child: AssetPhoto(photo)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold, height: 1.25)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onExplore,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.forestGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Explore',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
