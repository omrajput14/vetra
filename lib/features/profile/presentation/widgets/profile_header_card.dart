import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String regNo;
  final String qualification;
  final String specialization;
  final String hospital;
  final String? profilePhotoUrl;
  final String? verificationStatus;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.regNo,
    required this.qualification,
    required this.specialization,
    required this.hospital,
    this.profilePhotoUrl,
    this.verificationStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isVerified = verificationStatus == 'VERIFIED';
    final isPending = verificationStatus == 'PENDING' || verificationStatus == null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                  image: (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(profilePhotoUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: (profilePhotoUrl == null || profilePhotoUrl!.isEmpty)
                    ? const Icon(Icons.medical_services_outlined, size: 36, color: AppColors.primary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? Colors.green
                        : (isPending ? AppColors.cautionAmber : AppColors.alertCritical),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVerified ? Icons.check : (isPending ? Icons.hourglass_empty : Icons.close),
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypography.screenTitle.copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        regNo,
                        style: AppTypography.captionMetadata.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  qualification,
                  style: AppTypography.bodyDefault.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  specialization,
                  style: AppTypography.captionMetadata.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_hospital_outlined, size: 14, color: AppColors.textMetadata),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hospital,
                        style: AppTypography.captionMetadata.copyWith(
                          color: AppColors.textMetadata,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
