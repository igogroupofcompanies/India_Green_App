import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Photo from `assets/images/`, with a branded gradient shown until the file
/// exists so screens keep their layout before artwork is dropped in.
class AssetPhoto extends StatelessWidget {
  final String asset;
  final Alignment alignment;
  final IconData fallbackIcon;

  const AssetPhoto(
    this.asset, {
    super.key,
    this.alignment = Alignment.center,
    this.fallbackIcon = Icons.eco_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$asset',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: alignment,
      errorBuilder: (_, __, ___) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A5C35), AppColors.forestGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Icon(fallbackIcon, color: Colors.white24, size: 48),
        ),
      ),
    );
  }
}
