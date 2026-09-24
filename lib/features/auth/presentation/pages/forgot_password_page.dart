import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

// ponytail: the backend has no reset-by-link or OTP endpoint, only change-password
// for a signed-in user. Add a real reset form once such an endpoint exists.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 12),
            Text('Forgot Password', style: AppTypography.screenTitle),
            const SizedBox(height: 16),
            Text(
              'Resetting a forgotten password is not available in PASHU SATHI yet.',
              style: AppTypography.bodyDefault,
            ),
            const SizedBox(height: 12),
            Text(
              'If you are still signed in on another phone, you can change your password there '
              'from the Security settings in your Profile.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
