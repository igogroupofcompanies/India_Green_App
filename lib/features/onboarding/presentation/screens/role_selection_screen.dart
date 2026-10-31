import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../widgets/onboarding_scaffold.dart';
import '../../../../l10n/app_localizations.dart';

/// Role data for the selection grid.
class _RoleOption {
  final String nameKey;
  final String emoji;
  final String descKey;
  final Color accentColor;

  const _RoleOption(this.nameKey, this.emoji, this.descKey, this.accentColor);
}

// Store keys instead of translated strings so we can translate them dynamically in build()
const _roles = [
  _RoleOption('roleFarmer', '👨‍🌾', 'roleFarmerDesc', AppColors.forestGreen),
  _RoleOption('roleVendor', '🏪', 'roleVendorDesc', AppColors.growthGreen),
  _RoleOption('roleConsumer', '🛒', 'roleConsumerDesc', AppColors.harvestGold),
  _RoleOption('roleInvestor', '💰', 'roleInvestorDesc', Color(0xFF142217)),
  _RoleOption('roleJobSeeker', '💼', 'roleJobSeekerDesc', Color(0xFF8C9D94)),
  _RoleOption('roleFranchise', '🤝', 'roleFranchiseDesc', Color(0xFFF0B33A)),
];

/// Screen for selecting user roles (multi-select).
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final selectedRoles = authState.selectedRoles;
    final l10n = AppLocalizations.of(context);
    
    String getRoleName(String key) {
      switch (key) {
        case 'roleFarmer': return l10n.roleFarmer;
        case 'roleVendor': return l10n.roleVendor;
        case 'roleConsumer': return l10n.roleConsumer;
        case 'roleInvestor': return l10n.roleInvestor;
        case 'roleJobSeeker': return l10n.roleJobSeeker;
        case 'roleFranchise': return l10n.roleFranchise;
        default: return key;
      }
    }
    
    String getRoleDesc(String key) {
      switch (key) {
        case 'roleFarmerDesc': return l10n.roleFarmerDesc;
        case 'roleVendorDesc': return l10n.roleVendorDesc;
        case 'roleConsumerDesc': return l10n.roleConsumerDesc;
        case 'roleInvestorDesc': return l10n.roleInvestorDesc;
        case 'roleJobSeekerDesc': return l10n.roleJobSeekerDesc;
        case 'roleFranchiseDesc': return l10n.roleFranchiseDesc;
        default: return key;
      }
    }

    return OnboardingScaffold(
      step: 2,
      title: l10n.selectRoles,
      subtitle: l10n.selectRolesSubtitle,
      onBack: () => context.go(Routes.languageSelect),
      bottom: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: selectedRoles.isEmpty
              ? null
              : () => context.go(Routes.otpLogin),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.harvestGold,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.softGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: selectedRoles.isEmpty ? 0 : 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  selectedRoles.isEmpty
                      ? l10n.selectAtLeastOneRole
                      : l10n.continueWithRoles(selectedRoles.length),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selectedRoles.isEmpty
                        ? AppColors.textMuted
                        : Colors.white,
                  ),
                ),
              ),
              if (selectedRoles.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ],
          ),
        ),
      ),
      child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  itemCount: _roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    final roleName = getRoleName(role.nameKey);
                    final roleDesc = getRoleDesc(role.descKey);
                    final isSelected = selectedRoles.contains(role.nameKey);

                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(authProvider.notifier)
                            .toggleRole(role.nameKey);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? role.accentColor.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? role.accentColor
                                : AppColors.softGray,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: role.accentColor.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Emoji avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: role.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(role.emoji,
                                  style: const TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 14),

                            // Label & subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    roleName,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? role.accentColor
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    roleDesc,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Checkmark
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? role.accentColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? role.accentColor
                                      : AppColors.textMuted.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded,
                                      size: 16, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: (60 * index).ms)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, duration: 300.ms);
                  },
                ),
    );
  }
}
