import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/animal_card.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';

class MyAnimalsPage extends StatefulWidget {
  const MyAnimalsPage({super.key});

  @override
  State<MyAnimalsPage> createState() => _MyAnimalsPageState();
}

class _MyAnimalsPageState extends State<MyAnimalsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animalNotifier.loadAnimals().then((_) {
        dashboardNotifier.loadDashboard();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animalNotifier,
      builder: (context, _) {
        final animals = animalNotifier.animals;
        final isLoading = animalNotifier.isLoading;
        final hasFetched = animalNotifier.hasFetchedFromServer;

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text('My Animals', style: AppTypography.screenTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                tooltip: 'Scan Animal Tag QR',
                onPressed: () => context.push('/qr-scanner-vet'),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                tooltip: 'Add Animal',
                onPressed: () => context.push('/add-animal'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    if (val.trim().isEmpty) {
                      animalNotifier.loadAnimals();
                    } else {
                      animalNotifier.searchAnimals(tagNumber: val.trim(), animalName: val.trim());
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search animals by name or tag number...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                      tooltip: 'Scan Animal Tag QR',
                      onPressed: () => context.push('/qr-scanner-vet'),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                  ),
                ),
              ),
              Expanded(
                child: isLoading && animals.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : animals.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.pets, size: 64, color: AppColors.textSecondary),
                                  const SizedBox(height: 16),
                                  Text(
                                    hasFetched ? 'No registered animals found.' : 'Loading your animals...',
                                    style: AppTypography.cardTitle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  if (!hasFetched)
                                    const Text(
                                      'Syncing with server, please wait a moment.',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      textAlign: TextAlign.center,
                                    )
                                  else ...[
                                    const Text(
                                      'Register your first animal to get started with PASHU SATHI.',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => context.push('/add-animal'),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Your First Animal'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await animalNotifier.loadAnimals();
                              await dashboardNotifier.loadDashboard();
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: animals.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final animal = animals[index];
                                return AnimalCard(
                                  name: animal.displayName,
                                  tagId: animal.tagNumber,
                                  breed: animal.breed ?? animal.species,
                                  status: animal.status ?? 'REGISTERED',
                                  photoUrl: animal.photoUrl,
                                  localPhotoPath: animal.localPhotoPath,
                                  onTap: () => context.push('/animal-passport', extra: animal.id),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          bottomNavigationBar: FarmerBottomNavigation(
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) context.go('/farmer-dashboard');
              if (index == 1) context.go('/my-animals');
              if (index == 2) context.go('/alerts');
              if (index == 3) context.go('/nearby-vets');
              if (index == 4) context.go('/profile');
            },
          ),
        );
      },
    );
  }
}
