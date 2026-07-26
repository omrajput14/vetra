import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';

class OutbreakMapPage extends StatelessWidget {
  const OutbreakMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Outbreak Map Surveillance', style: AppTypography.screenTitle),
      ),
      body: Stack(
        children: [
          Container(
            color: AppColors.surfaceContainer,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 80, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('Interactive Heatmap Layer', style: AppTypography.cardTitle),
                  Text('Showing active quarantine zones within 50 km', style: AppTypography.captionMetadata),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.alertCritical),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Zone Red Alert: Active FMD outbreak 3.2km away', style: AppTypography.captionMetadata.copyWith(color: AppColors.alertCritical, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => context.push('/risk-zone'),
                    child: const Text('View Risk Zone'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go('/farmer-dashboard');
          if (index == 1) context.go('/my-animals');
          if (index == 2) context.go('/alerts');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }
}
