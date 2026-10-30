import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../onboarding/providers/auth_provider.dart';
import '../widgets/brand_carousel.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/welcome_card.dart';

/// Home dashboard: welcome card, promo banners and the IGO group companies.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(authProvider).profile;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go(Routes.profile),
            child: WelcomeCard(
              userName: profile?.name ?? 'Farmer',
              pincode: profile?.pincode ?? '',
            ),
          ),
          const SizedBox(height: 20),
          const HeroBannerCarousel(),
          const SizedBox(height: 28),
          Text('IGO GROUPS',
              style: theme.textTheme.headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
              children: [
                const TextSpan(text: 'Unit of the igo precious farming '),
                TextSpan(
                  text: 'PVT LTD.',
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const BrandCarousel(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
