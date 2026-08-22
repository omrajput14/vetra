import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Card component for displaying veterinarian profiles in directory and discovery views.
class VetCard extends StatelessWidget {
  final String name;
  final String designation;
  final String distance;
  final double rating;
  final String? phoneNumber;
  final bool? emergencyAvailable;
  final VoidCallback? onCallTap;
  final VoidCallback? onBookTap;
  final VoidCallback? onTap;

  const VetCard({
    super.key,
    required this.name,
    required this.designation,
    required this.distance,
    required this.rating,
    this.phoneNumber,
    this.emergencyAvailable,
    this.onCallTap,
    this.onBookTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap ?? onBookTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.borderHairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 2),
                      Text('$designation • $distance', style: AppTypography.captionMetadata),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.cautionAmber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTypography.captionMetadata.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (emergencyAvailable == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.alertCritical.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.alertCritical.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emergency, size: 10, color: AppColors.alertCritical),
                                  const SizedBox(width: 2),
                                  Text(
                                    l10n?.emergencyAvailable ?? 'Emergency Available',
                                    style: const TextStyle(
                                      color: AppColors.alertCritical,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Dual Action Buttons: [📞 Call Vet] & [📅 Book Appointment]
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.04),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 17, color: AppColors.primary),
                    label: Text(
                      l10n?.callVet ?? 'Call Vet',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: onCallTap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.calendar_month, size: 17),
                    label: Text(
                      l10n?.bookAppointment ?? 'Book Appointment',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
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
