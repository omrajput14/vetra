import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class VetVerificationPage extends StatelessWidget {
  const VetVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: const Icon(Icons.verified_user, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(l10n?.licenseVerified ?? 'License Verified', style: AppTypography.screenTitle),
              const SizedBox(height: 8),
              Text(
                l10n?.licenseVerifiedDesc ?? 'Your veterinary license has been verified with active status.',
                style: AppTypography.bodyDefault,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: l10n?.goToVetDashboard ?? 'Go to Vet Dashboard',
                onPressed: () => context.go('/vet-dashboard'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
