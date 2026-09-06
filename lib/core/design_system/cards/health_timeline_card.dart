import 'package:flutter/material.dart';
import '../../../features/animal/data/models/animal_health_record_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../app_colors.dart';
import '../app_typography.dart';

class HealthTimelineCard extends StatelessWidget {
  final AnimalHealthRecordModel record;

  const HealthTimelineCard({super.key, required this.record});

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'AI_SCREENING':
        return Icons.smart_toy_outlined;
      case 'VET_CONSULTATION':
        return Icons.medical_services_outlined;
      case 'DIAGNOSIS':
        return Icons.biotech_outlined;
      case 'TREATMENT':
        return Icons.medication_outlined;
      case 'VACCINATION':
        return Icons.vaccines_outlined;
      case 'OBSERVATION':
      default:
        return Icons.assignment_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'AI_SCREENING':
        return const Color(0xFF2563EB); // Blue
      case 'VET_CONSULTATION':
        return const Color(0xFF1B4D3E); // Deep Forest Green
      case 'DIAGNOSIS':
        return const Color(0xFFD97706); // Amber
      case 'TREATMENT':
        return const Color(0xFF0D9488); // Teal
      case 'VACCINATION':
        return const Color(0xFF7C3AED); // Purple
      case 'OBSERVATION':
      default:
        return const Color(0xFF4B5563); // Slate Grey
    }
  }

  String _getTypeLabel(String type, AppLocalizations? l10n) {
    switch (type.toUpperCase()) {
      case 'AI_SCREENING':
        return l10n?.aiScreening ?? 'AI Health Screening';
      case 'VET_CONSULTATION':
        return l10n?.consultation ?? 'Vet Consultation';
      case 'DIAGNOSIS':
        return l10n?.diagnosis ?? 'Diagnosis';
      case 'TREATMENT':
        return l10n?.treatment ?? 'Treatment';
      case 'VACCINATION':
        return l10n?.vaccination ?? 'Vaccination';
      case 'OBSERVATION':
      default:
        return l10n?.observation ?? 'Observation';
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr.contains('T') ? dateStr.split('T').first : dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeColor = _getTypeColor(record.recordType);
    final formattedDate = _formatDate(record.recordedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent strip with event icon
              Container(
                width: 52,
                color: typeColor.withValues(alpha: 0.12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTypeIcon(record.recordType),
                      color: typeColor,
                      size: 26,
                    ),
                  ],
                ),
              ),
              // Content body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Type Chip + Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getTypeLabel(record.recordType, l10n),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: typeColor,
                              ),
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: AppTypography.captionMetadata.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        record.title,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      // Description
                      if (record.description != null && record.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          record.description!,
                          style: AppTypography.bodyDefault.copyWith(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],

                      // Symptoms
                      if (record.symptoms != null && record.symptoms!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n?.symptoms ?? "Symptoms"}: ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                record.symptoms!,
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Diagnosis
                      if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n?.diagnosis ?? "Diagnosis"}: ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                record.diagnosis!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Treatment / Rx
                      if (record.treatment != null && record.treatment!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n?.treatment ?? "Treatment"}: ',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D9488),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                record.treatment!,
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Attending Vet & Source Metadata
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (record.veterinarianName != null && record.veterinarianName!.isNotEmpty) ...[
                            const Icon(Icons.verified_user, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              record.veterinarianName!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                          ] else
                            const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              record.source,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
