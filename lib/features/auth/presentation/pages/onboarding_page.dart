import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/buttons/secondary_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined, size: 80, color: AppColors.primary),
                      ),
                      const SizedBox(height: 32),
                      Text('Protect Your Herd', style: AppTypography.screenTitle, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(
                        'AI-powered disease detection and instant vet connections in your pocket.',
                        style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    label: 'Get Started',
                    onPressed: () => context.go('/welcome-role'),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Sign In',
                    onPressed: () => context.go('/welcome-role'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
