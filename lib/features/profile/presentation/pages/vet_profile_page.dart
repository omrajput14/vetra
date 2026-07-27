import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/availability_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/action_card.dart';

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
          // 1. Profile Header
          const ProfileHeaderCard(
            name: 'Dr. Sarah Jenkins',
            regNo: 'Reg #VET-9941-XX',
            qualification: 'BVSc & AH, MVSc (Large Animal Medicine)',
            specialization: 'Ruminant Epidemiology & Surgery',
            hospital: 'Valley Veterinary Hospital',
          ),
          const SizedBox(height: 14),

          // 2. Availability Status Card
          AvailabilityCard(
            isAvailable: _isAvailable,
            onChanged: (val) => setState(() => _isAvailable = val),
          ),
          const SizedBox(height: 20),

          // 3. Practitioner Info Section
          Text('Practitioner Information', style: AppTypography.sectionHeading),
          const SizedBox(height: 10),
          const InfoTile(
            icon: Icons.school_outlined,
            label: 'Qualification & Degrees',
            value: 'BVSc & AH, MVSc (Large Animal Medicine)',
          ),
          const SizedBox(height: 8),
          const InfoTile(
            icon: Icons.workspace_premium_outlined,
            label: 'Clinical Specialization',
            value: 'Ruminant Epidemiology & Surgical Triage',
          ),
          const SizedBox(height: 8),
          const InfoTile(
            icon: Icons.history_outlined,
            label: 'Years of Experience',
            value: '12 Years Clinical Practice',
          ),
          const SizedBox(height: 8),
          const InfoTile(
            icon: Icons.phone_outlined,
            label: 'Direct Practitioner Contact',
            value: '+1 (555) 019-8833 • dr.sarah@valleyvet.org',
          ),
          const SizedBox(height: 24),

          // 4. Professional Quick Actions Section
          Text('Quick Actions', style: AppTypography.sectionHeading),
          const SizedBox(height: 10),
          ActionCard(
            icon: Icons.edit_note_outlined,
            title: 'Edit Profile & Qualifications',
            subtitle: 'Update clinical details and contact info',
            onTap: () => context.push('/edit-profile'),
          ),
          const SizedBox(height: 8),
          ActionCard(
            icon: Icons.calendar_today_outlined,
            title: 'My Clinical Schedule',
            subtitle: 'View upcoming consultations and visits',
            onTap: () => context.go('/consultation-history'),
          ),
          const SizedBox(height: 8),
          ActionCard(
            icon: Icons.tune_outlined,
            title: 'Availability & Shift Settings',
            subtitle: 'Configure emergency response hours',
            onTap: () => context.push('/notification-preferences'),
          ),
          const SizedBox(height: 8),
          ActionCard(
            icon: Icons.verified_outlined,
            title: 'Documents & Licenses',
            subtitle: 'Manage verified registration certificates',
            onTap: () => context.push('/about-legal'),
          ),
          const SizedBox(height: 8),
          ActionCard(
            icon: Icons.logout_outlined,
            title: 'Log Out Practitioner Account',
            subtitle: 'Safely end active session',
            isDanger: true,
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
}
