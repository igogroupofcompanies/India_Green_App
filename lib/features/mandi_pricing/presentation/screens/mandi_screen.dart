import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/coming_soon_view.dart';
import '../../../../l10n/app_localizations.dart';

/// Live mandi prices need a real data source; no sample prices are shown meanwhile.
class MandiScreen extends StatelessWidget {
  const MandiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScaffold(
      title: AppLocalizations.of(context).liveMandiPrices,
      icon: Icons.show_chart_rounded,
      message: 'Live market prices are coming soon.',
    );
  }
}
