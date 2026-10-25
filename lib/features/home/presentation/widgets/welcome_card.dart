import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/weather_provider.dart';

class WelcomeCard extends ConsumerWidget {
  final String userName;
  final String pincode;

  const WelcomeCard({super.key, required this.userName, required this.pincode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final weather = ref.watch(weatherProvider).valueOrNull;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E37), Color(0xFF16502E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.harvestGold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.forestGreen, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.welcomeUser(userName),
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('PIN: $pincode',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (weather != null) ...[
                Expanded(
                  child: _Chip(
                    icon: Icons.wb_sunny_rounded,
                    label:
                        '${weather.tempC.toStringAsFixed(1)}°C ${weather.summary}',
                    color: Colors.white,
                    fill: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _Chip(
                  icon: Icons.eco_rounded,
                  label: 'Good Farming Day',
                  color: AppColors.harvestGold,
                  fill: AppColors.harvestGold.withValues(alpha: 0.15),
                  border: AppColors.harvestGold.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color fill;
  final Color? border;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.fill,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.harvestGold, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    letterSpacing: 0.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
