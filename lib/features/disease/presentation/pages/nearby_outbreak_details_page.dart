import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../data/models/outbreak_dto.dart';
import '../providers/outbreak_provider.dart';

class NearbyOutbreakDetailsPage extends ConsumerWidget {
  final OutbreakModel? outbreak;

  const NearbyOutbreakDetailsPage({super.key, this.outbreak});

  Color _getRiskColor(String riskScore) {
    switch (riskScore.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.alertCritical;
      case 'HIGH':
        return const Color(0xFFE65100);
      case 'MEDIUM':
        return AppColors.cautionAmber;
      case 'LOW':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final lang = activeLocale.languageCode;
    final targetOutbreak = outbreak ??
        outbreakNotifier.selectedCluster ??
        (outbreakNotifier.outbreaks.isNotEmpty ? outbreakNotifier.outbreaks.first : null);

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final bd = targetOutbreak?.riskBreakdown;
    final riskColor = _getRiskColor(targetOutbreak?.riskScore ?? 'MEDIUM');

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text(
          lang == 'mr'
              ? 'प्रादुर्भाव क्षेत्र तपशील'
              : (lang == 'hi' ? 'प्रकोप क्षेत्र विवरण' : 'Outbreak Zone Details'),
          style: AppTypography.screenTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: targetOutbreak == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: AppColors.textMetadata),
                  const SizedBox(height: 12),
                  Text('No Outbreak Selected', style: AppTypography.cardTitle),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: riskColor),
                    boxShadow: [
                      BoxShadow(
                        color: riskColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              targetOutbreak.diseaseName,
                              style: AppTypography.cardTitle.copyWith(fontSize: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: riskColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: riskColor, width: 1.5),
                            ),
                            child: Text(
                              '${targetOutbreak.compositeRiskScore} • ${targetOutbreak.riskScore}',
                              style: TextStyle(
                                color: riskColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${targetOutbreak.status} • Containment Area',
                        style: AppTypography.captionMetadata,
                      ),
                      const Divider(height: 24),

                      // Multi-Signal Breakdown Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderHairline.withValues(alpha: 0.6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MULTI-SIGNAL RISK INTELLIGENCE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildSignalProgressBar(
                              label: 'Spatial Density (40%)',
                              points: (bd?.clusterScore ?? 50.0) * 0.40,
                              maxPoints: 40.0,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 6),
                            _buildSignalProgressBar(
                              label: 'Weather Factors (20%)',
                              points: (bd?.weatherScore ?? 40.0) * 0.20,
                              maxPoints: 20.0,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 6),
                            _buildSignalProgressBar(
                              label: 'Historical Pattern (20%)',
                              points: (bd?.historyScore ?? 30.0) * 0.20,
                              maxPoints: 20.0,
                              color: Colors.purpleAccent,
                            ),
                            const SizedBox(height: 6),
                            _buildSignalProgressBar(
                              label: 'Herd Immunity Gap (20%)',
                              points: (bd?.vaccinationGapScore ?? 55.0) * 0.20,
                              maxPoints: 20.0,
                              color: Colors.teal,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (bd != null && bd.recommendedAction.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            bd.recommendedAction,
                            style: const TextStyle(fontSize: 12, height: 1.3),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      _buildInfoRow('Quarantine Perimeter', '${targetOutbreak.radiusKm.toStringAsFixed(1)} km'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Registered Cases', '${targetOutbreak.affectedReportsCount} Reports'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Center GPS', '${targetOutbreak.centerLatitude.toStringAsFixed(4)}° N, ${targetOutbreak.centerLongitude.toStringAsFixed(4)}° E'),
                      const SizedBox(height: 8),
                      _buildInfoRow('Evaluation Window', '${targetOutbreak.evaluationWindowHours} Hours'),
                      if (targetOutbreak.lastCaseReportedAt != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('Last Case Reported', dateFormat.format(targetOutbreak.lastCaseReportedAt!.toLocal())),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: lang == 'mr' ? 'जैविक सुरक्षा मार्गदर्शक' : (lang == 'hi' ? 'जैव-सुरक्षा निर्देश' : 'Biosecurity Protocols'),
                  onPressed: () => context.push('/biosecurity-recommendations'),
                ),
              ],
            ),
    );
  }

  Widget _buildSignalProgressBar({
    required String label,
    required double points,
    required double maxPoints,
    required Color color,
  }) {
    final pct = (points / maxPoints).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            Text(
              '${points.toStringAsFixed(1)} / ${maxPoints.toStringAsFixed(0)} pts',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.captionMetadata.copyWith(fontWeight: FontWeight.w600)),
        Text(value, style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
