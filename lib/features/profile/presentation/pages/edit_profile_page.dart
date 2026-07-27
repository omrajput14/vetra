import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _facilityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = authNotifier.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.emailOrPhone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facilityController.dispose();
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

    setState(() => _isSubmitting = true);
    final success = await authNotifier.updateProfile(
      fullName: name,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      farmName: _facilityController.text.trim().isEmpty ? null : _facilityController.text.trim(),
      clinicName: _facilityController.text.trim().isEmpty ? null : _facilityController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
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
          AppTextField(
            controller: _nameController,
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _facilityController,
            labelText: 'Farm / Clinic Name',
            hintText: 'e.g. Green Valley Farm',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: '+1 555-0199',
            keyboardType: TextInputType.phone,
          ),
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
