import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../../core/services/location_service.dart';
import '../../../disease/data/models/outbreak_dto.dart';
import '../../../disease/presentation/providers/outbreak_provider.dart';

/// Farmer-facing health alerts tab.
///
/// Shows ACTIVE outbreaks with HIGH or CRITICAL risk scores, fetched live
/// from the disease surveillance backend via [OutbreakNotifier].
/// Replaced the previous hardcoded single "FMD Quarantine Zone" entry.
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch location first so we can show distance per-alert, then load outbreaks.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await outbreakNotifier.fetchUserLocation();
      await outbreakNotifier.loadOutbreaks();
    });
  }

  Future<void> _refresh() async {
    await outbreakNotifier.fetchUserLocation();
    await outbreakNotifier.loadOutbreaks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Health Alerts', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: outbreakNotifier,
        builder: (context, _) {
          if (outbreakNotifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (outbreakNotifier.errorMessage != null) {
            return _buildErrorState(outbreakNotifier.errorMessage!);
          }

          // Only surface HIGH and CRITICAL risk outbreaks as "alerts".
          // ACTIVE status filter prevents resolved outbreaks from showing.
          final alerts = outbreakNotifier.outbreaks
              .where((o) =>
                  (o.riskScore == 'HIGH' || o.riskScore == 'CRITICAL') &&
                  o.status == 'ACTIVE')
              .toList()
            ..sort((a, b) =>
                b.compositeRiskScore.compareTo(a.compositeRiskScore));

          if (alerts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) => _AlertCard(
                outbreak: alerts[idx],
                userLocation: outbreakNotifier.userLocation,
                onTap: () =>
                    context.push('/alert-details', extra: alerts[idx]),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/farmer-dashboard');
          if (index == 1) context.go('/my-animals');
          if (index == 3) context.go('/nearby-vets');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined,
                size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('No Active Alerts', style: AppTypography.cardTitle),
            const SizedBox(height: 8),
            Text(
              'There are currently no high-risk or critical disease outbreaks in the surveillance system.',
              textAlign: TextAlign.center,
              style: AppTypography.captionMetadata,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Check again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            Text('Could not load alerts', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Text(error,
                textAlign: TextAlign.center,
                style: AppTypography.captionMetadata),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alert card widget ──────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final OutbreakModel outbreak;
  final UserLocationResult? userLocation;
  final VoidCallback onTap;

  const _AlertCard({
    required this.outbreak,
    required this.userLocation,
    required this.onTap,
  });

  /// Haversine great-circle distance between two lat/lon points (km).
  double _distanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = outbreak.riskScore == 'CRITICAL';
    final alertColor =
        isCritical ? AppColors.alertCritical : AppColors.cautionAmber;

    String? distanceText;
    if (userLocation != null) {
      final dist = _distanceKm(
        userLocation!.latitude,
        userLocation!.longitude,
        outbreak.centerLatitude,
        outbreak.centerLongitude,
      );
      distanceText = '${dist.toStringAsFixed(1)} km away';
    }

    final count = outbreak.affectedReportsCount;
    final casesText = '$count case${count == 1 ? '' : 's'} reported';

    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: alertColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCritical
                      ? Icons.warning_rounded
                      : Icons.warning_amber_rounded,
                  color: alertColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            outbreak.diseaseName,
                            style: AppTypography.cardTitle
                                .copyWith(fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: alertColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            outbreak.riskScore,
                            style: AppTypography.captionMetadata.copyWith(
                              color: alertColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (distanceText != null) distanceText,
                        casesText,
                      ].join(' · '),
                      style: AppTypography.captionMetadata,
                    ),
                    if (outbreak.riskBreakdown != null &&
                        outbreak.riskBreakdown!.recommendedAction
                            .isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        outbreak.riskBreakdown!.recommendedAction,
                        style: AppTypography.captionMetadata
                            .copyWith(color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textMetadata),
            ],
          ),
        ),
      ),
    );
  }
}
