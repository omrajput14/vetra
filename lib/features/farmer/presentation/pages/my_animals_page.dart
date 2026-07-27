import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/animal_card.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../animal/presentation/providers/animal_provider.dart';

class MyAnimalsPage extends StatefulWidget {
  const MyAnimalsPage({super.key});

  @override
  State<MyAnimalsPage> createState() => _MyAnimalsPageState();
}

class _MyAnimalsPageState extends State<MyAnimalsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animalNotifier.loadAnimals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      animalNotifier.loadAnimals();
    } else {
      animalNotifier.searchAnimals(tagNumber: query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animalNotifier,
      builder: (context, _) {
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
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search by tag number, species...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMetadata),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    animalNotifier.loadAnimals();
                                  },
                                )
                              : null,
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
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await animalNotifier.loadAnimals(),
                  child: animalNotifier.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : animalNotifier.animals.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 80),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.pets, size: 64, color: AppColors.textMetadata),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No animals registered yet',
                                        style: AppTypography.screenTitle.copyWith(fontSize: 18),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap + Add Animal below to add your first animal.',
                                        style: AppTypography.captionMetadata,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: animalNotifier.animals.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final animal = animalNotifier.animals[index];
                                return AnimalCard(
                                  name: animal.tagNumber,
                                  tagId: animal.qrCodeId ?? animal.tagNumber,
                                  breed: '${animal.species} • ${animal.breed ?? "Unknown breed"}',
                                  status: animal.gender,
                                  onTap: () => context.push('/animal-passport', extra: animal.id),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: AppColors.textPrimary,
            onPressed: () async {
              await context.push('/add-animal');
              animalNotifier.loadAnimals();
            },
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
      },
    );
  }
}
