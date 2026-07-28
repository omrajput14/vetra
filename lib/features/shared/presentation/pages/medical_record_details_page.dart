import 'package:flutter/material.dart';
import 'package:vetra/features/medical_record/data/models/medical_record_dto.dart';

class MedicalRecordDetailsPage extends StatelessWidget {
  final MedicalRecordModel record;

  const MedicalRecordDetailsPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electronic Medical Record'),
        backgroundColor: const Color(0xFF1B4D3E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: const Color(0xFF1B4D3E),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user, color: Colors.amber, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            record.diagnosis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Animal: ${record.animalName ?? 'N/A'} (${record.tagNumber ?? 'TAG-N/A'})',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          'Date: ${record.createdAt.split('T').first}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata Grid (Vet, Clinic, Farmer)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    _buildMetaRow(Icons.person_pin, 'Attending Vet', record.veterinarianName ?? 'Dr. Veterinarian'),
                    const Divider(height: 16),
                    _buildMetaRow(Icons.local_hospital, 'Clinic / Practice', record.clinicName ?? 'Vetra Clinical Practice'),
                    const Divider(height: 16),
                    _buildMetaRow(Icons.agriculture, 'Owner / Farmer', record.farmerName ?? 'Livestock Owner'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Clinical Details Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clinical Diagnosis & Symptoms',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4D3E)),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailBox('Diagnosis', record.diagnosis, Colors.red[50]!, Colors.red[800]!),
                    if (record.symptoms != null && record.symptoms!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildDetailBox('Observed Symptoms', record.symptoms!, Colors.orange[50]!, Colors.orange[900]!),
                    ],
                    const SizedBox(height: 16),

                    const Text(
                      'Treatment & Intervention',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4D3E)),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailBox('Administered Treatment', record.treatment, Colors.green[50]!, Colors.green[900]!),
                    if (record.prescription != null && record.prescription!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildDetailBox('Prescription', record.prescription!, Colors.blue[50]!, Colors.blue[900]!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vitals & Follow-Up Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vitals & Observations',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4D3E)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVitalChip(
                            Icons.monitor_weight_outlined,
                            'Weight',
                            record.weight != null ? '${record.weight} kg' : 'N/A',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildVitalChip(
                            Icons.thermostat_outlined,
                            'Temperature',
                            record.temperature != null ? '${record.temperature} °C' : 'N/A',
                          ),
                        ),
                      ],
                    ),
                    if (record.followUpDate != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event, color: Colors.amber),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Recommended Follow-Up Date', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                Text(record.followUpDate!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Clinical Notes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(record.notes!, style: TextStyle(color: Colors.grey[800], height: 1.3)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1B4D3E), size: 20),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildDetailBox(String label, String content, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(fontSize: 14, color: Colors.grey[900], height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildVitalChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B4D3E)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
