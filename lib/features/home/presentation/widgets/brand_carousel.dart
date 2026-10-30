import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/coming_soon_snack.dart';
import '../../../../core/presentation/widgets/page_dots.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// One-card-per-page carousel of IGO group companies.
class BrandCarousel extends StatefulWidget {
  const BrandCarousel({super.key});

  static const _brands = [
    (name: 'IGO Agri Mart', tag: 'RECOMMENDED', logo: 'brand_agrimart.png', icon: Icons.storefront_rounded, desc: 'Your one-stop agri inputs retail network — seeds, nutrients, polyhouse materials and more.'),
    (name: 'Farm Gate Mandi', tag: 'POPULAR', logo: 'brand_mandi.png', icon: Icons.balance_rounded, desc: 'Direct farmer-to-buyer network'),
    (name: 'IGO Nursery', tag: '', logo: 'brand_nursery.png', icon: Icons.local_florist_rounded, desc: 'Plant saplings & micro-greens'),
    (name: 'IGO Farmlands', tag: 'PREMIUM', logo: 'brand_farmlands.png', icon: Icons.grass_rounded, desc: 'Modern lease farming system'),
    (name: 'IGO Fintech', tag: '', logo: 'brand_fintech.png', icon: Icons.account_balance_rounded, desc: 'Credit & loans for agriculture'),
    (name: 'Palm Cafe', tag: '', logo: 'brand_palmcafe.png', icon: Icons.local_cafe_rounded, desc: 'Organic farm-to-table chain'),
    (name: 'IGO Academy', tag: '', logo: 'brand_academy.png', icon: Icons.school_rounded, desc: 'Agritech education & certifications'),
    (name: 'IGO Biotech', tag: '', logo: 'brand_biotech.png', icon: Icons.biotech_rounded, desc: 'Organic farming formulations'),
    (name: 'IGO Exports', tag: '', logo: 'brand_exports.png', icon: Icons.public_rounded, desc: 'Global organic distribution'),
    (name: 'IGO Logistics', tag: '', logo: 'brand_logistics.png', icon: Icons.local_shipping_rounded, desc: 'Refrigerated supply chain'),
    (name: 'Soil Sense', tag: 'NEW', logo: 'brand_soilsense.png', icon: Icons.sensors_rounded, desc: 'IoT sensors for soil analytics'),
  ];

  @override
  State<BrandCarousel> createState() => _BrandCarouselState();
}

class _BrandCarouselState extends State<BrandCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brands = BrandCarousel._brands;
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _controller,
            itemCount: brands.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: _BrandCard(brand: brands[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        PageDots(count: brands.length, index: _index),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  final ({String name, String tag, String logo, IconData icon, String desc}) brand;

  const _BrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF8FA89B), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.softGray,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 52,
                      child: Image.asset(
                        'assets/images/${brand.logo}',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(brand.icon,
                            size: 36, color: AppColors.forestGreen),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(brand.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          if (brand.tag.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreenBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(brand.tag,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                      color: AppColors.forestGreen,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(brand.desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: AppColors.textSecondary)),
                ),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => brand.name == 'IGO Agri Mart'
                          ? context.go(Routes.agrimart)
                          : showComingSoon(context, brand.name),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('More'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forestGreen,
                        backgroundColor: AppColors.lightGreenBg,
                        side: const BorderSide(color: Color(0xFF8FA89B)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
