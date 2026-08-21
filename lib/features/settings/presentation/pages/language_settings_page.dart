import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n?.languageSettings ?? 'Language Settings', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.language, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.chooseLanguage ?? 'Choose your preferred language for the app and AI Advisor.',
                    style: AppTypography.captionMetadata.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildOption(
            context: context,
            ref: ref,
            flag: '🇬🇧',
            title: 'English',
            subtitle: 'English (Default)',
            code: 'en',
            isSelected: currentLocale.languageCode == 'en',
          ),
          const SizedBox(height: 12),
          _buildOption(
            context: context,
            ref: ref,
            flag: '🇮🇳',
            title: 'हिंदी',
            subtitle: 'Hindi',
            code: 'hi',
            isSelected: currentLocale.languageCode == 'hi',
          ),
          const SizedBox(height: 12),
          _buildOption(
            context: context,
            ref: ref,
            flag: '🇮🇳',
            title: 'मराठी',
            subtitle: 'Marathi',
            code: 'mr',
            isSelected: currentLocale.languageCode == 'mr',
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required WidgetRef ref,
    required String flag,
    required String title,
    required String subtitle,
    required String code,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        await ref.read(localeProvider.notifier).setLanguageCode(code);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title selected'),
              duration: const Duration(seconds: 1),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderHairline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                  Text(subtitle, style: AppTypography.captionMetadata),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textMetadata,
            ),
          ],
        ),
      ),
    );
  }
}
