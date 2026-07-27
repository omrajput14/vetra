import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

class FarmerRegisterPage extends StatefulWidget {
  const FarmerRegisterPage({super.key});

  @override
  State<FarmerRegisterPage> createState() => _FarmerRegisterPageState();
}

class _FarmerRegisterPageState extends State<FarmerRegisterPage> {
  final _nameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _animalCountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _farmNameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _animalCountController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    authNotifier.registerFarmer(
      name: _nameController.text.isEmpty ? 'John Miller' : _nameController.text,
      farmName: _farmNameController.text.isEmpty ? 'Oak Valley Herd' : _farmNameController.text,
      phone: _phoneController.text.isEmpty ? '555-0199' : _phoneController.text,
      village: _villageController.text.isEmpty ? 'Oakhaven' : _villageController.text,
      district: _districtController.text.isEmpty ? 'Valley Region' : _districtController.text,
      state: _stateController.text.isEmpty ? 'Central Province' : _stateController.text,
      animalCount: _animalCountController.text,
    );
    context.go('/farmer-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Farmer Registration', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 12),
            Text('Register Your Farm', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text(
              'Enter farm details to enable herd surveillance and vet alerts.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            AppTextField(controller: _nameController, labelText: 'Full Name', hintText: 'John Miller'),
            const SizedBox(height: 16),
            AppTextField(controller: _farmNameController, labelText: 'Farm Name', hintText: 'Oak Valley Herd'),
            const SizedBox(height: 16),
            AppTextField(controller: _phoneController, labelText: 'Phone Number', hintText: '555-0199', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            AppTextField(controller: _villageController, labelText: 'Village', hintText: 'Oakhaven'),
            const SizedBox(height: 16),
            AppTextField(controller: _districtController, labelText: 'District', hintText: 'Valley Region'),
            const SizedBox(height: 16),
            AppTextField(controller: _stateController, labelText: 'State', hintText: 'Central Province'),
            const SizedBox(height: 16),
            AppTextField(controller: _animalCountController, labelText: 'Number of Animals (Optional)', hintText: '12', keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Create Farmer Account',
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
