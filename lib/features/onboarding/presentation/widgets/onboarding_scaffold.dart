import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared frame for the onboarding steps: green header with the logo, a step
/// indicator and title, then the step's content, with an optional pinned
/// bottom action.
class OnboardingScaffold extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? bottom;
  final VoidCallback? onBack;

  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
    this.totalSteps = 4,
    this.bottom,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Collapse the header while the keyboard is open so forms keep their room.
    final compact = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.forestGreen, Color(0xFF16502E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, compact ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (onBack != null)
                          IconButton(
                            tooltip: 'Back',
                            onPressed: onBack,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                          )
                        else
                          Container(
                            width: 36,
                            height: 36,
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
                                  color: AppColors.forestGreen),
                            ),
                          ),
                        const Spacer(),
                        Text('Step $step of $totalSteps',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: step / totalSteps,
                        minHeight: 5,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.harvestGold),
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 20),
                    Text(title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: child),
          if (bottom != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: bottom,
              ),
            ),
        ],
      ),
    );
  }
}
