import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';

class ConsultationHistoryPage extends StatelessWidget {
  const ConsultationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Consultation Cases', style: AppTypography.screenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Recent Cases', style: AppTypography.sectionHeading),
          const SizedBox(height: 12),
          _buildCaseItem(
            context,
            tagId: 'TAG-8924',
            name: 'Bessie (Holstein)',
            diagnosis: 'Subclinical Mastitis (Left Rear)',
            treatment: 'Administered intramammary antibiotics.',
            status: 'Recovered',
          ),
          const SizedBox(height: 12),
          _buildCaseItem(
            context,
            tagId: 'TAG-1102',
            name: 'Flock Alpha - Ram',
            diagnosis: 'Routine Checkup & Booster',
            treatment: 'Clostridial 8-in-1 booster administered.',
            status: 'Healthy',
          ),
        ],
      ),
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/vet-dashboard');
          if (index == 3) context.go('/vet-outbreak-map');
          if (index == 4) context.go('/vet-profile');
        },
      ),
    );
  }

  Widget _buildCaseItem(BuildContext context, {required String tagId, required String name, required String diagnosis, required String treatment, required String status}) {
    return Container(
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
              Text(name, style: AppTypography.cardTitle),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text(tagId, style: AppTypography.captionMetadata),
          const SizedBox(height: 8),
          Text('Diagnosis: $diagnosis', style: AppTypography.bodyDefault),
          Text('Action: $treatment', style: AppTypography.captionMetadata),
        ],
      ),
    );
  }
}
