import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../animal/data/models/animal_health_record_dto.dart';
import '../widgets/health_record_list.dart';

/// Shows one vaccination record; fields the record does not have are left out.
class VaccinationDetailsPage extends StatelessWidget {
  final AnimalHealthRecordModel? record;
  const VaccinationDetailsPage({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    final r = record;
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Vaccine Record Details', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: r == null
          ? Center(child: Text('Vaccination record not found.', style: AppTypography.captionMetadata))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(r.vaccineName ?? r.title, style: AppTypography.screenTitle),
                const SizedBox(height: 12),
                for (final (label, value) in [
                  ('Given on', formatRecordDate(r.recordedAt)),
                  ('Next due', r.nextDueDate == null ? null : formatRecordDate(r.nextDueDate)),
                  ('Batch number', r.batchNumber),
                  ('Administered by', r.veterinarianName),
                  ('Notes', r.description),
                ])
                  if (value != null && value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('$label: $value', style: AppTypography.bodyDefault),
                    ),
              ],
            ),
    );
  }
}
