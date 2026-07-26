import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class RegisterVetDetailsPage extends StatelessWidget {
  const RegisterVetDetailsPage({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 12),
            Text('Veterinarian Registration', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text('Please provide your details to access the clinical system.', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            const AppTextField(labelText: 'Full Name', hintText: 'Dr. Jane Doe'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Clinic Name', hintText: 'Valley Animal Hospital'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Phone Number', hintText: '(555) 123-4567', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Email Address', hintText: 'jane.doe@example.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Veterinary License Number', hintText: 'VET-12345-XX'),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Create Account',
              onPressed: () => context.push('/email-verification'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
