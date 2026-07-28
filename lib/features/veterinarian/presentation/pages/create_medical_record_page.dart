import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        const SnackBar(
          content: Text('Medical Record saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      final error = ref.read(medicalRecordProvider).errorMessage ?? 'Failed to save record';
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
    final state = ref.watch(medicalRecordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Medical Record'),
        backgroundColor: const Color(0xFF1B4D3E),
        foregroundColor: Colors.white,
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
                color: const Color(0xFFE8F5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pets, color: Color(0xFF1B4D3E)),
                          const SizedBox(width: 8),
                          Text(
                            widget.appointment.animalName ?? 'Animal',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B4D3E),
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
                      Text('Farmer: ${widget.appointment.farmerName ?? 'Owner'}', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Clinical Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4D3E)),
              ),
              const SizedBox(height: 12),

              // Diagnosis
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis *',
                  hintText: 'e.g. Bovine Mastitis, Acute Fever',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Diagnosis is required' : null,
              ),
              const SizedBox(height: 14),

              // Symptoms
              TextFormField(
                controller: _symptomsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observed Symptoms',
                  hintText: 'e.g. Udder swelling, decreased appetite, high body temp',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sick_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // Treatment
              TextFormField(
                controller: _treatmentController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Treatment Administered *',
                  hintText: 'e.g. Intramammary antibiotic infusion, anti-inflammatory IV',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.healing_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Treatment details are required' : null,
              ),
              const SizedBox(height: 14),

              // Prescription
              TextFormField(
                controller: _prescriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Prescription',
                  hintText: 'e.g. Penicillin 500mg (2x daily for 5 days)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication_outlined),
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
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: '450.0',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _temperatureController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Temp (°C)',
                        hintText: '38.5',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.thermostat_outlined),
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
                  decoration: const InputDecoration(
                    labelText: 'Follow-up Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(
                    _selectedFollowUpDate != null
                        ? '${_selectedFollowUpDate!.day}/${_selectedFollowUpDate!.month}/${_selectedFollowUpDate!.year}'
                        : 'Select follow-up date (optional)',
                    style: TextStyle(
                      color: _selectedFollowUpDate != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Clinical Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Clinical Notes & Recommendations',
                  hintText: 'e.g. Keep animal in dry shed, isolate for 3 days',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
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
                    backgroundColor: const Color(0xFF1B4D3E),
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
                    state.isLoading ? 'Saving Record...' : 'Save Medical Record',
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
