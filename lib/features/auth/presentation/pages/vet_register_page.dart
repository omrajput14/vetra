import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class VetRegisterPage extends ConsumerStatefulWidget {
  const VetRegisterPage({super.key});

  @override
  ConsumerState<VetRegisterPage> createState() => _VetRegisterPageState();
}

class _VetRegisterPageState extends ConsumerState<VetRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regNoController = TextEditingController();
  final _qualController = TextEditingController();
  final _specController = TextEditingController();
  final _clinicController = TextEditingController();
  final _expController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _regNoController.dispose();
    _qualController.dispose();
    _specController.dispose();
    _clinicController.dispose();
    _expController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final regNo = _regNoController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || regNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.enterRequiredRegistration ?? 'Please enter Email, Password, Name, and Registration Number'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final currentLang = ref.read(localeProvider).languageCode;
    final success = await authNotifier.registerVet(
      name: name,
      email: email,
      password: password,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      regNo: regNo,
      qualification: _qualController.text.trim().isEmpty ? 'BVSc & AH' : _qualController.text.trim(),
      specialization: _specController.text.trim().isEmpty ? 'General Medicine' : _specController.text.trim(),
      clinicName: _clinicController.text.trim(),
      experience: _expController.text.trim().isEmpty ? '5' : _expController.text.trim(),
      preferredLanguage: currentLang,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/vet-dashboard');
    } else {
      final msg = authNotifier.errorMessage ?? (l10n?.error ?? 'Veterinarian registration failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Locale activeLocale = const Locale('en');
    try {
      activeLocale = ref.watch(localeProvider);
    } catch (_) {}

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n?.registerVetTitle ?? 'Veterinarian Registration', style: AppTypography.screenTitle),
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
            Text(l10n?.registerPractice ?? 'Register Practice', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text(
              l10n?.registerPracticeSubtitle ?? 'Provide professional licensing details for active verification.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(l10n?.preferredLanguage ?? 'Preferred Language', style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLanguageChip('en', '🇬🇧 English', activeLocale.languageCode == 'en'),
                const SizedBox(width: 8),
                _buildLanguageChip('hi', '🇮🇳 हिंदी', activeLocale.languageCode == 'hi'),
                const SizedBox(width: 8),
                _buildLanguageChip('mr', '🇮🇳 मराठी', activeLocale.languageCode == 'mr'),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _nameController,
              labelText: l10n?.fullName ?? 'Full Name',
              hintText: 'Dr. Sarah Jenkins',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              labelText: l10n?.email ?? 'Email',
              hintText: 'dr.sarah@clinic.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              labelText: l10n?.password ?? 'Password',
              hintText: 'Minimum 6 characters',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textMetadata),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              labelText: l10n?.phone ?? 'Phone Number',
              hintText: '+15550188',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _regNoController,
              labelText: l10n?.registrationNumber ?? 'Veterinary Registration Number',
              hintText: 'VET-12345-XX',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _qualController,
              labelText: l10n?.qualification ?? 'Qualification',
              hintText: 'BVSc & AH',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _specController,
              labelText: l10n?.specialization ?? 'Specialization',
              hintText: 'Large Animals',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _clinicController,
              labelText: l10n?.clinicName ?? 'Clinic Name (Optional)',
              hintText: 'Valley Animal Clinic',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _expController,
              labelText: l10n?.yearsExperience ?? 'Years of Experience',
              hintText: '8',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: _isLoading ? (l10n?.loading ?? 'Registering...') : (l10n?.registerPractice ?? 'Register Practice'),
              onPressed: _isLoading ? null : _handleRegister,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String code, String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(localeProvider.notifier).setLocale(Locale(code));
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surfaceCard,
    );
  }
}
