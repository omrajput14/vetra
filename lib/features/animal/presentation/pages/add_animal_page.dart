import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class AddAnimalPage extends StatelessWidget {
  const AddAnimalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Add New Animal', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(labelText: 'Animal Name', hintText: 'e.g. Bessie'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Tag ID', hintText: 'e.g. NL-93842'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Breed', hintText: 'e.g. Holstein'),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Age (Years)', hintText: '4', keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save Animal',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
