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
            const Icon(Icons.medical_services, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Text('VET DASHBOARD', style: AppTypography.screenTitle.copyWith(color: AppColors.primary)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
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
                  Text('Clinical Triage', style: AppTypography.sectionHeading),
                  Text('Welcome, Dr. Sarah Jenkins (Reg #VET-9941-XX)', style: AppTypography.captionMetadata),
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
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('5', style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 32)),
                      Text('Today Appointments', style: AppTypography.captionMetadata),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('3', style: AppTypography.screenTitle.copyWith(color: AppColors.cautionAmber, fontSize: 32)),
                      Text('Pending Requests', style: AppTypography.captionMetadata),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Urgent AI Disease Review', style: AppTypography.cardTitle),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/alert-details'),
            child: const AlertCard(
              title: 'Likely FMD Case Submitted (94% AI Confidence)',
              description: 'Farm #842 - Oak Valley Herd. Review scan for official confirmation.',
            ),
          ),
          const SizedBox(height: 24),
          Text('Quick Clinical Actions', style: AppTypography.sectionHeading),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan Animal QR',
                  onTap: () => context.push('/qr-scanner-vet'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.add_task,
                  label: 'Diagnosis Entry',
                  onTap: () => context.push('/diagnosis-entry'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Today Schedule', style: AppTypography.cardTitle),
          const SizedBox(height: 8),
          _buildScheduleItem('09:00 AM', 'Herd Vaccination', 'Oakhaven Farm'),
          const SizedBox(height: 8),
          _buildScheduleItem('11:00 AM', 'Lameness Check (2 Cows)', 'Miller Dairy'),
          const SizedBox(height: 8),
          _buildScheduleItem('02:00 PM', 'Follow-up: Calving', 'Teleconsult'),
        ],
      ),
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/vet-dashboard');
          if (index == 1) context.go('/vet-requests');
          if (index == 2) context.go('/consultation-history');
          if (index == 3) context.go('/vet-outbreak-map');
          if (index == 4) context.go('/vet-profile');
        },
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderHairline),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.buttonLabel.copyWith(fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
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
