import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/coming_soon_view.dart';

class LearningAcademyScreen extends StatelessWidget {
  const LearningAcademyScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScaffold(
      title: 'IGO Academy',
      icon: Icons.school_rounded,
      message: 'Courses and certifications are coming soon.');
}
