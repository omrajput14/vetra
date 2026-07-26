import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Profile', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const AppTextField(labelText: 'Full Name', hintText: "John O'Connor"),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Farm Name', hintText: "O'Connor Livestock Farm"),
          const SizedBox(height: 16),
          const AppTextField(labelText: 'Phone Number', hintText: '555-0199', keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save Changes',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
