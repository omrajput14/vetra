import 'package:flutter/material.dart';
import '../../../animal/data/models/animal_health_record_dto.dart';
import '../widgets/health_record_list.dart';

// ponytail: the backend has no DEWORMING record type, so deworming is recognised by
// keyword in the record's text. Add a record type server-side if this misses entries.
const _dewormingWords = [
  'deworm', 'anthelmint', 'albendazole', 'fenbendazole', 'ivermectin',
  'levamisole', 'oxyclozanide', 'closantel', 'praziquantel',
];

bool isDewormingRecord(AnimalHealthRecordModel r) {
  final text = [r.title, r.treatment, r.description].whereType<String>().join(' ').toLowerCase();
  return _dewormingWords.any(text.contains);
}

class DewormingRecordPage extends StatelessWidget {
  final String animalId;
  const DewormingRecordPage({super.key, this.animalId = ''});

  @override
  Widget build(BuildContext context) {
    return HealthRecordList(
      title: 'Deworming History',
      animalId: animalId,
      icon: Icons.medication,
      where: isDewormingRecord,
      subtitle: (r) => [
        'Given ${formatRecordDate(r.recordedAt)}',
        if (r.nextDueDate != null) 'Next due ${formatRecordDate(r.nextDueDate)}',
      ].join(' • '),
      emptyMessage: 'No deworming recorded for this animal yet.',
    );
  }
}
