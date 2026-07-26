import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class AddTreatmentPage extends StatelessWidget {
  const AddTreatmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Record Treatment', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(labelText: 'Treatment Description', hintText: 'Wound dressing & antiseptic injection'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Attending Vet / Admin', hintText: 'Dr. S. Patel'),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Submit Record',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
