import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/widgets/authenticated_image.dart';
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
  final _clinicAddressController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _certificateUrlController = TextEditingController();
  final _villageController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();

  String? _profilePhotoPath;
  String? _remoteProfilePhotoUrl;
  double? _latitude;
  double? _longitude;
  bool _isDetectingLocation = false;
  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = authNotifier.currentUser;
    final dash = dashboardNotifier.dashboard;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.emailOrPhone;
      _facilityController.text = dash?.facilityName ?? user.metadata['clinicName']?.toString() ?? user.metadata['farmName']?.toString() ?? '';
      _clinicAddressController.text = user.clinicAddress ?? '';
      _qualificationController.text = user.metadata['qualification']?.toString() ?? '';
      _specializationController.text = user.metadata['specialization']?.toString() ?? '';
      _experienceController.text = user.metadata['yearsExperience']?.toString() ?? '';
      _remoteProfilePhotoUrl = user.profilePhotoUrl ?? user.metadata['profilePhotoUrl']?.toString();
      _certificateUrlController.text = user.certificateUrl ?? '';
      _villageController.text = user.metadata['village']?.toString() ?? '';
      _talukaController.text = user.metadata['taluka']?.toString() ?? '';
      _districtController.text = user.metadata['district']?.toString() ?? '';
      _stateController.text = user.metadata['state']?.toString() ?? '';
      _latitude = user.latitude;
      _longitude = user.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facilityController.dispose();
    _clinicAddressController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _certificateUrlController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() {
        _profilePhotoPath = picked.path;
        _isUploadingPhoto = true;
      });

      final uploadedUrl = await authNotifier.uploadProfilePhoto(picked.path);
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            _remoteProfilePhotoUrl = uploadedUrl;
          }
        });
        if (uploadedUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authNotifier.errorMessage ?? 'Failed to upload photo'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isUploadingPhoto = true);
    final ok = await authNotifier.deleteProfilePhoto();
    if (mounted) {
      setState(() {
        _isUploadingPhoto = false;
        if (ok) {
          _profilePhotoPath = null;
          _remoteProfilePhotoUrl = null;
        }
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo removed'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _showPhotoOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take Photo from Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (_profilePhotoPath != null || (_remoteProfilePhotoUrl != null && _remoteProfilePhotoUrl!.isNotEmpty))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefreshGPS() async {
    setState(() => _isDetectingLocation = true);
    try {
      final loc = await LocationService.instance.getCurrentLocation();
      if (!mounted) return;
      if (loc != null) {
        setState(() {
          _latitude = loc.latitude;
          _longitude = loc.longitude;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GPS coordinates refreshed'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not acquire GPS position'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPS error: $e'), backgroundColor: Colors.orange),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
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
      clinicAddress: isVet && _clinicAddressController.text.trim().isNotEmpty ? _clinicAddressController.text.trim() : null,
      profilePhotoUrl: _remoteProfilePhotoUrl,
      certificateUrl: isVet && _certificateUrlController.text.trim().isNotEmpty ? _certificateUrlController.text.trim() : null,
      village: _villageController.text.trim().isEmpty ? null : _villageController.text.trim(),
      taluka: _talukaController.text.trim().isEmpty ? null : _talukaController.text.trim(),
      district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
      state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
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
    final user = authNotifier.currentUser;

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
          // Profile Photo Input
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: AuthenticatedImage(
                    localPhotoPath: _profilePhotoPath,
                    photoUrl: _remoteProfilePhotoUrl,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 48, color: AppColors.primary),
                    ),
                  ),
                ),
                if (_isUploadingPhoto)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _isUploadingPhoto ? null : _showPhotoOptionsSheet,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _nameController,
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: 'e.g. 9876543210',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _facilityController,
            labelText: isVet ? 'Veterinary Clinic / Hospital Name' : 'Farm Name',
            hintText: isVet ? 'e.g. Anand Animal Hospital' : 'e.g. Green Pastures Dairy Farm',
          ),
          if (isVet) ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: _clinicAddressController,
              labelText: 'Clinic Full Address',
              hintText: 'e.g. Plot 12, Main Road, Pune, Maharashtra',
            ),
          ],
          const SizedBox(height: 16),
          AppTextField(
            controller: _villageController,
            labelText: 'Village / City',
            hintText: 'e.g. Haveli',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _talukaController,
            labelText: 'Taluka / Sub-district',
            hintText: 'e.g. Haveli',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _districtController,
            labelText: 'District',
            hintText: 'e.g. Pune',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _stateController,
            labelText: 'State',
            hintText: 'e.g. Maharashtra',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _latitude != null && _longitude != null
                        ? 'GPS: ${_latitude!.toStringAsFixed(4)}°, ${_longitude!.toStringAsFixed(4)}°'
                        : 'No GPS location set',
                    style: AppTypography.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: _isDetectingLocation ? null : _handleRefreshGPS,
                  icon: _isDetectingLocation
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, size: 16),
                  label: Text(_isDetectingLocation ? '...' : 'Update GPS'),
                ),
              ],
            ),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Qualification Certificate', style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (_certificateUrlController.text.isNotEmpty ? Colors.green : AppColors.cautionAmber)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _certificateUrlController.text.isNotEmpty
                              ? (user?.certificateStatus ?? 'UPLOADED')
                              : 'NOT UPLOADED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _certificateUrlController.text.isNotEmpty ? Colors.green : AppColors.cautionAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Upload or link your Veterinary Council Registration document / degree certificate for verification.',
                      style: AppTypography.captionMetadata),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showCertificateUploadDialog(),
                    icon: const Icon(Icons.upload_file),
                    label: Text(_certificateUrlController.text.isNotEmpty ? 'Replace Certificate' : 'Upload Certificate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
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

  void _showCertificateUploadDialog() {
    final controller = TextEditingController(text: _certificateUrlController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Veterinary Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide document URL or cloud certificate link for State Veterinary Council verification:',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'https://vet-council.gov.in/cert/12345.pdf',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => _certificateUrlController.text = controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Attach Document'),
          ),
        ],
      ),
    );
  }
}
