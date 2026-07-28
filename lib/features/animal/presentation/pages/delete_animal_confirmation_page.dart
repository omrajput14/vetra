import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../providers/animal_provider.dart';

class DeleteAnimalConfirmationPage extends StatefulWidget {
  final String? animalId;
  const DeleteAnimalConfirmationPage({super.key, this.animalId});

  @override
  State<DeleteAnimalConfirmationPage> createState() => _DeleteAnimalConfirmationPageState();
}

class _DeleteAnimalConfirmationPageState extends State<DeleteAnimalConfirmationPage> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    if (widget.animalId == null) {
      context.pop();
      return;
    }

    setState(() => _isDeleting = true);
    final success = await animalNotifier.deleteAnimal(widget.animalId!);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal record removed successfully')),
      );
      context.go('/my-animals');
    } else {
      final msg = animalNotifier.errorMessage ?? 'Failed to delete animal';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.alertCritical),
              const SizedBox(height: 16),
              Text('Remove Animal Record?', style: AppTypography.screenTitle),
              const SizedBox(height: 8),
              Text(
                'This action will permanently delete the animal record from your herd profile.',
                style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: _isDeleting ? 'Deleting...' : 'Confirm Deletion',
                onPressed: _isDeleting ? null : () => _handleDelete(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Cancel', style: AppTypography.buttonLabel.copyWith(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
