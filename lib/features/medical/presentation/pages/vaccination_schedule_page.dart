import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/health_record_list.dart';

/// VACCINATION health records of one animal, with each next due date.
class VaccinationSchedulePage extends StatelessWidget {
  final String animalId;
  const VaccinationSchedulePage({super.key, this.animalId = ''});

  @override
  Widget build(BuildContext context) {
    return HealthRecordList(
      title: 'Vaccination Schedule',
      animalId: animalId,
      icon: Icons.vaccines,
      where: (r) => r.recordType == 'VACCINATION',
      subtitle: (r) => [
        'Given ${formatRecordDate(r.recordedAt)}',
        r.nextDueDate == null ? 'No next dose recorded' : 'Next due ${formatRecordDate(r.nextDueDate)}',
      ].join(' • '),
      emptyMessage: 'No vaccinations recorded for this animal yet.',
      onTap: (context, r) => context.push('/vaccination-details', extra: r),
    );
  }
}
