import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class BiosecurityRecommendationsPage extends StatelessWidget {
  const BiosecurityRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Biosecurity Checklist', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                Text('Quarantine Protocol for Outbreak Zone', style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                Text('1. Restrict all non-essential personnel from entering the barn.', style: AppTypography.bodyDefault),
                const SizedBox(height: 4),
                Text('2. Disinfect footwear in footbaths containing 2% Virkon S.', style: AppTypography.bodyDefault),
                const SizedBox(height: 4),
                Text('3. Isolate affected animals immediately to Pen C.', style: AppTypography.bodyDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
