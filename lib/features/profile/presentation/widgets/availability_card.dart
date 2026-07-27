import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class AvailabilityCard extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  const AvailabilityCard({
    super.key,
    required this.isAvailable,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isAvailable ? AppColors.primary : AppColors.cautionAmber;
    final statusText = isAvailable ? 'Available for On-Call & Triage' : 'Currently On Leave / Unavailable';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.check_circle_outline : Icons.pause_circle_outline,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duty Status',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: AppTypography.captionMetadata.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
