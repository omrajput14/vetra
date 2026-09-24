import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

/// General outbreak biosecurity steps; nothing here is specific to one farm.
class BiosecurityRecommendationsPage extends StatelessWidget {
  const BiosecurityRecommendationsPage({super.key});

  static const _steps = [
    'Keep sick animals apart from the herd in a separate pen or shed, with their own feed, water and equipment.',
    'Do not buy, sell, move or graze animals with other herds until your veterinarian says it is safe.',
    'Keep visitors and vehicles away from animal areas. Anyone who must enter should clean their boots and wash their hands.',
    'Disinfect footwear, tools and vehicles with a disinfectant your veterinarian recommends for the disease '
        '(for example, 4% washing soda solution for foot-and-mouth disease).',
    'Do not open or cut the body of an animal that died suddenly. Ask your veterinarian how to dispose of it safely.',
    'Report every sick or dead animal to your veterinarian as soon as you notice it.',
    'Keep newly bought animals apart for at least 3 weeks before they join the herd.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Biosecurity Checklist', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protecting your herd during an outbreak', style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                for (var i = 0; i < _steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('${i + 1}. ${_steps[i]}', style: AppTypography.bodyDefault),
                  ),
                const SizedBox(height: 8),
                Text(
                  'General guidance. Follow your veterinarian\'s instructions for your farm.',
                  style: AppTypography.captionMetadata,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
