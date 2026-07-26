import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/alert_card.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';

class VetDashboardPage extends StatelessWidget {
  const VetDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Row(
          children: [
            Text('Vet Dashboard', style: AppTypography.screenTitle),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'VET ROLE',
                style: AppTypography.captionMetadata.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: AppTypography.sectionHeading),
                  Text('Welcome back, Dr. Silva', style: AppTypography.captionMetadata),
                ],
              ),
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceContainer,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Urgent AI Alerts', style: AppTypography.cardTitle),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/alert-details'),
            child: const AlertCard(
              title: 'Likely FMD Detected (94% AI Confidence)',
              description: 'Action required on Farm #842. Click to review scan.',
            ),
          ),
          const SizedBox(height: 24),
          Text("Today's Schedule", style: AppTypography.cardTitle),
          const SizedBox(height: 8),
          _buildScheduleItem('09:00 AM', 'Herd Vaccination', 'Oakhaven Farm'),
          const SizedBox(height: 8),
          _buildScheduleItem('11:00 AM', 'Lameness Check (2 Cows)', "Miller's Dairy"),
          const SizedBox(height: 8),
          _buildScheduleItem('02:00 PM', 'Follow-up: Calving', 'Teleconsult'),
        ],
      ),
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/vet-requests');
          if (index == 1) context.go('/consultation-history');
          if (index == 2) context.go('/outbreak-map');
          if (index == 3) context.go('/vet-profile');
        },
      ),
    );
  }

  Widget _buildScheduleItem(String time, String title, String location) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        children: [
          Text(time, style: AppTypography.buttonLabel.copyWith(color: AppColors.primary)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                Text(location, style: AppTypography.captionMetadata),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
