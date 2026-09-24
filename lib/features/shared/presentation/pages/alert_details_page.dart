import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../disease/data/models/outbreak_dto.dart';

/// Detailed view for a single outbreak-based health alert.
///
/// [outbreak] is passed as GoRouter `extra` from [AlertsPage].
/// When null (stale deep-link / navigation error), a graceful error state
/// is shown instead of the previous hardcoded FMD/Oakhaven content.
class AlertDetailsPage extends StatelessWidget {
  final OutbreakModel? outbreak;

  const AlertDetailsPage({super.key, this.outbreak});

  @override
  Widget build(BuildContext context) {
    if (outbreak == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Alert Details', style: AppTypography.screenTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_outlined,
                    size: 48, color: AppColors.textMetadata),
                const SizedBox(height: 12),
                Text('Alert details unavailable',
                    style: AppTypography.cardTitle),
                const SizedBox(height: 6),
                Text(
                  'The alert information could not be loaded.',
                  textAlign: TextAlign.center,
                  style: AppTypography.captionMetadata,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final o = outbreak!;
    final isCritical = o.riskScore == 'CRITICAL';
    final alertColor =
        isCritical ? AppColors.alertCritical : AppColors.cautionAmber;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Alert Details', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header card ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: alertColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCritical
                          ? Icons.warning_rounded
                          : Icons.warning_amber_rounded,
                      color: alertColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        o.diseaseName,
                        style: AppTypography.cardTitle
                            .copyWith(color: alertColor, fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: alertColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        o.riskScore,
                        style: AppTypography.captionMetadata.copyWith(
                          color: alertColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Status: ${o.status}',
                    style: AppTypography.captionMetadata),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Stats row ────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Cases Reported',
                  value: '${o.affectedReportsCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Radius',
                  value: '${o.radiusKm.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),

          // ── Recommended action ───────────────────────────────────────────
          if (o.riskBreakdown != null &&
              o.riskBreakdown!.recommendedAction.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              icon: Icons.check_circle_outline,
              title: 'Recommended Action',
              body: o.riskBreakdown!.recommendedAction,
              color: AppColors.primary,
            ),
          ],

          // ── Risk explanation ─────────────────────────────────────────────
          if (o.riskBreakdown != null &&
              o.riskBreakdown!.riskExplanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoSection(
              icon: Icons.info_outline,
              title: 'Risk Explanation',
              body: o.riskBreakdown!.riskExplanation,
              color: AppColors.textMetadata,
            ),
          ],

          // ── Last case reported ───────────────────────────────────────────
          if (o.lastCaseReportedAt != null) ...[
            const SizedBox(height: 12),
            _InfoSection(
              icon: Icons.schedule,
              title: 'Last Case Reported',
              body: o.lastCaseReportedAt!.toLocal().toString().split('.').first,
              color: AppColors.textMetadata,
            ),
          ],

          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => context.push('/risk-zone', extra: o),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Risk zone & safety guidance'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/biosecurity-recommendations'),
            icon: const Icon(Icons.health_and_safety_outlined),
            label: const Text('Biosecurity checklist'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTypography.cardTitle.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.captionMetadata),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.captionMetadata.copyWith(
                      color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(body, style: AppTypography.bodyDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
