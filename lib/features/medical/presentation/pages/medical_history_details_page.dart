import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../animal/presentation/providers/animal_provider.dart';

class MedicalHistoryDetailsPage extends StatefulWidget {
  final String? animalId;

  const MedicalHistoryDetailsPage({super.key, this.animalId});

  @override
  State<MedicalHistoryDetailsPage> createState() => _MedicalHistoryDetailsPageState();
}

class _MedicalHistoryDetailsPageState extends State<MedicalHistoryDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetId = widget.animalId ?? animalNotifier.selectedAnimalId;
      if (targetId != null) {
        animalNotifier.loadTimeline(targetId);
        animalNotifier.loadHealthStatus(targetId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Medical History File', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: animalNotifier,
        builder: (context, _) {
          final targetId = widget.animalId ?? animalNotifier.selectedAnimalId;
          final animals = animalNotifier.animals;
          final animal = animals.where((a) => a.id == targetId).firstOrNull ??
              (animals.isNotEmpty ? animals.first : null);

          if (animal == null) {
            return Center(
              child: Text('No registered livestock found.', style: AppTypography.captionMetadata),
            );
          }

          final records = animalNotifier.getTimeline(animal.id);
          final status = animalNotifier.getStatus(animal.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderHairline),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Clinical File: ${animal.animalName ?? animal.tagNumber}',
                            style: AppTypography.cardTitle,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (status?.status == 'CRITICAL'
                                    ? AppColors.alertCritical
                                    : (status?.status == 'ATTENTION' ? AppColors.cautionAmber : AppColors.primary))
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status?.status ?? 'HEALTHY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: status?.status == 'CRITICAL'
                                  ? AppColors.alertCritical
                                  : (status?.status == 'ATTENTION' ? AppColors.cautionAmber : AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Tag: ${animal.tagNumber} • Species: ${animal.species}', style: AppTypography.bodySmall),
                    if (animal.breed != null) Text('Breed: ${animal.breed}', style: AppTypography.captionMetadata),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Total Records', '${records.length}'),
                        _buildStat('Vaccinations', '${records.where((r) => r.recordType == 'VACCINATION').length}'),
                        _buildStat('Treatments', '${records.where((r) => r.recordType == 'TREATMENT').length}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Chronological Records', style: AppTypography.sectionHeading),
              const SizedBox(height: 10),
              if (records.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Center(
                    child: Text('No medical records recorded for this animal.', style: AppTypography.captionMetadata),
                  ),
                )
              else
                ...records.map(
                  (r) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
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
                            Text(r.title, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                            Text(r.recordedAt.split('T').first, style: AppTypography.captionMetadata),
                          ],
                        ),
                        if (r.diagnosis != null) ...[
                          const SizedBox(height: 4),
                          Text('Diagnosis: ${r.diagnosis}', style: AppTypography.bodySmall),
                        ],
                        if (r.treatment != null) ...[
                          const SizedBox(height: 4),
                          Text('Treatment: ${r.treatment}', style: AppTypography.captionMetadata),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.cardTitle.copyWith(color: AppColors.primary, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.captionMetadata.copyWith(fontSize: 11)),
      ],
    );
  }
}
