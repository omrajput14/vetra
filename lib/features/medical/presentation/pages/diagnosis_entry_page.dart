import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';

class DiagnosisEntryPage extends StatelessWidget {
  const DiagnosisEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n?.diagnosisEntry ?? 'Clinical Diagnosis Entry', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(
            labelText: l10n?.symptoms ?? 'Primary Clinical Findings',
            hintText: 'High fever, vesicular lesions around mouth',
          ),
          const SizedBox(height: 16),
          AppTextField(
            labelText: l10n?.clinicalDiagnosis ?? 'Differential Diagnosis',
            hintText: 'Foot and Mouth Disease (FMD)',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n?.save ?? 'Save Diagnosis Entry',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
