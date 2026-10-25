import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/coming_soon_view.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScaffold(
      title: 'Estates & Franchises', icon: Icons.storefront_rounded);
}
