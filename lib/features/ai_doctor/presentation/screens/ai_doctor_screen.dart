import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/coming_soon_view.dart';
import '../../../../l10n/app_localizations.dart';

/// Crop Doctor is not live yet; it must not show made-up diagnoses to farmers.
class AiDoctorScreen extends StatelessWidget {
  const AiDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoonScaffold(
      title: AppLocalizations.of(context).cropDoctor,
      icon: Icons.document_scanner_rounded,
      message: 'Crop disease scanning is being built. Until it is ready, please consult your local agriculture officer.',
    );
  }
}
