import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../providers/disease_registry_provider.dart';
import '../widgets/zoonotic_warning_banner.dart';

class DiseaseInformationPage extends StatelessWidget {
  final String? diseaseName;

  const DiseaseInformationPage({super.key, this.diseaseName});

  @override
  Widget build(BuildContext context) {
    final targetDisease = diseaseName ?? 'Foot and Mouth Disease';
    final metadata = diseaseRegistryNotifier.getMetadata(targetDisease);
    final isZoonotic = diseaseRegistryNotifier.isZoonotic(targetDisease);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Disease Knowledge Base', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // If disease is marked zoonotic in registry, render prominent distinct warning
          if (isZoonotic)
            ZoonoticWarningBanner(diseaseName: targetDisease),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(targetDisease, style: AppTypography.screenTitle.copyWith(fontSize: 20)),
                    ),
                    if (metadata != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (metadata.severity == 'CRITICAL' ? AppColors.alertCritical : AppColors.primary)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          metadata.severity,
                          style: TextStyle(
                            color: metadata.severity == 'CRITICAL' ? AppColors.alertCritical : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Livestock pathogen surveillance record under PASHU SATHI epidemiological registry.',
                  style: AppTypography.bodyDefault,
                ),
                const SizedBox(height: 12),
                Text('Epidemiological Metrics:', style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text('• Baseline Mortality: ${metadata?.mortality ?? "MEDIUM"}', style: AppTypography.captionMetadata),
                Text('• Surveillance Radius: ${metadata?.defaultRadiusKm ?? 25.0} km', style: AppTypography.captionMetadata),
                Text('• Outbreak Evaluation Window: ${metadata?.evaluationWindowHours ?? 48} hours', style: AppTypography.captionMetadata),
                Text('• Legally Reportable: ${metadata?.reportable == true ? "YES" : "NO"}', style: AppTypography.captionMetadata),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
