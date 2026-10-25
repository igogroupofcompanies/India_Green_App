import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/coming_soon_view.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScaffold(
      title: 'Vendor Dashboard', icon: Icons.store_rounded);
}
