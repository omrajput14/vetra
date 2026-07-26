import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';

class VetProfilePage extends StatelessWidget {
  const VetProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Veterinarian Profile', style: AppTypography.screenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Icon(Icons.medical_services, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text('Dr. Silva', style: AppTypography.screenTitle),
                Text('Valley Veterinary Clinic • License VET-9941', style: AppTypography.captionMetadata),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go('/vet-requests');
          if (index == 1) context.go('/consultation-history');
          if (index == 2) context.go('/outbreak-map');
        },
      ),
    );
  }
}
