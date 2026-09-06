import 'package:flutter/material.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../l10n/app_localizations.dart';

/// Reusable high-contrast warning component for diseases transmissible to humans (zoonotic).
class ZoonoticWarningBanner extends StatelessWidget {
  final String? diseaseName;
  final EdgeInsetsGeometry? margin;

  const ZoonoticWarningBanner({
    super.key,
    this.diseaseName,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5), // Accessible high-contrast warm background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD9381E), // Vivid alert crimson
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD9381E).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9381E).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Color(0xFFD9381E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n?.zoonoticHumanHealthRisk ?? 'ZOONOTIC / HUMAN HEALTH RISK',
                  style: AppTypography.cardTitle.copyWith(
                    color: const Color(0xFF9E1F10),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9381E),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n?.zoonoticGuidance ?? 'Public Health Advisory',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.zoonoticWarningMessage ??
                'This disease may affect humans. Avoid direct contact and seek veterinary/public-health guidance.',
            style: AppTypography.bodyDefault.copyWith(
              color: const Color(0xFF4A180E),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (diseaseName != null && diseaseName!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Identified Pathogen: ${diseaseName!.trim()}',
              style: AppTypography.captionMetadata.copyWith(
                color: const Color(0xFF7A2E1E),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
