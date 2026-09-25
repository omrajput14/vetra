import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../appointment/data/models/appointment_dto.dart';
import '../../../disease/presentation/providers/disease_registry_provider.dart';
import '../../../disease/presentation/widgets/zoonotic_warning_banner.dart';
import '../providers/ai_scan_provider.dart';

class ScanResultsPage extends StatelessWidget {
  final Map<String, dynamic>? extraData;

  const ScanResultsPage({super.key, this.extraData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = aiScanNotifier.lastScanResult;
    final imagePath =
        extraData?['imagePath']?.toString() ?? aiScanNotifier.selectedImagePath;

    if (result == null || result.isAnalysisFailure) {
      return _buildScanFailed(context, result?.status);
    }

    final String status = result.status;
    final String diagnosis = result.diagnosis!;
    final double confidence = result.confidenceScore ?? 0.0;
    final String severity = result.severity;
    final List<String> observations = result.observations;
    final String recommendedNextStep = result.recommendedNextStep;
    final String disclaimer = result.disclaimer;
    final String provider = result.aiProvider ?? 'VETRA_AI';
    final String model = result.aiModel ?? 'NOOP-V1';

    final bool isEmergency =
        severity.toUpperCase() == 'EMERGENCY' || severity.toUpperCase() == 'CRITICAL';
    final bool isZoonotic = diseaseRegistryNotifier.isZoonotic(diagnosis);
    final targetAnimalId = extraData?['animalId']?.toString() ??
        aiScanNotifier.selectedAnimalId ??
        '';

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Preliminary AI Assessment', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/farmer-dashboard'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (result.status == 'VERIFIED' || result.status == 'REJECTED')
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (result.status == 'VERIFIED' ? AppColors.primary : AppColors.alertCritical)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(result.status == 'VERIFIED' ? Icons.verified : Icons.block,
                      color: result.status == 'VERIFIED' ? AppColors.primary : AppColors.alertCritical),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.status == 'VERIFIED'
                          ? 'Confirmed by ${result.vetDisplayName ?? 'a veterinarian'}'
                          : 'Not confirmed by ${result.vetDisplayName ?? 'a veterinarian'}'
                              '${result.rejectionReason != null ? ': ${result.rejectionReason}' : ''}',
                      style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          // Captured Image Card
          if (imagePath != null && File(imagePath).existsSync())
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderHairline),
              ),
              child: const Center(
                child: Icon(Icons.psychology, size: 56, color: AppColors.brandPrimary),
              ),
            ),

          const SizedBox(height: 16),

          // Diagnostic Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top status and provider metadata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(status),
                    Text(
                      '$provider ($model)',
                      style: AppTypography.captionMetadata.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Suspected Condition Title & Severity
                Text(
                  'Suspected Visual Condition',
                  style: AppTypography.captionMetadata.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        diagnosis,
                        style: AppTypography.screenTitle.copyWith(
                          fontSize: 19,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSeverityBadge(severity),
                  ],
                ),

                const SizedBox(height: 18),

                // AI Confidence Meter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.insights, color: AppColors.brandPrimary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'AI Confidence',
                          style: AppTypography.bodyDefault.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(confidence * 100).toStringAsFixed(1)}%',
                      style: AppTypography.bodyDefault.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidence.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade800,
                    color: AppColors.brandPrimary,
                    minHeight: 6,
                  ),
                ),

                // Observed Indicators List
                if (observations.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Observed Indicators',
                    style: AppTypography.captionMetadata.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...observations.map((obs) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: AppColors.brandPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                obs,
                                style: AppTypography.bodyDefault.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                // Recommended Next Steps
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.brandPrimary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.brandPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended Next Step',
                              style: AppTypography.captionMetadata.copyWith(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recommendedNextStep,
                              style: AppTypography.bodyDefault.copyWith(
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Feature 2: Zoonotic Disease Alert Styling (if transmissible to humans)
          if (isZoonotic) ...[
            const SizedBox(height: 12),
            ZoonoticWarningBanner(diseaseName: diagnosis),
          ],

          // Feature 1: Emergency AI Triage Warning & BOOK VET NOW Banner
          if (isEmergency) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.alertCritical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.alertCritical,
                  width: 1.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.alertCritical,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n?.immediateVetAttentionRecommended ??
                              'Immediate veterinary attention recommended.',
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.alertCritical,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n?.emergencyCareWarning ??
                        'Critical condition detected. Immediate veterinary intervention required without delay.',
                    style: AppTypography.bodyDefault.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on, color: Colors.white, size: 20),
                      label: Text(
                        l10n?.bookVetNow ?? 'BOOK VET NOW',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertCritical,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () {
                        context.push('/appointment-booking', extra: {
                          'animalId': targetAnimalId,
                          'isEmergency': true,
                          'visitType': VisitType.emergency,
                          'reason': 'EMERGENCY AI TRIAGE: $diagnosis',
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Clinical Safety Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    disclaimer,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade200,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary & Secondary Actions
          PrimaryButton(
            label: 'Discuss with AI Veterinary Advisor',
            onPressed: () {
              context.push('/ai-advisor', extra: targetAnimalId);
            },
          ),

          const SizedBox(height: 12),

          if (!isEmergency) ...[
            OutlinedButton(
              onPressed: () => context.push('/appointment-booking', extra: {
                'animalId': targetAnimalId,
                'reason': diagnosis,
              }),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text('Book Vet Consultation'),
            ),
            const SizedBox(height: 12),
          ],

          OutlinedButton(
            onPressed: () => context.go('/farmer-dashboard'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: AppColors.borderHairline),
            ),
            child: const Text('Return to Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor = Colors.orange;
    if (status == 'COMPLETED' || status == 'VERIFIED') {
      badgeColor = Colors.green;
    } else if (status == 'FAILED') {
      badgeColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color = Colors.grey;
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
      case 'EMERGENCY':
      case 'SEVERE':
        color = Colors.redAccent;
        break;
      case 'MODERATE':
        color = Colors.orangeAccent;
        break;
      case 'MILD':
        color = Colors.lightBlueAccent;
        break;
      case 'NONE':
      case 'HEALTHY':
        color = Colors.greenAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildScanFailed(BuildContext context, String? status) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Preliminary AI Assessment', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/farmer-dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text('Scan failed, please retry',
                style: AppTypography.screenTitle.copyWith(color: Colors.redAccent),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'The AI could not analyse this photo, so no diagnosis was produced'
              '${status != null ? ' (scan status: $status)' : ''}.',
              style: AppTypography.bodyDefault.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Retake Photo',
              onPressed: () => context.go('/disease-scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
