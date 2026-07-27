import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

class VetRegisterPage extends StatefulWidget {
  const VetRegisterPage({super.key});

  @override
  State<VetRegisterPage> createState() => _VetRegisterPageState();
}

class _VetRegisterPageState extends State<VetRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regNoController = TextEditingController();
  final _qualController = TextEditingController();
  final _specController = TextEditingController();
  final _clinicController = TextEditingController();
  final _expController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _regNoController.dispose();
    _qualController.dispose();
    _specController.dispose();
    _clinicController.dispose();
    _expController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    authNotifier.registerVet(
      name: _nameController.text.isEmpty ? 'Dr. Sarah Jenkins' : _nameController.text,
      email: _emailController.text.isEmpty ? 'dr.sarah@clinic.com' : _emailController.text,
      phone: _phoneController.text.isEmpty ? '555-0188' : _phoneController.text,
      regNo: _regNoController.text.isEmpty ? 'VET-12345-XX' : _regNoController.text,
      qualification: _qualController.text.isEmpty ? 'BVSc & AH' : _qualController.text,
      specialization: _specController.text.isEmpty ? 'Large Animals' : _specController.text,
      clinicName: _clinicController.text,
      experience: _expController.text.isEmpty ? '8' : _expController.text,
    );
    context.go('/vet-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Veterinarian Registration', style: AppTypography.screenTitle),
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
            Text('Register Practice', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text(
              'Provide professional licensing details for active verification.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            AppTextField(controller: _nameController, labelText: 'Full Name', hintText: 'Dr. Sarah Jenkins'),
            const SizedBox(height: 16),
            AppTextField(controller: _emailController, labelText: 'Email', hintText: 'dr.sarah@clinic.com', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            AppTextField(controller: _phoneController, labelText: 'Phone Number', hintText: '555-0188', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            AppTextField(controller: _regNoController, labelText: 'Veterinary Registration Number', hintText: 'VET-12345-XX'),
            const SizedBox(height: 16),
            AppTextField(controller: _qualController, labelText: 'Qualification', hintText: 'BVSc & AH'),
            const SizedBox(height: 16),
            AppTextField(controller: _specController, labelText: 'Specialization', hintText: 'Large Animals'),
            const SizedBox(height: 16),
            AppTextField(controller: _clinicController, labelText: 'Clinic Name (Optional)', hintText: 'Valley Animal Clinic'),
            const SizedBox(height: 16),
            AppTextField(controller: _expController, labelText: 'Years of Experience', hintText: '8', keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Register Practice',
              onPressed: _handleRegister,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
