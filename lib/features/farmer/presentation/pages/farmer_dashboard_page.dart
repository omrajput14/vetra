import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/alert_card.dart';

class FarmerDashboardPage extends StatelessWidget {
  const FarmerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        title: Text('Vetra Dashboard', style: AppTypography.screenTitle),
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AlertCard(
            title: 'FMD Outbreak Alert',
            description: 'Confirmed cases within 5 km. Keep herd quarantined.',
          ),
          const SizedBox(height: 16),
          Text('Overview', style: AppTypography.sectionHeading),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('12', style: AppTypography.screenTitle.copyWith(color: AppColors.primary)),
                    Text('Animals', style: AppTypography.captionMetadata),
                  ],
                ),
                Column(
                  children: [
                    Text('2', style: AppTypography.screenTitle.copyWith(color: AppColors.cautionAmber)),
                    Text('Vaccine Due', style: AppTypography.captionMetadata),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
