import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';

class RegisterRoleSelectionPage extends StatefulWidget {
  const RegisterRoleSelectionPage({super.key});

  @override
  State<RegisterRoleSelectionPage> createState() => _RegisterRoleSelectionPageState();
}

class _RegisterRoleSelectionPageState extends State<RegisterRoleSelectionPage> {
  String _selectedRole = 'farmer';

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
              Text('Create Account', style: AppTypography.screenTitle),
              const SizedBox(height: 8),
              Text('Select your role to get started.', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              _buildRoleCard(
                role: 'farmer',
                title: 'Farmer',
                description: 'Manage your livestock and get health alerts.',
                icon: Icons.agriculture,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                role: 'veterinarian',
                title: 'Veterinarian',
                description: 'Confirm diagnoses and assist local farmers.',
                icon: Icons.medical_services,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continue',
                onPressed: () {
                  if (_selectedRole == 'veterinarian') {
                    context.push('/register-vet-details');
                  } else {
                    context.push('/email-verification');
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainer : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderHairline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.3) : AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.cardTitle),
                  const SizedBox(height: 4),
                  Text(description, style: AppTypography.captionMetadata),
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
