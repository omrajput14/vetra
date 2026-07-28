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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _animalCountController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _farmNameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _animalCountController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Email, Password, and Full Name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await authNotifier.registerFarmer(
      email: email,
      password: password,
      name: name,
      farmName: _farmNameController.text.trim(),
      phone: phone.isEmpty ? '+15550199' : phone,
      village: _villageController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      animalCount: _animalCountController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/farmer-dashboard');
    } else {
      final msg = authNotifier.errorMessage ?? 'Farmer registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
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
            AppTextField(controller: _emailController, labelText: 'Email', hintText: 'john@farm.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Minimum 6 characters',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMetadata),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _nameController, labelText: 'Full Name', hintText: 'John Miller'),
            const SizedBox(height: 16),
            AppTextField(controller: _farmNameController, labelText: 'Farm Name', hintText: 'Oak Valley Herd'),
            const SizedBox(height: 16),
            AppTextField(controller: _phoneController, labelText: 'Phone Number', hintText: '+15550199', keyboardType: TextInputType.phone),
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
              label: _isLoading ? 'Registering...' : 'Create Farmer Account',
              onPressed: _isLoading ? null : _handleRegister,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
