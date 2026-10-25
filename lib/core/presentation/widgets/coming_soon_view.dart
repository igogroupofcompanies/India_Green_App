import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Honest placeholder for features that are not live yet. Never show fabricated data instead.
class ComingSoonScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const ComingSoonScaffold({
    super.key,
    required this.title,
    required this.icon,
    this.message = 'This feature is coming soon. We will let you know when it is ready.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: AppColors.harvestGold),
              const SizedBox(height: 16),
              Text('Coming soon',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
