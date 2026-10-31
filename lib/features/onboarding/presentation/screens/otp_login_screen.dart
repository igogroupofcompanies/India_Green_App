import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/onboarding_scaffold.dart';

/// OTP login screen — phone entry + OTP verification.
/// On success navigates to [UserDetailsScreen] to collect profile info.
class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _isOtpSent = false;
  bool _verifying = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  /// Indian mobile numbers are 10 digits starting with 6-9.
  bool get _phoneValid => RegExp(r'^[6-9]\d{9}$').hasMatch(_phoneCtrl.text);

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _sendOtp() async {
    if (!_phoneValid) return;

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
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  void _changeNumber() {
    _cooldownTimer?.cancel();
    setState(() {
      _isOtpSent = false;
      _resendCooldown = 0;
      _otpCtrl.clear();
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6 || _verifying) return;
    setState(() => _verifying = true);

    final needsProfile = await ref.read(authProvider.notifier).verifyOtp(
          _phoneCtrl.text.trim(),
          _otpCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _verifying = false);

    // Returning users are redirected home by the router once their profile loads.
    if (needsProfile) {
      // OTP verified — navigate to user details, passing phone as GoRouter extra
      context.go(Routes.userDetails, extra: _phoneCtrl.text.trim());
    } else if (ref.read(authProvider).error != null) {
      _otpCtrl.clear();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final busy = authState.isLoading || _verifying;

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
      step: 2,
      totalSteps: 3,
      title: l10n.loginWithOtp,
      subtitle: 'Verify your mobile number to access all features',
      onBack: () => context.go(Routes.languageSelect),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Phone Number ──────────────────────────────────────────────
            Text(l10n.enterPhone,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              maxLength: 10,
              enabled: !_isOtpSent && !busy,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '9876543210',
                prefixText: '+91 ',
                counterText: '',
                errorText: _phoneCtrl.text.length == 10 && !_phoneValid
                    ? 'Enter a valid mobile number'
                    : null,
                suffixIcon: _isOtpSent
                    ? TextButton(
                        onPressed: _changeNumber,
                        child: const Text('Change'),
                      )
                    : (_phoneValid
                        ? const Icon(Icons.check_circle,
                            color: AppColors.growthGreen)
                        : null),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _isOtpSent ? null : _sendOtp(),
            ),

            const SizedBox(height: 16),

            // ── Send OTP button ───────────────────────────────────────────
            if (!_isOtpSent)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _phoneValid && !busy ? _sendOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.harvestGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.sendOtp),
                ),
              ),

            // ── OTP Input ─────────────────────────────────────────────────
            if (_isOtpSent) ...[
              Container(
                padding: const EdgeInsets.all(14),
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
                    Expanded(
                      child: Text(
                        'OTP sent to +91 ${_phoneCtrl.text}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(l10n.enterOtp,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _otpCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: 6,
                enabled: !busy,
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
                onChanged: (v) {
                  setState(() {});
                  if (v.length == 6) _verifyOtp(); // verify as soon as it's complete
                },
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _resendCooldown <= 0 && !busy ? _sendOtp : null,
                    child: Text(_resendCooldown > 0
                        ? '${l10n.resendOtp} (${_resendCooldown}s)'
                        : l10n.resendOtp),
                  ),
                  SizedBox(
                    width: 140,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          _otpCtrl.text.length == 6 && !busy ? _verifyOtp : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.harvestGold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: busy && _otpCtrl.text.length == 6
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(l10n.verifyOtp),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
