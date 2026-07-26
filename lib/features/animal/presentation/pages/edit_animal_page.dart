import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class EditAnimalPage extends StatelessWidget {
  const EditAnimalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Animal', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(labelText: 'Animal Name', hintText: 'Bessie'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Tag ID', hintText: 'NL-93842'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Breed', hintText: 'Holstein'),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Update Details',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
