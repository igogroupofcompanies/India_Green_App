import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/onboarding_scaffold.dart';
import '../../../../l10n/app_localizations.dart';

/// Language data model for display.
class _LangOption {
  final String name;
  final String nativeScript;
  final String greeting;

  const _LangOption(this.name, this.nativeScript, this.greeting);
}

const _languages = [
  _LangOption('Tamil', 'தமிழ்', 'வணக்கம்'),
  _LangOption('Hindi', 'हिन्दी', 'नमस्ते'),
  _LangOption('Telugu', 'తెలుగు', 'నమస్కారం'),
  _LangOption('Kannada', 'ಕನ್ನಡ', 'ನಮಸ್ಕಾರ'),
  _LangOption('Malayalam', 'മലയാളം', 'നമസ്കാരം'),
  _LangOption('Marathi', 'मराठी', 'नमस्कार'),
  _LangOption('Bengali', 'বাংলা', 'নমস্কার'),
  _LangOption('Gujarati', 'ગુજરાતી', 'નમસ્તે'),
  _LangOption('Punjabi', 'ਪੰਜਾਬੀ', 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ'),
  _LangOption('Odia', 'ଓଡ଼ିଆ', 'ନମସ୍କାର'),
  _LangOption('Assamese', 'অসমীয়া', 'নমস্কাৰ'),
  _LangOption('English', 'English', 'Hello'),
];

/// Screen for selecting the preferred app language.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String _selected = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Language selection screen is always in English so users can read it
    // before choosing their preferred language.
    return Localizations.override(
      context: context,
      locale: const Locale('en'),
      child: _buildScaffold(context, theme),
    );
  }

  Widget _buildScaffold(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context);

    return OnboardingScaffold(
      step: 1,
      totalSteps: 3,
      title: l10n.selectLanguage,
      subtitle: l10n.selectLanguageSubtitle,
      bottom: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            ref.read(localeProvider.notifier).setLanguage(_selected);
            ref.read(authProvider.notifier).setLanguage(_selected);
            context.go(Routes.otpLogin);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.harvestGold,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.continueBtn,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
        ),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = _selected == lang.name;

          return Semantics(
            button: true,
            selected: isSelected,
            label: '${lang.name} ${lang.nativeScript}',
            child: GestureDetector(
              onTap: () => setState(() => _selected = lang.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.forestGreen : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.forestGreen
                        : const Color(0xFFE3E8E5),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.forestGreen.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang.nativeScript,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lang.greeting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.harvestGold, size: 22),
                  ],
                ),
              ),
            ),
          )
              .animate(delay: (40 * index).ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, duration: 300.ms);
        },
      ),
    );
  } // end _buildScaffold
} // end _LanguageSelectionScreenState

