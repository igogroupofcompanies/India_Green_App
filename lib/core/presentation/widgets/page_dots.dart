import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Carousel position dots; the active dot stretches into a pill.
class PageDots extends StatelessWidget {
  final int count;
  final int index;

  const PageDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 28 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index ? AppColors.forestGreen : const Color(0xFFCFD6D2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
