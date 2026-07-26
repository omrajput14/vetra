import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class DiagnosisEntryPage extends StatelessWidget {
  const DiagnosisEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Clinical Diagnosis Entry', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(labelText: 'Primary Clinical Findings', hintText: 'High fever, vesicular lesions around mouth'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Differential Diagnosis', hintText: 'Foot and Mouth Disease (FMD)'),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save Diagnosis Entry',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
