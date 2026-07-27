import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class VetProfilePage extends StatefulWidget {
  const VetProfilePage({super.key});

  @override
  State<VetProfilePage> createState() => _VetProfilePageState();
}

class _VetProfilePageState extends State<VetProfilePage> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Veterinarian Profile', style: AppTypography.screenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Icon(Icons.medical_services, size: 52, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text('Dr. Sarah Jenkins', style: AppTypography.screenTitle.copyWith(fontSize: 22)),
                const SizedBox(height: 4),
                Text('BVSc & AH • Senior Livestock Veterinarian', style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('License Reg #VET-9941-XX', style: AppTypography.captionMetadata.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
                      color: _isAvailable ? AppColors.primary : AppColors.cautionAmber,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Availability Status', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                        Text(_isAvailable ? 'Available for On-Call & Emergencies' : 'Currently On Leave / Unavailable', style: AppTypography.captionMetadata),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _isAvailable,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isAvailable = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Practitioner Info', style: AppTypography.sectionHeading),
          const SizedBox(height: 8),
          _buildInfoTile(Icons.school, 'Qualification', 'BVSc & AH, MVSc (Large Animal Medicine)'),
          const SizedBox(height: 8),
          _buildInfoTile(Icons.local_hospital, 'Clinic / Hospital', 'Valley Veterinary Hospital'),
          const SizedBox(height: 8),
          _buildInfoTile(Icons.workspace_premium, 'Specialization', 'Ruminant Epidemiology & Surgery'),
          const SizedBox(height: 8),
          _buildInfoTile(Icons.history, 'Years of Experience', '12 Years Clinical Practice'),
          const SizedBox(height: 8),
          _buildInfoTile(Icons.phone, 'Contact Information', '+1 (555) 019-8833 • dr.sarah@valleyvet.org'),
          const SizedBox(height: 24),
          ListTile(
            tileColor: AppColors.alertCritical.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.logout, color: AppColors.alertCritical),
            title: Text('Log Out', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.alertCritical)),
            onTap: () {
              authNotifier.logout();
              context.go('/welcome');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: VetBottomNavigation(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) context.go('/vet-dashboard');
          if (index == 1) context.go('/vet-requests');
          if (index == 2) context.go('/consultation-history');
          if (index == 3) context.go('/vet-outbreak-map');
          if (index == 4) context.go('/vet-profile');
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.captionMetadata),
                Text(value, style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
