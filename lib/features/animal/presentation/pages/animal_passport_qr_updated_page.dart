import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../data/models/animal_dto.dart';
import '../providers/animal_provider.dart';

class AnimalPassportQrUpdatedPage extends StatelessWidget {
  final String? animalId;
  final AnimalModel? animal;

  const AnimalPassportQrUpdatedPage({
    super.key,
    this.animalId,
    this.animal,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animalNotifier,
      builder: (context, _) {
        AnimalModel? activeAnimal = animal;
        if (activeAnimal == null) {
          final targetId = animalId ?? animalNotifier.selectedAnimalId;
          if (targetId != null && targetId.isNotEmpty) {
            final matches = animalNotifier.animals.where((a) => a.id == targetId);
            if (matches.isNotEmpty) {
              activeAnimal = matches.first;
            }
          }
          if (activeAnimal == null && animalNotifier.animals.isNotEmpty) {
            activeAnimal = animalNotifier.animals.first;
          }
        }

        final qrPayload = activeAnimal?.qrCodeId?.isNotEmpty == true
            ? activeAnimal!.qrCodeId!
            : (activeAnimal?.tagNumber.isNotEmpty == true
                ? activeAnimal!.tagNumber
                : (activeAnimal?.id ?? 'VETRA-DEMO-TAG'));

        final tagNumber = activeAnimal?.tagNumber ?? 'Not Assigned';
        final animalName = activeAnimal?.displayName ?? 'Animal';
        final species = activeAnimal?.species ?? 'LIVESTOCK';
        final breed = activeAnimal?.breed ?? 'Native';
        final ownerName = activeAnimal?.farmerName.isNotEmpty == true
            ? activeAnimal!.farmerName
            : 'Registered Farmer';

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text('Digital Animal Passport', style: AppTypography.screenTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Passport Card Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderHairline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/branding/vetra_logo_transparent.png', height: 26, width: 26),
                            const SizedBox(width: 8),
                            Text(
                              'PASHU SATHI HEALTH PASSPORT',
                              style: AppTypography.captionMetadata.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Real Scannable QR Code with quiet zone
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: qrPayload,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.primary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // QR Identifier Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.qr_code, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                qrPayload,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // Animal Metadata Grid
                        _buildInfoRow('Animal Name', animalName),
                        const SizedBox(height: 10),
                        _buildInfoRow('Ear Tag Number', tagNumber),
                        const SizedBox(height: 10),
                        _buildInfoRow('Species / Breed', '$species • $breed'),
                        const SizedBox(height: 10),
                        _buildInfoRow('Registered Owner', ownerName),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Helper Guidance Note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Field veterinarians can scan this tag using the VETRA app to instantly access the complete medical timeline and vaccination history.',
                            style: AppTypography.captionMetadata.copyWith(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.captionMetadata.copyWith(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }
}

