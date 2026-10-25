import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/coming_soon_view.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScaffold(
      title: 'Agri Jobs Portal', icon: Icons.work_rounded);
}
