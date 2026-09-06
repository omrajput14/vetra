import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class FarmerRegisterPage extends ConsumerStatefulWidget {
  const FarmerRegisterPage({super.key});

  @override
  ConsumerState<FarmerRegisterPage> createState() => _FarmerRegisterPageState();
}

class _FarmerRegisterPageState extends ConsumerState<FarmerRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _animalCountController = TextEditingController();

  String _selectedLanguage = 'en';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isDetectingLocation = false;
  bool _locationBannerDismissed = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Default to the current app locale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLocale = ref.read(localeProvider);
      setState(() {
        _selectedLanguage = currentLocale.languageCode;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _farmNameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _animalCountController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestLocation() async {
    setState(() => _isDetectingLocation = true);
    try {
      final result = await LocationService.instance.getCurrentLocation();
      if (!mounted) return;
      if (result != null) {
        setState(() {
          _latitude = result.latitude;
          _longitude = result.longitude;
          _locationBannerDismissed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm GPS coordinates captured successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not obtain GPS. You can enter village & taluka manually.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDetectingLocation = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final rawPhone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Email, Password, and Full Name')),
      );
      return;
    }

    // Client-side email validation
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address (e.g. name@domain.com)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Client-side password length validation
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Client-side animal count validation
    final rawAnimalCount = _animalCountController.text.trim();
    if (rawAnimalCount.isNotEmpty) {
      final count = int.tryParse(rawAnimalCount);
      if (count == null || count < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid animal count (0 or greater)'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    // Sync selected language to localeProvider
    await ref.read(localeProvider.notifier).setLanguageCode(_selectedLanguage);

    final cleanPhone = rawPhone.isEmpty ? null : rawPhone.replaceAll(RegExp(r'\s+'), '');
    final cleanFarmName = _farmNameController.text.trim().isEmpty ? null : _farmNameController.text.trim();
    final cleanVillage = _villageController.text.trim().isEmpty ? null : _villageController.text.trim();
    final cleanTaluka = _talukaController.text.trim().isEmpty ? null : _talukaController.text.trim();
    final cleanDistrict = _districtController.text.trim().isEmpty ? null : _districtController.text.trim();
    final cleanState = _stateController.text.trim().isEmpty ? null : _stateController.text.trim();

    final success = await authNotifier.registerFarmer(
      email: email,
      password: password,
      name: name,
      farmName: cleanFarmName ?? '',
      phone: cleanPhone,
      village: cleanVillage ?? '',
      taluka: cleanTaluka,
      district: cleanDistrict ?? '',
      state: cleanState ?? '',
      latitude: _latitude,
      longitude: _longitude,
      animalCount: rawAnimalCount.isEmpty ? null : rawAnimalCount,
      preferredLanguage: _selectedLanguage,
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n?.registerFarmerTitle ?? 'Farmer Registration', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            Row(
              children: [
                Image.asset('assets/branding/vetra_logo_transparent.png', height: 36, width: 36),
                const SizedBox(width: 10),
                Text('PASHU SATHI', style: AppTypography.screenTitle.copyWith(color: AppColors.primary, letterSpacing: 1.2, fontSize: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Register Your Farm', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text(
              'Enter farm details to enable herd surveillance and vet alerts.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Language Selection Section
            Text(
              l10n?.preferredLanguage ?? 'Preferred Language',
              style: AppTypography.cardTitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLanguageChip('en', '🇬🇧 English'),
                const SizedBox(width: 8),
                _buildLanguageChip('hi', '🇮🇳 हिंदी'),
                const SizedBox(width: 8),
                _buildLanguageChip('mr', '🇮🇳 मराठी'),
                const SizedBox(width: 6),
                _buildLanguageChip('ur', '🇮🇳 اردو'),
              ],
            ),
            const SizedBox(height: 20),

            // Location Permission Pre-prompt Card
            if (!_locationBannerDismissed && _latitude == null) ...[
              _buildLocationPrePromptCard(l10n),
              const SizedBox(height: 20),
            ] else if (_latitude != null && _longitude != null) ...[
              _buildLocationVerifiedCard(),
              const SizedBox(height: 20),
            ],

            AppTextField(
              controller: _emailController,
              labelText: l10n?.email ?? 'Email Address',
              hintText: 'john@farm.com',
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
            AppTextField(controller: _nameController, labelText: l10n?.fullName ?? 'Full Name', hintText: 'John Miller'),
            const SizedBox(height: 16),
            AppTextField(controller: _farmNameController, labelText: l10n?.farmName ?? 'Farm Name', hintText: 'Oak Valley Herd'),
            const SizedBox(height: 16),
            AppTextField(controller: _phoneController, labelText: l10n?.phone ?? 'Phone Number', hintText: '+15550199', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            AppTextField(controller: _villageController, labelText: l10n?.village ?? 'Village', hintText: 'Oakhaven'),
            const SizedBox(height: 16),
            AppTextField(controller: _talukaController, labelText: l10n?.taluka ?? 'Taluka / Block', hintText: 'East Taluka'),
            const SizedBox(height: 16),
            AppTextField(controller: _districtController, labelText: l10n?.district ?? 'District', hintText: 'Valley Region'),
            const SizedBox(height: 16),
            AppTextField(controller: _stateController, labelText: l10n?.state ?? 'State', hintText: 'Central Province'),
            const SizedBox(height: 16),
            AppTextField(controller: _animalCountController, labelText: l10n?.animalCount ?? 'Number of Animals', hintText: '12', keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            PrimaryButton(
              label: _isLoading ? (l10n?.loading ?? 'Registering...') : (l10n?.createAccount ?? 'Create Farmer Account'),
              onPressed: _isLoading ? null : _handleRegister,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPrePromptCard(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n?.locationPermissionTitle ?? 'Allow VETRA to use your location',
                  style: AppTypography.cardTitle.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.locationPermissionDesc ??
                'Your location helps us find nearby veterinarians, provide local animal-health alerts, and identify disease risks in your area.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _isDetectingLocation ? null : _handleRequestLocation,
                  icon: _isDetectingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.my_location, size: 18),
                  label: Text(l10n?.allowLocation ?? 'Allow Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleEdges.rounded10,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextButton(
                  onPressed: () => setState(() => _locationBannerDismissed = true),
                  child: Text(
                    l10n?.notNow ?? 'Not Now',
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationVerifiedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPS Coordinates Attached',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.green),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_latitude!.toStringAsFixed(4)}° N, ${_longitude!.toStringAsFixed(4)}° E',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
            onPressed: _isDetectingLocation ? null : _handleRequestLocation,
            tooltip: 'Refresh GPS',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String code, String label) {
    final isSelected = _selectedLanguage == code;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => _selectedLanguage = code);
          await ref.read(localeProvider.notifier).setLanguageCode(code);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderHairline,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class RoundedRectangleEdges {
  static final rounded10 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
}
