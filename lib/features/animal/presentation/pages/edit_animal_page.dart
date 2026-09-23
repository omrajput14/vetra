import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/animal_provider.dart';

class EditAnimalPage extends StatefulWidget {
  final String animalId;
  const EditAnimalPage({super.key, required this.animalId});

  @override
  State<EditAnimalPage> createState() => _EditAnimalPageState();
}

class _EditAnimalPageState extends State<EditAnimalPage> {
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _qrController = TextEditingController();
  final _breedController = TextEditingController();

  String? _selectedPhotoPath;
  String? _currentPhotoUrl;
  String _selectedSpecies = 'CATTLE';
  String _selectedGender = 'FEMALE';
  bool _isSubmitting = false;

  final List<String> _speciesOptions = ['CATTLE', 'BUFFALO', 'SHEEP', 'GOAT', 'SWINE', 'POULTRY', 'OTHER'];
  final List<String> _genderOptions = ['FEMALE', 'MALE', 'UNKNOWN'];

  @override
  void initState() {
    super.initState();
    final animal = animalNotifier.animals.firstWhere((a) => a.id == widget.animalId, orElse: () => animalNotifier.animals.first);
    _nameController.text = animal.animalName ?? '';
    _tagController.text = animal.tagNumber;
    _qrController.text = animal.qrCodeId ?? '';
    _breedController.text = animal.breed ?? '';
    _selectedPhotoPath = animal.localPhotoPath;
    _currentPhotoUrl = animal.photoUrl;

    if (_speciesOptions.contains(animal.species.toUpperCase())) {
      _selectedSpecies = animal.species.toUpperCase();
    }
    if (_genderOptions.contains(animal.gender.toUpperCase())) {
      _selectedGender = animal.gender.toUpperCase();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _qrController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Ear Tag Number')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await animalNotifier.updateAnimal(
      id: widget.animalId,
      animalName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      tagNumber: tag,
      qrCodeId: _qrController.text.trim().isEmpty ? null : _qrController.text.trim(),
      species: _selectedSpecies,
      breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
      gender: _selectedGender,
      localPhotoPath: _selectedPhotoPath,
      photoUrl: _currentPhotoUrl,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(animalNotifier.lastSaveQueued
              ? 'Saved on this device. The changes will be sent when you are back online.'
              : 'Animal details updated successfully'),
        ),
      );
      context.pop();
    } else {
      final msg = animalNotifier.errorMessage ?? 'Failed to update animal';
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
        title: Text('Edit Animal Record', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text('Update Animal Details', style: AppTypography.screenTitle.copyWith(fontSize: 20)),
            const SizedBox(height: 24),
            ImagePickerField(
              label: l10n?.animalPhoto ?? 'Animal Photo',
              initialLocalPath: _selectedPhotoPath,
              initialRemoteUrl: _currentPhotoUrl,
              onImageChanged: (path) {
                setState(() {
                  _selectedPhotoPath = path;
                  if (path == null) _currentPhotoUrl = null;
                });
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              labelText: 'Animal Name (Optional)',
              hintText: 'e.g. Bessie',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _tagController,
              labelText: '${l10n?.tagNumber ?? 'Ear Tag Number'} *',
              hintText: 'e.g. NL-93842',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _qrController,
              labelText: l10n?.qrPassport ?? 'QR Code Identifier',
              hintText: 'e.g. QR-99410',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSpecies,
              decoration: InputDecoration(
                labelText: '${l10n?.species ?? 'Species'} *',
                border: const OutlineInputBorder(),
              ),
              items: _speciesOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSpecies = val);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _breedController,
              labelText: l10n?.breed ?? 'Breed',
              hintText: 'e.g. Holstein',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: '${l10n?.gender ?? 'Gender'} *',
                border: const OutlineInputBorder(),
              ),
              items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGender = val);
              },
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: _isSubmitting ? 'Updating...' : 'Update Animal',
              onPressed: _isSubmitting ? null : () => _handleUpdate(),
            ),
          ],
        ),
      ),
    );
  }
}
