import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AnimalTimelinePage extends StatelessWidget {
  const AnimalTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Health Timeline', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTimelineTile('12 Oct 2023', 'FMD Vaccination Booster', 'Dr. S. Patel'),
          _buildTimelineTile('05 Jun 2023', 'Routine Deworming', 'Self Administered'),
          _buildTimelineTile('10 Jan 2023', 'Birth Record Registered', 'Tag NL-93842'),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(String date, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: AppTypography.captionMetadata),
              Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
              Text(subtitle, style: AppTypography.captionMetadata.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
