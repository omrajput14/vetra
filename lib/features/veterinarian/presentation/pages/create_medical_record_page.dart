import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../appointment/data/models/appointment_dto.dart';
import '../../../medical_record/presentation/providers/medical_record_provider.dart';

class CreateMedicalRecordPage extends ConsumerStatefulWidget {
  final AppointmentModel appointment;

  const CreateMedicalRecordPage({super.key, required this.appointment});

  @override
  ConsumerState<CreateMedicalRecordPage> createState() => _CreateMedicalRecordPageState();
}

class _CreateMedicalRecordPageState extends ConsumerState<CreateMedicalRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedFollowUpDate;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _symptomsController.dispose();
    _treatmentController.dispose();
    _prescriptionController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFollowUpDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedFollowUpDate = picked;
      });
    }
  }

  Future<void> _submitRecord() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final body = <String, dynamic>{
      'appointmentId': widget.appointment.id,
      'diagnosis': _diagnosisController.text.trim(),
      'treatment': _treatmentController.text.trim(),
      if (_symptomsController.text.trim().isNotEmpty)
        'symptoms': _symptomsController.text.trim(),
      if (_prescriptionController.text.trim().isNotEmpty)
        'prescription': _prescriptionController.text.trim(),
      if (_weightController.text.trim().isNotEmpty)
        'weight': double.tryParse(_weightController.text.trim()),
      if (_temperatureController.text.trim().isNotEmpty)
        'temperature': double.tryParse(_temperatureController.text.trim()),
      if (_selectedFollowUpDate != null)
        'followUpDate': _selectedFollowUpDate!.toIso8601String().split('T').first,
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
    };

    final success = await ref.read(medicalRecordProvider.notifier).createRecord(body);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.recordSavedSuccess ?? 'Medical Record saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final error = ref.read(medicalRecordProvider).errorMessage ?? (l10n?.error ?? 'Failed to save record');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(medicalRecordProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        title: Text(l10n?.createMedicalRecord ?? 'Create Medical Record', style: AppTypography.screenTitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              Card(
                color: AppColors.surfaceCard,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.borderHairline)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pets, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            widget.appointment.animalName ?? (l10n?.animalName ?? 'Animal'),
                            style: AppTypography.cardTitle,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.appointment.tagNumber ?? 'TAG-N/A',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${l10n?.continueAsFarmer ?? "Farmer"}: ${widget.appointment.farmerName ?? "Owner"}',
                        style: AppTypography.captionMetadata,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n?.evmrTitle ?? 'Clinical Details',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: 12),

              // Diagnosis
              TextFormField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  labelText: '${l10n?.clinicalDiagnosis ?? "Diagnosis"} *',
                  hintText: 'e.g. Bovine Mastitis, Acute Fever',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? (l10n?.enterDiagnosisValidation ?? 'Diagnosis is required') : null,
              ),
              const SizedBox(height: 14),

              // Symptoms
              TextFormField(
                controller: _symptomsController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n?.symptoms ?? 'Observed Symptoms',
                  hintText: 'e.g. Udder swelling, decreased appetite',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.sick_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Treatment
              TextFormField(
                controller: _treatmentController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: '${l10n?.treatment ?? "Treatment Administered"} *',
                  hintText: 'e.g. Intramammary antibiotic infusion',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.healing_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? (l10n?.enterTreatmentValidation ?? 'Treatment details are required') : null,
              ),
              const SizedBox(height: 14),

              // Prescription
              TextFormField(
                controller: _prescriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n?.prescriptions ?? 'Prescription (Rx)',
                  hintText: 'e.g. Penicillin 500mg (2x daily for 5 days)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.medication_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Vitals (Weight & Temperature)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n?.weightInKg ?? 'Weight (kg)',
                        hintText: '450.0',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _temperatureController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n?.temperatureInCelsius ?? 'Temp (°C)',
                        hintText: '38.5',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.thermostat_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Follow-up Date
              InkWell(
                onTap: _pickFollowUpDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n?.followUpDate ?? 'Follow-up Date',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.event_outlined),
                  ),
                  child: Text(
                    _selectedFollowUpDate != null
                        ? '${_selectedFollowUpDate!.day}/${_selectedFollowUpDate!.month}/${_selectedFollowUpDate!.year}'
                        : (l10n?.followUpDate ?? 'Select follow-up date'),
                    style: TextStyle(
                      color: _selectedFollowUpDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Clinical Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n?.clinicalNotes ?? 'Clinical Notes & Recommendations',
                  hintText: 'e.g. Keep animal in dry shed, isolate for 3 days',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: state.isLoading ? null : _submitRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    state.isLoading ? (l10n?.loading ?? 'Saving Record...') : (l10n?.save ?? 'Save Medical Record'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
