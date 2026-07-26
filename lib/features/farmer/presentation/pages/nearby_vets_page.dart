import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/vet_card.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';

class NearbyVetsPage extends StatelessWidget {
  const NearbyVetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Nearby Vets', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppColors.primary),
            onPressed: () => context.push('/outbreak-map'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          VetCard(
            name: 'Dr. S. Patel',
            designation: 'Large Animals Officer',
            distance: '2.5 km away',
            rating: 4.9,
          ),
          SizedBox(height: 12),
          VetCard(
            name: 'Dr. E. Carter',
            designation: 'Equine & Bovine Specialist',
            distance: '4.1 km away',
            rating: 4.7,
          ),
          SizedBox(height: 12),
          VetCard(
            name: 'Dr. M. Nguyen',
            designation: 'Mixed Clinical Practice',
            distance: '6.8 km away',
            rating: 5.0,
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
