import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class DiseaseInformationPage extends StatelessWidget {
  const DiseaseInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                Text('Foot and Mouth Disease (FMD)', style: AppTypography.screenTitle.copyWith(fontSize: 20)),
                const SizedBox(height: 8),
                Text('High-severity viral infection affecting cloven-hoofed animals.', style: AppTypography.bodyDefault),
                const SizedBox(height: 12),
                Text('Key Symptoms:', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                Text('• Blisters on feet and mouth', style: AppTypography.captionMetadata),
                Text('• Excessive salivation & fever', style: AppTypography.captionMetadata),
                Text('• Lameness and loss of appetite', style: AppTypography.captionMetadata),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
