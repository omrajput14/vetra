import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Forgot Password', style: AppTypography.screenTitle),
              const SizedBox(height: 8),
              Text('Enter your registered email address or phone number to receive a reset link.', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              const AppTextField(
                labelText: 'Email or Phone Number',
                hintText: 'e.g. user@farm.com or 555-0199',
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Send Reset Link',
                onPressed: () => context.push('/reset-password'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
