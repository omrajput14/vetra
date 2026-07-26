import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Appointment Details', style: AppTypography.screenTitle),
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
            const Icon(Icons.check_circle, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Consultation Confirmed', style: AppTypography.screenTitle),
            const SizedBox(height: 8),
            Text('Doctor: Dr. S. Patel', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            Text('Time: Today 04:00 PM', style: AppTypography.captionMetadata),
          ],
        ),
      ),
    );
  }
}
