import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/supabase_service.dart';
import '../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

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

    final success = await ref.read(authProvider.notifier).completeLogin(
          name: name,
          phone: phone,
          pincode: pincode,
        );

    // On success, GoRouter redirect fires automatically (isAuthenticated → true)
    // On failure, error SnackBar is shown via the listener below
    if (success && mounted) {
      // Router handles navigation to /home
    }
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_pin_rounded,
                      color: AppColors.forestGreen, size: 32),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                // Title
                Text(
                  l10n.userDetailsTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 6),

                Text(
                  l10n.userDetailsSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 32),

                // ── Name ──────────────────────────
                Text(l10n.enterName,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    hintText: 'Farmer Muthusamy',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                // ── Village / Town ────────────────
                Text(l10n.enterAddress,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressCtrl,
                  textCapitalization: TextCapitalization.words,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    hintText: l10n.addressHint,
                    prefixIcon: const Icon(Icons.location_city_rounded),
                  ),
                  // Address is optional — no validator
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 20),

                // ── Pincode ───────────────────────
                Text(l10n.enterPincode,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pincodeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  enabled: !authState.isLoading,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: '636001',
                    counterText: '',
                    prefixIcon: Icon(Icons.pin_drop_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length != 6) {
                      return 'Enter a valid 6-digit pincode';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 36),

                // ── Submit button ─────────────────
                SizedBox(
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
                ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
