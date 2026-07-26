import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/cards/animal_card.dart';

class MyAnimalsOfflineStatePage extends StatelessWidget {
  const MyAnimalsOfflineStatePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'Offline: Changes will sync once connected',
                  style: AppTypography.captionMetadata.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AnimalCard(
                  name: 'Bessie (Cached)',
                  tagId: 'NL-93842',
                  breed: 'Holstein',
                  status: 'Offline Cached',
                  onTap: () => context.push('/animal-passport'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
