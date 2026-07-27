import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../providers/animal_provider.dart';

class AnimalPassportPage extends StatelessWidget {
  final String animalId;
  const AnimalPassportPage({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animalNotifier,
      builder: (context, _) {
        final animal = animalNotifier.animals.firstWhere(
          (a) => a.id == animalId,
          orElse: () => animalNotifier.animals.first,
        );

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text('Animal Passport', style: AppTypography.screenTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () => context.push('/edit-animal', extra: animal.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.alertCritical),
                onPressed: () => context.push('/delete-animal', extra: animal.id),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderHairline),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.pets, size: 64, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(animal.displayName, style: AppTypography.screenTitle.copyWith(fontSize: 24)),
                    if (animal.animalName != null && animal.animalName!.isNotEmpty)
                      Text('Ear Tag: ${animal.tagNumber}', style: AppTypography.captionMetadata),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(animal.species, style: AppTypography.captionMetadata.copyWith(color: Colors.white)),
                      backgroundColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Animal Telemetry & Details', style: AppTypography.sectionHeading),
              const SizedBox(height: 12),
              _buildDetailTile('Official Tag', animal.tagNumber),
              _buildDetailTile('QR Code ID', animal.qrCodeId ?? 'Not Assigned'),
              _buildDetailTile('Species', animal.species),
              _buildDetailTile('Breed', animal.breed ?? 'Unknown'),
              _buildDetailTile('Gender', animal.gender),
              _buildDetailTile('Owner', animal.farmerName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.captionMetadata),
          Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
