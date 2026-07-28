import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

class VetCard extends StatelessWidget {
  final String name;
  final String designation;
  final String distance;
  final double rating;
  final VoidCallback? onBookTap;
  final VoidCallback? onTap;

  const VetCard({
    super.key,
    required this.name,
    required this.designation,
    required this.distance,
    required this.rating,
    this.onBookTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? onBookTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderHairline),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Icon(Icons.medical_services, color: AppColors.vetAccent, size: 26),
                ),
                const SizedBox(width: 14),
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: onBookTap ?? onTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
