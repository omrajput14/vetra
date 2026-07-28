import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../medical_record/data/models/medical_record_dto.dart';
import '../../../medical_record/presentation/providers/medical_record_provider.dart';
import '../../../shared/presentation/pages/medical_record_details_page.dart';

class AnimalMedicalHistoryWidget extends ConsumerStatefulWidget {
  final String animalId;

  const AnimalMedicalHistoryWidget({super.key, required this.animalId});

  @override
  ConsumerState<AnimalMedicalHistoryWidget> createState() => _AnimalMedicalHistoryWidgetState();
}

class _AnimalMedicalHistoryWidgetState extends ConsumerState<AnimalMedicalHistoryWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(medicalRecordProvider.notifier).fetchAnimalHistory(widget.animalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalRecordProvider);
    final history = state.animalHistories[widget.animalId] ?? [];

    if (state.isLoading && history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            const Icon(Icons.history_outlined, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'No Medical Records Found',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              'Clinical records created by attending veterinarians after completed consultations will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: history.map((record) => _buildHistoryCard(context, record)).toList(),
    );
  }

  Widget _buildHistoryCard(BuildContext context, MedicalRecordModel record) {
    final recordDate = record.createdAt.contains('T')
        ? record.createdAt.split('T').first
        : record.createdAt;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicalRecordDetailsPage(record: record),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4D3E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medical_services, color: Color(0xFF1B4D3E), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.diagnosis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Vet: ${record.veterinarianName ?? 'Dr. Veterinarian'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recordDate,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        children: [
                          const TextSpan(text: 'Treatment: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: record.treatment),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (record.prescription != null && record.prescription!.isNotEmpty) ...[
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Rx: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      TextSpan(text: record.prescription),
                    ],
                  ),
                ),
              ],

              if (record.followUpDate != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.event, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Follow-up: ${record.followUpDate}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View Complete EVMR', style: TextStyle(fontSize: 12, color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF1B4D3E)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
