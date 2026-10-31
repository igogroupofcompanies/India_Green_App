import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/asset_photo.dart';
import '../../../../core/presentation/widgets/page_dots.dart';

/// Auto-advancing promo banners at the top of Home.
class HeroBannerCarousel extends StatefulWidget {
  const HeroBannerCarousel({super.key});

  // Add more files to this list to get an auto-advancing carousel.
  static const banners = ['banner_1.png'];

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (HeroBannerCarousel.banners.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % HeroBannerCarousel.banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: [
                for (final b in HeroBannerCarousel.banners) AssetPhoto(b),
              ],
            ),
          ),
        ),
        if (HeroBannerCarousel.banners.length > 1) ...[
          const SizedBox(height: 14),
          PageDots(count: HeroBannerCarousel.banners.length, index: _index),
        ],
      ],
    );
  }
}
