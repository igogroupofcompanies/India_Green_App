import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/coming_soon_view.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScaffold(
      title: 'Farm Wallet & Loans', icon: Icons.account_balance_wallet_rounded);
}
