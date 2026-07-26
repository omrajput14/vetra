import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class VaccinationDetailsPage extends StatelessWidget {
  const VaccinationDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Vaccine Record Details', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FMD Quadrivalent Vaccine', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text('Batch ID: VAX-2023-9904', style: AppTypography.captionMetadata),
            Text('Administered by: Dr. S. Patel', style: AppTypography.bodyDefault),
            Text('Expiry Date: 12 Oct 2025', style: AppTypography.captionMetadata),
          ],
        ),
      ),
    );
  }
}
