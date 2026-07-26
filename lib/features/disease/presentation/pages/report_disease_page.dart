import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class ReportDiseasePage extends StatelessWidget {
  const ReportDiseasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Report Suspected Outbreak', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(labelText: 'Affected Farm Location', hintText: 'Oakhaven District, Sector 4'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Estimated Affected Animals', hintText: '5', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Observed Symptoms', hintText: 'Fever, salivation, severe lameness'),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Submit Emergency Report',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
