import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/localization/locale_provider.dart';

import '../../../disease/data/models/outbreak_dto.dart';
import '../../../disease/presentation/providers/outbreak_provider.dart';

class RiskZonePage extends ConsumerWidget {
  final OutbreakModel? initialOutbreak;

  const RiskZonePage({super.key, this.initialOutbreak});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final lang = activeLocale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text(
          lang == 'mr'
              ? 'अतिधोकादायक प्रादुर्भाव क्षेत्रे'
              : (lang == 'hi' ? 'उच्च जोखिम प्रकोप क्षेत्र' : 'High Risk Surveillance Zones'),
          style: AppTypography.screenTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: outbreakNotifier,
        builder: (context, _) {
          final outbreaks = initialOutbreak != null
              ? [initialOutbreak!]
              : outbreakNotifier.outbreaks.where((o) => o.riskScore == 'HIGH' || o.riskScore == 'CRITICAL').toList();

          if (outbreaks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_rounded, size: 56, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      lang == 'mr'
                          ? 'सध्या कोणतेही अतिधोकादायक क्षेत्र नाही'
                          : (lang == 'hi' ? 'कोई उच्च जोखिम क्षेत्र सक्रिय नहीं है' : 'No High Risk Zones Active'),
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang == 'mr'
                          ? 'सर्व प्रादुर्भाव क्षेत्रे सामान्य नियंत्रण मर्यादेत आहेत.'
                          : (lang == 'hi'
                              ? 'सभी क्षेत्र सामान्य नियंत्रण सीमा के भीतर हैं।'
                              : 'All livestock health sectors are within normal containment thresholds.'),
                      style: AppTypography.captionMetadata,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: outbreaks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final o = outbreaks[index];
              final isCritical = o.riskScore == 'CRITICAL';
              final color = isCritical ? AppColors.alertCritical : const Color(0xFFE65100);
              final bd = o.riskBreakdown;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                            o.diseaseName,
                            style: AppTypography.cardTitle.copyWith(fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color),
                          ),
                          child: Text(
                            '${o.compositeRiskScore} • ${o.riskScore}',
                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Radius: ${o.radiusKm.toStringAsFixed(1)} km Bio-containment Area • ${o.affectedReportsCount} Cases',
                      style: AppTypography.captionMetadata,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Center: ${o.centerLatitude.toStringAsFixed(4)}° N, ${o.centerLongitude.toStringAsFixed(4)}° E',
                      style: AppTypography.captionMetadata.copyWith(fontSize: 11),
                    ),
                    if (bd != null && bd.recommendedAction.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bd.recommendedAction,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${o.status}',
                          style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.shield_outlined, size: 16),
                          label: const Text('Safety Guidance'),
                          onPressed: () => context.push('/biosecurity-recommendations'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
