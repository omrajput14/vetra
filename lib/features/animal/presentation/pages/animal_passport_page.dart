import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/animal_provider.dart';
import '../widgets/animal_medical_history_widget.dart';

class AnimalPassportPage extends StatelessWidget {
  final String animalId;
  const AnimalPassportPage({super.key, required this.animalId});

  String _getSpeciesLabel(String species, AppLocalizations? l10n) {
    switch (species.toUpperCase()) {
      case 'CATTLE':
        return l10n?.cattle ?? 'Cattle';
      case 'BUFFALO':
        return l10n?.buffalo ?? 'Buffalo';
      case 'GOAT':
        return l10n?.goat ?? 'Goat';
      case 'SHEEP':
        return l10n?.sheep ?? 'Sheep';
      default:
        return species;
    }
  }

  String _getGenderLabel(String gender, AppLocalizations? l10n) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return l10n?.male ?? 'Male';
      case 'FEMALE':
        return l10n?.female ?? 'Female';
      default:
        return gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            title: Text(l10n?.qrPassport ?? 'Animal Passport', style: AppTypography.screenTitle),
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
                      Text('${l10n?.tagNumber ?? "Tag"}: ${animal.tagNumber}', style: AppTypography.captionMetadata),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(_getSpeciesLabel(animal.species, l10n), style: AppTypography.captionMetadata.copyWith(color: Colors.white)),
                      backgroundColor: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/ai-advisor', extra: animal.id),
                        icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        label: Text(
                          l10n?.askAdvisor ?? 'Ask AI Veterinary Advisor',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n?.myAnimals ?? 'Animal Details', style: AppTypography.sectionHeading),
              const SizedBox(height: 12),
              _buildDetailTile(l10n?.tagNumber ?? 'Tag Number', animal.tagNumber),
              _buildDetailTile(l10n?.qrPassport ?? 'QR Passport ID', animal.qrCodeId ?? 'Not Assigned'),
              _buildDetailTile(l10n?.species ?? 'Species', _getSpeciesLabel(animal.species, l10n)),
              _buildDetailTile(l10n?.breed ?? 'Breed', animal.breed ?? 'Unknown'),
              _buildDetailTile(l10n?.gender ?? 'Gender', _getGenderLabel(animal.gender, l10n)),
              _buildDetailTile(l10n?.fullName ?? 'Owner', animal.farmerName),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.history_edu, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n?.medicalHistory ?? 'Medical History & Clinical Records', style: AppTypography.sectionHeading),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimalMedicalHistoryWidget(animalId: animal.id),
              const SizedBox(height: 24),
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
