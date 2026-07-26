import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';

class AppointmentBookingPage extends StatelessWidget {
  const AppointmentBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Request Consultation', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Select Doctor: Dr. S. Patel', style: AppTypography.cardTitle),
          const SizedBox(height: 16),
          Text('Preferred Time: Today 04:00 PM', style: AppTypography.bodyDefault),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Confirm Consultation Request',
            onPressed: () => context.push('/appointment-details'),
          ),
        ],
      ),
    );
  }
}
