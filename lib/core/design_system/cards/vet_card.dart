import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

class VetCard extends StatelessWidget {
  final String name;
  final String designation;
  final String distance;
  final double rating;

  const VetCard({
    super.key,
    required this.name,
    required this.designation,
    required this.distance,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surfaceContainer,
            child: Icon(Icons.medical_services, color: AppColors.vetAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.cardTitle),
                Text('$designation • $distance', style: AppTypography.captionMetadata),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.cautionAmber, size: 16),
                    const SizedBox(width: 4),
                    Text('$rating', style: AppTypography.captionMetadata.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.call, color: AppColors.primary),
        ],
      ),
    );
  }
}
