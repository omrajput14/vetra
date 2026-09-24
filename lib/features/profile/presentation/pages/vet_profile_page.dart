import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authNotifier.restoreSession();
      dashboardNotifier.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([authNotifier, dashboardNotifier]),
      builder: (context, _) {
        final user = authNotifier.currentUser;
        final dash = dashboardNotifier.dashboard;

        final vetName = user?.name.isNotEmpty == true ? user!.name : (dash?.userName ?? 'Dr. Practitioner');
        final regNo = user?.metadata['registrationNumber'] != null
            ? 'Reg #${user!.metadata['registrationNumber']}'
            : 'Reg #VET-VERIFIED';
        final qualification = user?.metadata['qualification']?.toString() ?? 'BVSc & AH, MVSc';
        final specialization = user?.metadata['specialization']?.toString() ?? 'Veterinary Medicine & Surgery';
        final hospital = user?.metadata['clinicName']?.toString() ?? (dash?.facilityName ?? (l10n?.clinicName ?? 'Veterinary Clinic'));
        final yearsExp = user?.metadata['yearsExperience']?.toString() ?? '0';
        final contact = user?.emailOrPhone ?? '';

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text(l10n?.vetProfile ?? 'Veterinarian Profile', style: AppTypography.screenTitle),
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    tooltip: 'Back',
                    onPressed: () => context.pop(),
                  )
                : null,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Dynamic Profile Header
              ProfileHeaderCard(
                name: vetName,
                regNo: regNo,
                qualification: qualification,
                specialization: specialization,
                hospital: hospital,
                profilePhotoUrl: user?.profilePhotoUrl,
                verificationStatus: user?.metadata['verificationStatus']?.toString(),
              ),
              const SizedBox(height: 14),

              // 2. Availability Status Card
              AvailabilityCard(
                isAvailable: user?.isAvailable ?? _isAvailable,
                onChanged: (val) async {
                  setState(() => _isAvailable = val);
                  await authNotifier.updateDutyStatus(val);
                },
              ),
              const SizedBox(height: 20),

              // 3. Practitioner Info Section
              Text(l10n?.practitionerInfo ?? 'Practitioner Information', style: AppTypography.sectionHeading),
              const SizedBox(height: 10),
              InfoTile(
                icon: Icons.school_outlined,
                label: l10n?.qualificationsAndDegrees ?? 'Qualification & Degrees',
                value: qualification,
              ),
              const SizedBox(height: 8),
              InfoTile(
                icon: Icons.workspace_premium_outlined,
                label: l10n?.clinicalSpecialization ?? 'Clinical Specialization',
                value: specialization,
              ),
              const SizedBox(height: 8),
              InfoTile(
                icon: Icons.location_city_outlined,
                label: 'Clinic Address & Location',
                value: user?.clinicAddress ?? (dash?.facilityName ?? 'Address not configured'),
              ),
              const SizedBox(height: 8),
              InfoTile(
                icon: Icons.verified_user_outlined,
                label: 'Veterinary Council Certificate',
                value: user?.certificateUrl != null
                    ? 'Certificate Uploaded (${user?.certificateStatus})'
                    : 'Pending Document Upload',
              ),
              const SizedBox(height: 8),
              InfoTile(
                icon: Icons.history_outlined,
                label: l10n?.yearsClinicalPractice ?? 'Years of Experience',
                value: '$yearsExp ${l10n?.yearsClinicalPractice ?? "Years Clinical Practice"}',
              ),
              const SizedBox(height: 8),
              InfoTile(
                icon: Icons.phone_outlined,
                label: l10n?.directContact ?? 'Direct Practitioner Contact',
                value: contact,
              ),
              const SizedBox(height: 24),

              // 4. Professional Quick Actions Section
              Text(l10n?.quickActions ?? 'Quick Actions', style: AppTypography.sectionHeading),
              const SizedBox(height: 10),
              ActionCard(
                icon: Icons.language_outlined,
                title: l10n?.languageSettings ?? 'Language Settings',
                subtitle: l10n?.chooseLanguage ?? 'Choose your preferred language',
                onTap: () => context.push('/language-settings'),
              ),
              const SizedBox(height: 8),
              ActionCard(
                icon: Icons.edit_note_outlined,
                title: l10n?.editProfileQualifications ?? 'Edit Profile & Qualifications',
                subtitle: l10n?.editProfileSubtitle ?? 'Update clinical details and contact info',
                onTap: () => context.push('/edit-profile'),
              ),
              const SizedBox(height: 8),
              ActionCard(
                icon: Icons.calendar_today_outlined,
                title: l10n?.clinicalSchedule ?? 'My Clinical Schedule',
                subtitle: l10n?.clinicalScheduleSubtitle ?? 'View upcoming consultations and visits',
                onTap: () => context.push('/clinical-schedule'),
              ),
              const SizedBox(height: 8),
              ActionCard(
                icon: Icons.tune_outlined,
                title: l10n?.availabilityShiftSettings ?? 'Availability & Shift Settings',
                subtitle: l10n?.availabilityShiftSubtitle ?? 'Configure emergency response hours',
                onTap: () => context.push('/shift-settings'),
              ),
              const SizedBox(height: 8),
              ActionCard(
                icon: Icons.lock_outline,
                title: l10n?.securitySettings ?? 'Security Settings',
                subtitle: 'Change your password',
                onTap: () => context.push('/security-settings'),
              ),
              const SizedBox(height: 8),
              ActionCard(
                icon: Icons.info_outline,
                title: l10n?.aboutLegal ?? 'About & Legal',
                subtitle: 'Version, team and open-source licences',
                onTap: () => context.push('/about-legal'),
              ),
              const SizedBox(height: 8),
              ActionCard(
                icon: Icons.logout_outlined,
                title: l10n?.logoutVetAccount ?? 'Log Out Practitioner Account',
                subtitle: l10n?.logoutVetAccountSubtitle ?? 'Safely end active session',
                isDanger: true,
                onTap: () async {
                  await authNotifier.logout();
                  if (context.mounted) context.go('/welcome');
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/branding/vetra_logo_transparent.png', height: 40, width: 40),
                    const SizedBox(height: 8),
                    Text('PASHU SATHI', style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 16, letterSpacing: 1.2)),
                    const SizedBox(height: 2),
                    Text('Veterinary Clinical Network', style: AppTypography.captionMetadata),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
      },
    );
  }
}
