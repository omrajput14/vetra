import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../providers/animal_provider.dart';

class AnimalTimelinePage extends StatefulWidget {
  final String? animalId;

  const AnimalTimelinePage({super.key, this.animalId});

  @override
  State<AnimalTimelinePage> createState() => _AnimalTimelinePageState();
}

class _AnimalTimelinePageState extends State<AnimalTimelinePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetId = widget.animalId ?? animalNotifier.selectedAnimalId;
      if (targetId != null) {
        animalNotifier.loadTimeline(targetId);
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
        title: Text('Animal Health Timeline', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: animalNotifier,
        builder: (context, _) {
          final targetId = widget.animalId ?? animalNotifier.selectedAnimalId;
          if (targetId == null) {
            return Center(
              child: Text('No animal selected.', style: AppTypography.captionMetadata),
            );
          }

          if (animalNotifier.isTimelineLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = animalNotifier.getTimeline(targetId);

          if (records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_toggle_off, size: 48, color: AppColors.textMetadata),
                    const SizedBox(height: 12),
                    Text('No health records found', style: AppTypography.cardTitle),
                    const SizedBox(height: 4),
                    Text('Clinical records, vaccinations, and deworming events will appear here chronologically.',
                        textAlign: TextAlign.center, style: AppTypography.captionMetadata),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final r = records[idx];
              final isVaccine = r.recordType == 'VACCINATION' || r.vaccineName != null;
              final isTreatment = r.recordType == 'TREATMENT';

              Color accentColor = AppColors.primary;
              IconData icon = Icons.medical_information_outlined;
              if (isVaccine) {
                accentColor = const Color(0xFF1976D2);
                icon = Icons.vaccines_outlined;
              } else if (isTreatment) {
                accentColor = const Color(0xFFE65100);
                icon = Icons.healing_outlined;
              }

              return Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.title.isNotEmpty ? r.title : (r.vaccineName ?? 'Health Record'),
                                      style: AppTypography.cardTitle.copyWith(fontSize: 15),
                                    ),
                                  ),
                                  Text(
                                    r.recordedAt.split('T').first,
                                    style: AppTypography.captionMetadata.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                              if (r.veterinarianName != null)
                                Text('Attending: ${r.veterinarianName}', style: AppTypography.captionMetadata),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (r.description != null && r.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(r.description!, style: AppTypography.bodySmall),
                    ],
                    if (r.treatment != null && r.treatment!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Treatment: ${r.treatment!}', style: AppTypography.captionMetadata.copyWith(color: AppColors.textPrimary)),
                      ),
                    ],
                    if (isVaccine && (r.batchNumber != null || r.nextDueDate != null)) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (r.batchNumber != null)
                            Chip(
                              label: Text('Batch: ${r.batchNumber}', style: const TextStyle(fontSize: 11)),
                              backgroundColor: Colors.blue.withValues(alpha: 0.1),
                              visualDensity: VisualDensity.compact,
                            ),
                          if (r.nextDueDate != null)
                            Chip(
                              label: Text('Next Due: ${r.nextDueDate}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
                              backgroundColor: Colors.orange.withValues(alpha: 0.1),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                    if (r.documentUrl != null && r.documentUrl!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          _showDocumentDialog(context, r.documentUrl!);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 16, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text('View Attached Certificate / Document', style: AppTypography.captionMetadata.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDocumentDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Attached Health Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Document Reference / Certificate URL:', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            SelectableText(url, style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
