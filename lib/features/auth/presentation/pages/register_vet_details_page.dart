import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterVetDetailsPage extends StatefulWidget {
  const RegisterVetDetailsPage({super.key});

  @override
  State<RegisterVetDetailsPage> createState() => _RegisterVetDetailsPageState();
}

class _RegisterVetDetailsPageState extends State<RegisterVetDetailsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    authNotifier.registerVet(
      name: _nameController.text.isEmpty ? 'Dr. Sarah Jenkins' : _nameController.text,
      email: _emailController.text.isEmpty ? 'dr.sarah@clinic.com' : _emailController.text,
      phone: _phoneController.text.isEmpty ? '555-0188' : _phoneController.text,
      regNo: _licenseController.text.isEmpty ? 'VET-12345-XX' : _licenseController.text,
      qualification: 'BVSc & AH',
      specialization: 'Large Animals',
      clinicName: 'Valley Animal Hospital',
      experience: '8',
    );
    context.push('/email-verification');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            Text('Veterinarian Registration', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text('Please provide your details to access the clinical system.', style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            AppTextField(controller: _nameController, labelText: 'Full Name', hintText: 'Dr. Jane Doe'),
            const SizedBox(height: 16),
            AppTextField(controller: _emailController, labelText: 'Email Address', hintText: 'jane.doe@example.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            AppTextField(controller: _phoneController, labelText: 'Phone Number', hintText: '(555) 123-4567', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            AppTextField(controller: _licenseController, labelText: 'Veterinary License Number', hintText: 'VET-12345-XX'),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Create Account',
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
