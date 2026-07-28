import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class VetRegistrationPage extends StatelessWidget {
  const VetRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Veterinarian Registration', style: AppTypography.screenTitle),
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
            Text('Register Practice', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text(
              'Provide professional licensing details to access clinical features.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const AppTextField(labelText: 'Full Name', hintText: 'Dr. Jane Doe'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Email Address', hintText: 'jane.doe@clinic.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Phone Number', hintText: '555-0188', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Veterinary Registration Number', hintText: 'VET-12345-XX'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Qualification', hintText: 'BVSc & AH / MVSc'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Specialization', hintText: 'Large Animals / Bovine Medicine'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Clinic Name (Optional)', hintText: 'Valley Animal Hospital'),
            const SizedBox(height: 16),
            const AppTextField(labelText: 'Years of Experience', hintText: '8', keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Submit Practitioner Details',
              onPressed: () => context.go('/vet-verification'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
