import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../../../animal/data/models/animal_dto.dart';
import '../../../animal/presentation/providers/animal_provider.dart';
import '../../data/models/mortality_dto.dart';
import '../providers/mortality_provider.dart';

class ReportMortalityPage extends StatefulWidget {
  final String? initialAnimalId;

  const ReportMortalityPage({super.key, this.initialAnimalId});

  @override
  State<ReportMortalityPage> createState() => _ReportMortalityPageState();
}

class _ReportMortalityPageState extends State<ReportMortalityPage> {
  final _formKey = GlobalKey<FormState>();
  final _causeDescriptionController = TextEditingController();
  final _treatmentNotesController = TextEditingController();
  final _notesController = TextEditingController();

  MortalityCauseCategory _selectedCategory = MortalityCauseCategory.unknown;
  String? _selectedDiseaseName;
  bool _recentlyTreated = false;

  // GPS state
  UserLocationResult? _locationResult;
  bool _isFetchingGps = false;
  String? _gpsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mortalityNotifier.init(preselectedAnimalId: widget.initialAnimalId);
      _fetchLocation();
    });
  }

  @override
  void dispose() {
    _causeDescriptionController.dispose();
    _treatmentNotesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isFetchingGps = true;
      _gpsError = null;
    });

    final loc = await LocationService.instance.getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _isFetchingGps = false;
      if (loc != null) {
        _locationResult = loc;
      } else {
        _gpsError = "Location permission required for disease outbreak tracing. Tap Retry to enable GPS.";
      }
    });
  }

  Future<void> _scanAnimalQr() async {
    final scannedAnimal = await context.push<AnimalModel?>('/qr-scanner-vet');
    if (scannedAnimal != null) {
      mortalityNotifier.selectAnimal(scannedAnimal);
    }
  }

  Future<void> _submit() async {
    final animal = mortalityNotifier.selectedAnimal;
    if (animal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an animal first."),
          backgroundColor: AppColors.alertCritical,
        ),
      );
      return;
    }

    if (animal.isDeceased) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This animal is already marked as deceased."),
          backgroundColor: AppColors.alertCritical,
        ),
      );
      return;
    }

    final dto = CreateMortalityReportDto(
      animalId: animal.id,
      causeCategory: _selectedCategory.apiValue,
      causeDescription: _causeDescriptionController.text.trim().isNotEmpty
          ? _causeDescriptionController.text.trim()
          : null,
      diseaseName: (_selectedCategory == MortalityCauseCategory.knownDisease ||
              _selectedCategory == MortalityCauseCategory.suspectedDisease)
          ? _selectedDiseaseName
          : null,
      recentlyTreated: _recentlyTreated,
      treatmentNotes: _recentlyTreated && _treatmentNotesController.text.trim().isNotEmpty
          ? _treatmentNotesController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      deathDateTime: DateTime.now().toUtc().toIso8601String(),
      latitude: _locationResult?.latitude,
      longitude: _locationResult?.longitude,
      locationAccuracy: 10.0,
    );

    final success = await mortalityNotifier.submitMortalityReport(dto);

    if (!mounted) return;

    if (success) {
      final isOffline = mortalityNotifier.isOfflineSaved;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isOffline ? Icons.cloud_off : Icons.check_circle,
                color: isOffline ? AppColors.cautionAmber : const Color(0xFF16A34A),
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isOffline ? "Saved Offline" : "Report Submitted",
                  style: AppTypography.screenTitle.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            mortalityNotifier.successMessage ?? "Animal mortality has been safely recorded.",
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/my-animals');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Return to Animals", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mortalityNotifier.errorMessage ?? "Submission failed. Please check details."),
          backgroundColor: AppColors.alertCritical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text("Report Animal Death", style: AppTypography.screenTitle.copyWith(fontSize: 19)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: mortalityNotifier,
        builder: (context, _) {
          final selectedAnimal = mortalityNotifier.selectedAnimal;
          final isSubmitting = mortalityNotifier.isLoading;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header guidance
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Help us protect your herd",
                              style: AppTypography.cardTitle.copyWith(fontSize: 14, color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Help us record the animal's health history and monitor possible disease spread in your village.",
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 1. SELECT / SCAN ANIMAL
                Text("1. Select or Scan Animal", style: AppTypography.sectionHeading.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderHairline),
                        ),
                        child: () {
                          final uniqueAnimals = <AnimalModel>[];
                          final seenIds = <String>{};
                          for (final a in animalNotifier.animals) {
                            if (seenIds.add(a.id)) uniqueAnimals.add(a);
                          }
                          final activeId = uniqueAnimals.any((a) => a.id == selectedAnimal?.id)
                              ? selectedAnimal?.id
                              : (uniqueAnimals.isNotEmpty ? uniqueAnimals.first.id : null);

                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: activeId,
                              hint: const Text("Select Registered Animal"),
                              items: uniqueAnimals.map((a) {
                                return DropdownMenuItem<String>(
                                  value: a.id,
                                  child: Text(
                                    "${a.displayName} (Tag #${a.tagNumber})",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: a.isDeceased ? AppColors.textSecondary : AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (id) {
                                if (id != null) mortalityNotifier.selectAnimalById(id);
                              },
                            ),
                          );
                        }(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _scanAnimalQr,
                      icon: const Icon(Icons.qr_code_scanner, size: 18),
                      label: const Text("Scan QR"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Selected Animal Summary Card
                if (selectedAnimal != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedAnimal.isDeceased ? AppColors.alertCritical : AppColors.borderHairline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.pets, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(selectedAnimal.displayName, style: AppTypography.cardTitle),
                                  Text(
                                    "Tag #${selectedAnimal.tagNumber} • ${selectedAnimal.species}",
                                    style: AppTypography.captionMetadata,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: selectedAnimal.isDeceased
                                    ? AppColors.alertCritical.withValues(alpha: 0.15)
                                    : const Color(0xFF16A34A).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                selectedAnimal.status ?? "ACTIVE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: selectedAnimal.isDeceased ? AppColors.alertCritical : const Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (selectedAnimal.isDeceased) ...[
                          const SizedBox(height: 8),
                          const Text(
                            "Warning: This animal is already registered as deceased.",
                            style: TextStyle(fontSize: 12, color: AppColors.alertCritical, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 2. CAUSE OF DEATH
                Text("2. What caused the animal's death?", style: AppTypography.sectionHeading.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MortalityCauseCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.label),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // If known or suspected disease, show disease registry selector
                if (_selectedCategory == MortalityCauseCategory.knownDisease ||
                    _selectedCategory == MortalityCauseCategory.suspectedDisease) ...[
                  Text("Select Disease Name", style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderHairline),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedDiseaseName,
                        hint: const Text("Select from Disease Registry"),
                        items: mortalityNotifier.diseaseCatalog.map((disease) {
                          return DropdownMenuItem<String>(
                            value: disease,
                            child: Text(disease),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDiseaseName = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Cause description
                TextField(
                  controller: _causeDescriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Cause Description (Optional)",
                    hintText: "e.g. Sudden weakness, fever, blisters, or injury details...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                  ),
                ),
                const SizedBox(height: 18),

                // 3. RECENT TREATMENT
                Text("3. Was this animal recently treated?", style: AppTypography.sectionHeading.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text("No"),
                      selected: !_recentlyTreated,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: !_recentlyTreated ? Colors.white : AppColors.textPrimary,
                        fontWeight: !_recentlyTreated ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _recentlyTreated = false);
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Yes"),
                      selected: _recentlyTreated,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _recentlyTreated ? Colors.white : AppColors.textPrimary,
                        fontWeight: _recentlyTreated ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _recentlyTreated = true);
                      },
                    ),
                  ],
                ),
                if (_recentlyTreated) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _treatmentNotesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Recent Treatment Notes",
                      hintText: "e.g. Antibiotics given 2 days ago, vaccinated last week...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // 4. NOTES
                Text("4. Anything else we should know?", style: AppTypography.sectionHeading.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Additional observations, isolation details, herd status...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                  ),
                ),
                const SizedBox(height: 18),

                // 5. GPS LOCATION
                Text("5. Location Capture", style: AppTypography.sectionHeading.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _isFetchingGps
                            ? const Text("Obtaining GPS coordinates...", style: TextStyle(fontSize: 13))
                            : _locationResult != null
                                ? Text(
                                    "Lat: ${_locationResult!.latitude.toStringAsFixed(4)}, Lng: ${_locationResult!.longitude.toStringAsFixed(4)}",
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    _gpsError ?? "GPS unavailable",
                                    style: const TextStyle(fontSize: 12, color: AppColors.cautionAmber),
                                  ),
                      ),
                      TextButton.icon(
                        onPressed: _fetchLocation,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 6. SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (isSubmitting || selectedAnimal?.isDeceased == true) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit Death Report",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
