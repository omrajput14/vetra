import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/animal_card.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';

class MyAnimalsPage extends StatelessWidget {
  const MyAnimalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('My Animals', style: AppTypography.screenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.sos, color: AppColors.alertCritical, size: 28),
            onPressed: () => context.push('/report-disease'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, tag ID...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMetadata),
                      fillColor: AppColors.surfaceCard,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.borderHairline),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: AppColors.primary),
                  onPressed: () => context.push('/filters'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                AnimalCard(
                  name: 'Bessie',
                  tagId: 'NL-93842',
                  breed: 'Holstein',
                  status: 'Healthy',
                  onTap: () => context.push('/animal-passport'),
                ),
                const SizedBox(height: 12),
                AnimalCard(
                  name: 'Daisy',
                  tagId: 'NL-93845',
                  breed: 'Jersey',
                  status: 'Checkup Due',
                  onTap: () => context.push('/animal-passport'),
                ),
                const SizedBox(height: 12),
                AnimalCard(
                  name: 'Thunder',
                  tagId: 'IE-44501',
                  breed: 'Angus',
                  status: 'Healthy',
                  onTap: () => context.push('/animal-passport'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: AppColors.textPrimary,
        onPressed: () => context.push('/add-animal'),
        icon: const Icon(Icons.add),
        label: Text('Add Animal', style: AppTypography.buttonLabel),
      ),
      bottomNavigationBar: FarmerBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/farmer-dashboard');
          if (index == 2) context.go('/alerts');
          if (index == 3) context.go('/nearby-vets');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }
}
