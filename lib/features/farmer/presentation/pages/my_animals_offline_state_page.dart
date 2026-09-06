import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/animal_card.dart';
import '../../../animal/presentation/providers/animal_provider.dart';

class MyAnimalsOfflineStatePage extends StatefulWidget {
  const MyAnimalsOfflineStatePage({super.key});

  @override
  State<MyAnimalsOfflineStatePage> createState() => _MyAnimalsOfflineStatePageState();
}

class _MyAnimalsOfflineStatePageState extends State<MyAnimalsOfflineStatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animalNotifier.loadAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animalNotifier,
      builder: (context, _) {
        final animals = animalNotifier.animals;

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text('My Animals (Offline)', style: AppTypography.screenTitle),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: AppColors.cautionAmber,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Offline Mode: Cached Animal Records',
                      style: AppTypography.captionMetadata.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: animals.isEmpty
                    ? Center(
                        child: Text(
                          'No locally cached animals.',
                          style: AppTypography.cardTitle,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: animals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final animal = animals[index];
                          return AnimalCard(
                            name: '${animal.displayName} (Cached)',
                            tagId: animal.tagNumber,
                            breed: animal.breed ?? animal.species,
                            status: 'Offline Cached',
                            onTap: () => context.push('/animal-passport', extra: animal.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
