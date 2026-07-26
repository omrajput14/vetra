import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Health Alerts', style: AppTypography.screenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: AppColors.surfaceCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.warning, color: AppColors.alertCritical),
            title: Text('FMD Quarantine Zone', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            subtitle: Text('3.2 km away • Action Required', style: AppTypography.captionMetadata),
            onTap: () => context.push('/alert-details'),
          ),
        ],
      ),
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/farmer-dashboard');
          if (index == 1) context.go('/my-animals');
          if (index == 3) context.go('/nearby-vets');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }
}
