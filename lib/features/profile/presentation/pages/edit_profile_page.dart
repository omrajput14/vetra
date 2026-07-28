import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/models/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _facilityController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = authNotifier.currentUser;
    final dash = dashboardNotifier.dashboard;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.emailOrPhone;
      _facilityController.text = dash?.facilityName ?? user.metadata['clinicName']?.toString() ?? user.metadata['farmName']?.toString() ?? '';
      _qualificationController.text = user.metadata['qualification']?.toString() ?? '';
      _specializationController.text = user.metadata['specialization']?.toString() ?? '';
      _experienceController.text = user.metadata['yearsExperience']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facilityController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Full Name')),
      );
      return;
    }

    final isVet = authNotifier.currentRole == UserRole.veterinarian;
    final facility = _facilityController.text.trim();
    final expYears = int.tryParse(_experienceController.text.trim());

    setState(() => _isSubmitting = true);
    final success = await authNotifier.updateProfile(
      fullName: name,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      farmName: !isVet && facility.isNotEmpty ? facility : null,
      clinicName: isVet && facility.isNotEmpty ? facility : null,
      qualification: _qualificationController.text.trim().isEmpty ? null : _qualificationController.text.trim(),
      specialization: _specializationController.text.trim().isEmpty ? null : _specializationController.text.trim(),
      yearsExperience: expYears,
    );

    if (success) {
      await dashboardNotifier.loadDashboard();
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      context.pop();
    } else {
      final msg = authNotifier.errorMessage ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVet = authNotifier.currentRole == UserRole.veterinarian;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isVet ? 'Edit Vet Profile' : 'Edit Profile', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(
            controller: _nameController,
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _facilityController,
            labelText: isVet ? 'Clinic / Hospital Name' : 'Farm / Facility Name',
            hintText: isVet ? 'e.g. City Vet Practice' : 'e.g. Green Valley Farm',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: '+1 555-0199',
            keyboardType: TextInputType.phone,
          ),
          if (isVet) ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: _qualificationController,
              labelText: 'Qualification & Degrees',
              hintText: 'e.g. BVSc & AH, MVSc',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _specializationController,
              labelText: 'Clinical Specialization',
              hintText: 'e.g. Ruminant Surgery & Epidemiology',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _experienceController,
              labelText: 'Years of Experience',
              hintText: 'e.g. 10',
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 32),
          PrimaryButton(
            label: _isSubmitting ? 'Saving...' : 'Save Changes',
            onPressed: _isSubmitting ? null : () => _handleSave(),
          ),
        ],
      ),
    );
  }
}
