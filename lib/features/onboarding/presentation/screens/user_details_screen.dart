import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/onboarding_scaffold.dart';

/// Collects user profile details (name, address, pincode) after OTP is verified.
/// Phone is passed via GoRouter `extra`.
class UserDetailsScreen extends ConsumerStatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(String phone) async {
    if (!_formKey.currentState!.validate()) return;

    final name    = _nameCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();

    // On success the GoRouter redirect fires (isAuthenticated → true); on
    // failure the error SnackBar is shown via the listener in build().
    await ref.read(authProvider.notifier).completeLogin(
          name: name,
          phone: phone,
          pincode: pincode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final l10n     = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    // Phone was passed from OtpLoginScreen via GoRouter extra
    // (falls back to the verified Supabase user's phone if `extra` was lost,
    // e.g. after the process was restarted mid-onboarding)
    final phone = GoRouterState.of(context).extra as String? ??
        ref.read(supabaseServiceProvider).client.auth.currentUser?.phone ??
        '';

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return OnboardingScaffold(
      step: 3,
      totalSteps: 3,
      title: l10n.userDetailsTitle,
      subtitle: l10n.userDetailsSubtitle,
      bottom: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: authState.isLoading ? null : () => _submit(phone),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.harvestGold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: authState.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.completeProfile,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.rocket_launch_rounded, size: 20),
                  ],
                ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // ── Name ──────────────────────────
                Text(l10n.enterName,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    hintText: 'Farmer Muthusamy',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 2) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // ── Village / Town ────────────────
                Text(l10n.enterAddress,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    hintText: l10n.addressHint,
                    prefixIcon: const Icon(Icons.location_city_rounded),
                  ),
                  // Address is optional — no validator
                ),

                const SizedBox(height: 20),

                // ── Pincode ───────────────────────
                Text(l10n.enterPincode,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pincodeCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) =>
                      authState.isLoading ? null : _submit(phone),
                  maxLength: 6,
                  enabled: !authState.isLoading,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '636001',
                    counterText: '',
                    prefixIcon: Icon(Icons.pin_drop_outlined),
                  ),
                  validator: (v) {
                    if (v == null || !RegExp(r'^[1-9]\d{5}$').hasMatch(v.trim())) {
                      return 'Enter a valid 6-digit pincode';
                    }
                    return null;
                  },
                ),

            ],
          ),
        ),
      ),
    );
  }
}
