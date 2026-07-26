import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class ScanAccuracyComparisonPage extends StatelessWidget {
  const ScanAccuracyComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Accuracy Benchmark', style: AppTypography.screenTitle),
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
                Text('Model Performance Benchmark', style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                Text('FMD Detection Accuracy: 94.2%', style: AppTypography.bodyDefault.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                Text('Mastitis Sensitivity: 91.8%', style: AppTypography.bodyDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
