import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';

class DeleteAnimalConfirmationPage extends StatelessWidget {
  const DeleteAnimalConfirmationPage({super.key});

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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(Icons.warning_amber, size: 64, color: AppColors.alertCritical),
              const SizedBox(height: 16),
              Text('Remove Animal?', style: AppTypography.screenTitle),
              const SizedBox(height: 8),
              Text('This action will archive animal NL-93842 from active surveillance.', style: AppTypography.bodyDefault, textAlign: TextAlign.center),
              const Spacer(),
              PrimaryButton(
                label: 'Confirm Deletion',
                onPressed: () => context.go('/my-animals'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
