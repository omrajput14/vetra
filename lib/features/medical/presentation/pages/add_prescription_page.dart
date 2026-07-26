import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class AddPrescriptionPage extends StatelessWidget {
  const AddPrescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Add Prescription', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(labelText: 'Medication Name', hintText: 'e.g. Oxytet 200 LA'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Dosage', hintText: 'e.g. 10ml IM daily'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Duration (Days)', hintText: '5', keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save Prescription',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
