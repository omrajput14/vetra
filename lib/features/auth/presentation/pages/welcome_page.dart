import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/language-settings'),
            icon: const Icon(Icons.language, size: 18, color: AppColors.primary),
            label: Text(
              AppLocales.getLanguageNativeName(activeLocale.languageCode),
              style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                l10n?.welcomeToVetra ?? 'Welcome to Vetra',
                style: AppTypography.screenTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.chooseHowToContinue ?? 'Choose how you want to continue',
                style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 36),
              _buildRoleCard(
                context,
                title: l10n?.continueAsFarmer ?? 'Continue as Farmer',
                description: l10n?.farmerRoleDesc ?? 'Herd management, AI disease scanner, local vet booking & outbreak alerts.',
                emoji: '🐄',
                color: AppColors.primary,
                onTap: () => context.push('/farmer-login'),
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                context,
                title: l10n?.continueAsVet ?? 'Continue as Veterinarian',
                description: l10n?.vetRoleDesc ?? 'Clinical triage, case diagnostics, digital prescriptions & farm consultations.',
                emoji: '🩺',
                color: AppColors.primary,
                onTap: () => context.push('/vet-login'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderHairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(description, style: AppTypography.captionMetadata.copyWith(height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMetadata),
          ],
        ),
      ),
    );
  }
}
