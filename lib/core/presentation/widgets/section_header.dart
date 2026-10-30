import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Green title band that continues the app bar (Services, IGO Academy).
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.forestGreen,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
