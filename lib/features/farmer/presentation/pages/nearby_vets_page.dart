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
        title: Text('Nearby Vets Directory', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppColors.primary),
            onPressed: () => context.push('/outbreak-map'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          VetCard(
            name: 'Dr. S. Patel',
            designation: 'Large Animals Officer',
            distance: '2.5 km away',
            rating: 4.9,
            onBookTap: () => context.push('/appointment-booking', extra: {'vetName': 'Dr. S. Patel'}),
          ),
          const SizedBox(height: 12),
          VetCard(
            name: 'Dr. E. Carter',
            designation: 'Equine & Bovine Specialist',
            distance: '4.1 km away',
            rating: 4.7,
            onBookTap: () => context.push('/appointment-booking', extra: {'vetName': 'Dr. E. Carter'}),
          ),
          const SizedBox(height: 12),
          VetCard(
            name: 'Dr. M. Nguyen',
            designation: 'Mixed Clinical Practice',
            distance: '6.8 km away',
            rating: 5.0,
            onBookTap: () => context.push('/appointment-booking', extra: {'vetName': 'Dr. M. Nguyen'}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: Text('Book Appointment', style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
        onPressed: () => context.push('/appointment-booking'),
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
