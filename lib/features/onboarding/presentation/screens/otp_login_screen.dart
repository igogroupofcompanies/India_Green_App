import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

/// OTP login screen — phone entry + OTP verification.
/// On success navigates to [UserDetailsScreen] to collect profile info.
class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();

  bool   _isOtpSent     = false;
  int    _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.length < 10) return;

    await ref.read(authProvider.notifier).sendOtp(_phoneCtrl.text.trim());

    final authState = ref.read(authProvider);
    if (authState.error == null && mounted) {
      setState(() {
        _isOtpSent = true;
        _resendCooldown = 30;
      });
      _startCooldown();
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6) return;

    final needsProfile = await ref.read(authProvider.notifier).verifyOtp(
          _phoneCtrl.text.trim(),
          _otpCtrl.text.trim(),
        );

    // Returning users are redirected home by the router once their profile loads.
    if (needsProfile && mounted) {
      // OTP verified — navigate to user details, passing phone as GoRouter extra
      context.go(Routes.userDetails, extra: _phoneCtrl.text.trim());
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final l10n      = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

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
                child: const Icon(Icons.phone_android_rounded,
                    color: AppColors.forestGreen, size: 32),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              Text(
                l10n.loginWithOtp,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.forestGreen,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 6),

              Text(
                'Verify your mobile number to access all features',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 32),

              // ── Phone Number ──────────────────────────────────────────────
              Text(l10n.enterPhone,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                enabled: !_isOtpSent && !authState.isLoading,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '9876543210',
                  prefixText: '+91 ',
                  counterText: '',
                  suffixIcon: _phoneCtrl.text.length == 10
                      ? const Icon(Icons.check_circle,
                          color: AppColors.growthGreen)
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // ── Send OTP button ───────────────────────────────────────────
              if (!_isOtpSent)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _phoneCtrl.text.length == 10 && !authState.isLoading
                            ? _sendOtp
                            : null,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.sendOtp),
                  ),
                ).animate().fadeIn(delay: 300.ms),

              // ── OTP Input ─────────────────────────────────────────────────
              if (_isOtpSent) ...[
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'OTP sent to +91 ${_phoneCtrl.text}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1),

                const SizedBox(height: 20),

                Text(l10n.enterOtp,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _resendCooldown <= 0 ? _sendOtp : null,
                      child: Text(_resendCooldown > 0
                          ? '${l10n.resendOtp} (${_resendCooldown}s)'
                          : l10n.resendOtp),
                    ),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: _otpCtrl.text.length == 6 &&
                                !authState.isLoading
                            ? _verifyOtp
                            : null,
                        child: authState.isLoading && _otpCtrl.text.length == 6
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(l10n.verifyOtp),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
