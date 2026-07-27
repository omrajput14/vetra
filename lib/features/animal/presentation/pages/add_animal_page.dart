import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../providers/animal_provider.dart';

class AddAnimalPage extends StatefulWidget {
  const AddAnimalPage({super.key});

  @override
  State<AddAnimalPage> createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  final _tagController = TextEditingController();
  final _qrController = TextEditingController();
  final _breedController = TextEditingController();
  final _photoUrlController = TextEditingController();

  String _selectedSpecies = 'CATTLE';
  String _selectedGender = 'FEMALE';
  bool _isSubmitting = false;

  final List<String> _speciesOptions = ['CATTLE', 'BUFFALO', 'SHEEP', 'GOAT', 'SWINE', 'POULTRY', 'OTHER'];
  final List<String> _genderOptions = ['FEMALE', 'MALE', 'UNKNOWN'];

  @override
  void dispose() {
    _tagController.dispose();
    _qrController.dispose();
    _breedController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final tag = _tagController.text.trim();
    if (tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Tag Number')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await animalNotifier.createAnimal(
      tagNumber: tag,
      qrCodeId: _qrController.text.trim().isEmpty ? null : _qrController.text.trim(),
      species: _selectedSpecies,
      breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
      gender: _selectedGender,
      photoUrl: _photoUrlController.text.trim().isEmpty ? null : _photoUrlController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal registered successfully')),
      );
      context.pop();
    } else {
      final msg = animalNotifier.errorMessage ?? 'Failed to add animal';
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
        title: Text('Register New Animal', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text('Animal Details', style: AppTypography.screenTitle.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Enter official tag and species information.', style: AppTypography.captionMetadata),
            const SizedBox(height: 24),
            AppTextField(
              controller: _tagController,
              labelText: 'Ear Tag Number *',
              hintText: 'e.g. NL-93842',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _qrController,
              labelText: 'QR Code Identifier (Optional)',
              hintText: 'e.g. QR-99410',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Species *',
                border: OutlineInputBorder(),
              ),
              items: _speciesOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSpecies = val);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _breedController,
              labelText: 'Breed (Optional)',
              hintText: 'e.g. Holstein / Jersey',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender *',
                border: OutlineInputBorder(),
              ),
              items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGender = val);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _photoUrlController,
              labelText: 'Photo URL (Optional)',
              hintText: 'https://...',
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: _isSubmitting ? 'Registering...' : 'Save Animal',
              onPressed: _isSubmitting ? null : () => _handleSubmit(),
            ),
          ],
        ),
      ),
    );
  }
}
