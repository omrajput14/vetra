import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// Reusable badge indicating a verified veterinarian professional.
class VerifiedBadge extends StatelessWidget {
  final String? customLabel;
  final bool compact;

  const VerifiedBadge({
    super.key,
    this.customLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = customLabel ?? (l10n?.verifiedVeterinarian ?? 'Verified Veterinarian');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            size: 13,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.captionMetadata.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
