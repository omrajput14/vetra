import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';

class VetRequestsPage extends StatelessWidget {
  const VetRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Incoming Requests', style: AppTypography.screenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('4 pending consultations', style: AppTypography.captionMetadata),
          const SizedBox(height: 16),
          _buildRequestCard(
            context,
            species: 'Bovine - Holstein',
            location: "O'Connor Farm, 12km",
            alert: 'Potential Milk Fever. Symptoms: Downer cow.',
            isCritical: true,
          ),
          const SizedBox(height: 12),
          _buildRequestCard(
            context,
            species: 'Ovine - Merino',
            location: 'Valley Ridge, 4km',
            alert: 'Routine vaccination check. Mild limping reported.',
            isCritical: false,
          ),
        ],
      ),
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/consultation-history');
          if (index == 3) context.go('/vet-outbreak-map');
          if (index == 4) context.go('/vet-profile');
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, {required String species, required String location, required String alert, required bool isCritical}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCritical ? AppColors.alertCritical.withValues(alpha: 0.1) : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCritical ? AppColors.alertCritical : AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(species, style: AppTypography.cardTitle),
              if (isCritical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.alertCritical, borderRadius: BorderRadius.circular(12)),
                  child: Text('CRITICAL', style: AppTypography.captionMetadata.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(location, style: AppTypography.captionMetadata),
          const SizedBox(height: 8),
          Text(alert, style: AppTypography.bodyDefault),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCritical ? AppColors.alertCritical : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.push('/appointment-booking'),
            child: const Center(child: Text('Accept Request')),
          ),
        ],
      ),
    );
  }
}
