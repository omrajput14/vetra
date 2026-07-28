import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/vet_card.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NearbyVetsPage extends StatefulWidget {
  const NearbyVetsPage({super.key});

  @override
  State<NearbyVetsPage> createState() => _NearbyVetsPageState();
}

class _NearbyVetsPageState extends State<NearbyVetsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authNotifier.fetchNearbyVets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authNotifier,
      builder: (context, _) {
        final vets = authNotifier.vetsList;

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text('Nearby Vets Directory', style: AppTypography.screenTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                onPressed: () => authNotifier.fetchNearbyVets(),
              ),
              IconButton(
                icon: const Icon(Icons.map, color: AppColors.primary),
                onPressed: () => context.push('/outbreak-map'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => await authNotifier.fetchNearbyVets(),
            child: vets.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderHairline),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.local_hospital_outlined, size: 48, color: AppColors.primary),
                            const SizedBox(height: 12),
                            Text('No Registered Vets Online Yet', style: AppTypography.cardTitle),
                            const SizedBox(height: 6),
                            Text(
                              'Swipe down or tap refresh to check for active veterinarians registered in your area.',
                              style: AppTypography.captionMetadata,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Sample Registered Practitioners', style: AppTypography.sectionHeading),
                      const SizedBox(height: 12),
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
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final v = vets[index];
                      final vetId = v['id']?.toString() ?? '';
                      final vetName = v['fullName']?.toString() ?? 'Dr. Veterinarian';
                      final spec = v['specialization']?.toString() ?? v['qualification']?.toString() ?? 'Veterinary Officer';
                      final clinic = v['clinicName']?.toString() ?? 'Clinical Practice';

                      return VetCard(
                        name: vetName,
                        designation: '$spec • $clinic',
                        distance: 'Verified Practitioner',
                        rating: 5.0,
                        onBookTap: () => context.push(
                          '/appointment-booking',
                          extra: {'vetId': vetId, 'vetName': vetName},
                        ),
                      );
                    },
                  ),
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
      },
    );
  }
}
