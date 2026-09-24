import '../../../../core/widgets/authenticated_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/health_timeline_card.dart';
import '../../../../core/models/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/animal_dto.dart';
import '../providers/animal_provider.dart';

class AnimalPassportPage extends StatefulWidget {
  final String animalId;
  const AnimalPassportPage({super.key, required this.animalId});

  @override
  State<AnimalPassportPage> createState() => _AnimalPassportPageState();
}

class _AnimalPassportPageState extends State<AnimalPassportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.animalId.isNotEmpty) {
        animalNotifier.fetchAnimalById(widget.animalId);
        animalNotifier.loadTimeline(widget.animalId);
        animalNotifier.loadHealthStatus(widget.animalId);
      }
    });
  }

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

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'HEALTHY':
        return const Color(0xFF16A34A); // Green
      case 'ATTENTION_REQUIRED':
        return const Color(0xFFEA580C); // Orange
      case 'TREATMENT_IN_PROGRESS':
        return const Color(0xFF0D9488); // Teal
      case 'PROTECTED':
        return const Color(0xFF7C3AED); // Purple
      case 'AI_SCREENED':
        return const Color(0xFF2563EB); // Blue
      default:
        return const Color(0xFF16A34A);
    }
  }

  String _getStatusLabel(String? status, AppLocalizations? l10n) {
    switch (status?.toUpperCase()) {
      case 'HEALTHY':
        return l10n?.healthy ?? 'Healthy';
      case 'ATTENTION_REQUIRED':
        return l10n?.attentionRequired ?? 'Attention Required';
      case 'TREATMENT_IN_PROGRESS':
        return l10n?.treatmentInProgress ?? 'Treatment in Progress';
      case 'PROTECTED':
        return l10n?.protectedStatus ?? 'Protected / Vaccinated';
      case 'AI_SCREENED':
        return l10n?.aiScreening ?? 'AI Screened';
      default:
        return l10n?.healthy ?? 'Healthy';
    }
  }

  void _showAddRecordDialog(BuildContext context, AnimalModel animal) {
    final l10n = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final symptomsController = TextEditingController();
    final treatmentController = TextEditingController();
    String selectedType = 'VACCINATION';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.addHealthRecord ?? 'Add Health Record',
                      style: AppTypography.screenTitle.copyWith(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: l10n?.consultationType ?? 'Record Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    DropdownMenuItem(value: 'VACCINATION', child: Text(l10n?.vaccination ?? 'Vaccination')),
                    DropdownMenuItem(value: 'OBSERVATION', child: Text(l10n?.observation ?? 'Observation')),
                    DropdownMenuItem(value: 'TREATMENT', child: Text(l10n?.treatment ?? 'Treatment')),
                    DropdownMenuItem(value: 'DIAGNOSIS', child: Text(l10n?.diagnosis ?? 'Diagnosis')),
                  ],
                  onChanged: (val) => setModalState(() => selectedType = val ?? 'VACCINATION'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title / Event (e.g. FMD Vaccine)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: symptomsController,
                  decoration: InputDecoration(
                    labelText: '${l10n?.symptoms ?? "Symptoms"} (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: treatmentController,
                  decoration: InputDecoration(
                    labelText: '${l10n?.treatment ?? "Treatment"} / Dose (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: '${l10n?.notes ?? "Clinical Notes"} (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;
                      Navigator.pop(ctx);
                      await animalNotifier.addHealthRecord(animal.id, {
                        'recordType': selectedType,
                        'title': titleController.text.trim(),
                        'symptoms': symptomsController.text.trim().isEmpty ? null : symptomsController.text.trim(),
                        'treatment': treatmentController.text.trim().isEmpty ? null : treatmentController.text.trim(),
                        'description': descController.text.trim().isEmpty ? null : descController.text.trim(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      l10n?.addHealthRecord ?? 'Save Record',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: animalNotifier,
      builder: (context, _) {
        final animal = animalNotifier.animals.firstWhere(
          (a) => a.id == widget.animalId,
          orElse: () => AnimalModel(
            id: widget.animalId,
            farmerId: '',
            farmerName: '',
            tagNumber: 'VETRA-TAG',
            species: 'CATTLE',
            gender: 'FEMALE',
            createdAt: '',
            updatedAt: '',
          ),
        );

        final timeline = animalNotifier.getTimeline(widget.animalId);
        final statusModel = animalNotifier.getStatus(widget.animalId);
        final statusColor = _getStatusColor(statusModel?.status);
        final statusText = _getStatusLabel(statusModel?.status, l10n);

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text(l10n?.animalPassport ?? 'Animal Passport', style: AppTypography.screenTitle),
            actions: [
              if (!animal.isDeceased)
                IconButton(
                  icon: const Icon(Icons.heart_broken_outlined, color: AppColors.alertCritical),
                  tooltip: 'Report Death',
                  onPressed: () => context.push('/report-mortality', extra: animal.id),
                ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                tooltip: l10n?.addHealthRecord ?? 'Add Record',
                onPressed: () => _showAddRecordDialog(context, animal),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () => context.push('/edit-animal', extra: animal.id),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await animalNotifier.loadTimeline(widget.animalId);
              await animalNotifier.loadHealthStatus(widget.animalId);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (animal.isDeceased)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.alertCritical.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.alertCritical, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Animal Recorded as Deceased',
                                style: TextStyle(color: AppColors.alertCritical, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Historical medical records and digital identity remain preserved below for lifetime traceability.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // 1. Digital Animal Passport Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderHairline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AuthenticatedImage(
                              localPhotoPath: animal.localPhotoPath,
                              photoUrl: animal.photoUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.pets, size: 36, color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  animal.displayName,
                                  style: AppTypography.screenTitle.copyWith(fontSize: 22),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l10n?.tagNumber ?? "Tag"}: ${animal.tagNumber}',
                                  style: AppTypography.captionMetadata.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getSpeciesLabel(animal.species, l10n),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (animal.breed != null && animal.breed!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          animal.breed!,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Visual QR Badge
                          GestureDetector(
                            onTap: () => context.push('/animal-passport-qr-updated', extra: animal),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.qr_code_2, size: 28, color: AppColors.primary),
                                  const SizedBox(height: 2),
                                  Text(
                                    'QR PASS',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Health Status Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.health_and_safety, color: statusColor, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${l10n?.healthStatus ?? "Health Status"}: $statusText',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: statusColor,
                                    ),
                                  ),
                                  if (statusModel?.statusSummary != null)
                                    Text(
                                      statusModel!.statusSummary,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Ask AI Veterinary Advisor Action
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

                // 2. Animal Details Grid
                Text(l10n?.myAnimals ?? 'Animal Details', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                _buildDetailTile(l10n?.tagNumber ?? 'Tag Number', animal.tagNumber),
                _buildDetailTile(
                  l10n?.qrPassport ?? 'QR Passport ID',
                  animal.qrCodeId ?? 'VTR-${animal.id.length >= 8 ? animal.id.substring(0, 8).toUpperCase() : animal.id.toUpperCase()}',
                ),
                _buildDetailTile(l10n?.species ?? 'Species', _getSpeciesLabel(animal.species, l10n)),
                _buildDetailTile(l10n?.breed ?? 'Breed', animal.breed ?? 'Native'),
                _buildDetailTile(l10n?.gender ?? 'Gender', _getGenderLabel(animal.gender, l10n)),
                _buildDetailTile(l10n?.fullName ?? 'Owner', animal.farmerName),

                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (label, icon, route, vetOnly) in const [
                      ('Vaccinations', Icons.vaccines, '/vaccination-schedule', false),
                      ('Deworming', Icons.medication, '/deworming-record', false),
                      ('Add Prescription', Icons.receipt_long, '/add-prescription', true),
                      ('Record Treatment', Icons.healing, '/add-treatment', true),
                    ])
                      if (!vetOnly || authNotifier.currentRole == UserRole.veterinarian)
                        OutlinedButton.icon(
                          onPressed: () => context.push(route, extra: animal.id),
                          icon: Icon(icon, size: 18),
                          label: Text(label),
                        ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. Lifetime Health Timeline Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timeline, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.healthTimeline ?? 'Lifetime Health Timeline',
                          style: AppTypography.sectionHeading,
                        ),
                      ],
                    ),
                    if (timeline.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${timeline.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (animalNotifier.isTimelineLoading && timeline.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (timeline.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderHairline),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history_outlined,
                            size: 44,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n?.noHealthRecords ?? 'No Health Records Yet',
                          style: AppTypography.cardTitle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n?.noHealthRecordsDesc ??
                              'AI screenings, vaccinations, and veterinary consultations will appear here in the animal\'s lifetime timeline.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyDefault.copyWith(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _showAddRecordDialog(context, animal),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n?.addHealthRecord ?? 'Add First Health Record'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...timeline.map((record) => HealthTimelineCard(record: record)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
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
