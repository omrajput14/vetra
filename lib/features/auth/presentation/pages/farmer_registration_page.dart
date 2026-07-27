import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class FarmerRegistrationPage extends StatelessWidget {
  const FarmerRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Farmer Registration', style: AppTypography.screenTitle),
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
            Text('Register Your Farm', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text(
              'Enter your farm details to enable herd surveillance and vet alerts.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const AppTextField(labelText: 'Full Name', hintText: 'John Miller'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Farm Name', hintText: 'Oak Valley Herd'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Phone Number', hintText: '555-0199', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Village', hintText: 'Oakhaven'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'District', hintText: 'Valley Region'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'State', hintText: 'Central Province'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Number of Animals (Optional)', hintText: '12', keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Create Farmer Account',
              onPressed: () => context.go('/email-verification'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
