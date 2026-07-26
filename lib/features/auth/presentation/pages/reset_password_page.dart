import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

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
              Text('Reset Password', style: AppTypography.screenTitle),
              const SizedBox(height: 8),
              Text('Create a new secure password for your account.', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              const AppTextField(
                labelText: 'New Password',
                hintText: 'New Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              const AppTextField(
                labelText: 'Confirm New Password',
                hintText: 'Confirm New Password',
                obscureText: true,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Update Password',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
