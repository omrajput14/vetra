import 'package:flutter/material.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../shared/presentation/widgets/sync_status_banner.dart';

class VetDashboardPage extends ConsumerStatefulWidget {
  const VetDashboardPage({super.key});

  @override
  ConsumerState<VetDashboardPage> createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends ConsumerState<VetDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardNotifier.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Locale activeLocale = const Locale('en');
    try {
      activeLocale = ref.watch(localeProvider);
    } catch (_) {}

    return AnimatedBuilder(
      animation: dashboardNotifier,
      builder: (context, _) {
        final dash = dashboardNotifier.dashboard;
        // Offline: identity comes from the profile cached at sign-in; counts are
        // unknown ("—") rather than a made-up 0.
        final cachedUser = authNotifier.currentUser;
        final vetName = dash?.userName ?? cachedUser?.name ?? 'Practitioner';
        final clinicName = dash?.facilityName ?? cachedUser?.clinicName ?? (l10n?.clinicName ?? 'Veterinary Clinic');
        final animalCount = dash?.registeredAnimalCount.toString() ?? '—';

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/branding/vetra_logo_transparent.png', height: 26, width: 26),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n?.vetDashboard ?? 'VET DASHBOARD',
                    style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => context.push('/language-settings'),
                icon: const Icon(Icons.language, size: 16, color: AppColors.primary),
                label: Text(
                  AppLocales.getLanguageNativeName(activeLocale.languageCode),
                  style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                onPressed: () => context.push('/notifications'),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => await dashboardNotifier.loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SyncStatusBanner(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n?.welcomeVet ?? "Welcome, Doctor"}, $vetName',
                            style: AppTypography.sectionHeading,
                          ),
                          const SizedBox(height: 2),
                          Text(clinicName, style: AppTypography.captionMetadata),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderHairline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(animalCount, style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 32)),
                            const SizedBox(height: 4),
                            Text(l10n?.surveillanceAnimals ?? 'Surveillance Animals', style: AppTypography.captionMetadata),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/vet-requests'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderHairline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dash?.pendingAppointmentsCount.toString() ?? '—', style: AppTypography.screenTitle.copyWith(color: AppColors.cautionAmber, fontSize: 32)),
                              const SizedBox(height: 4),
                              Text(l10n?.pendingRequests ?? 'Pending Requests', style: AppTypography.captionMetadata),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n?.quickClinicalActions ?? 'Quick Clinical Actions', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.qr_code_scanner,
                        label: l10n?.scanAnimalQr ?? 'Scan Animal QR',
                        onTap: () => context.push('/qr-scanner-vet'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.add_task,
                        label: l10n?.diagnosisEntry ?? 'Diagnosis Entry',
                        onTap: () => context.push('/diagnosis-entry'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.assignment_late_outlined,
                        label: 'Mortality Reviews',
                        onTap: () => context.push('/vet-mortality-inbox'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.map_outlined,
                        label: 'Outbreak Map',
                        onTap: () => context.push('/vet-outbreak-map'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: VetBottomNavigation(
            currentIndex: 0,
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

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderHairline),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.buttonLabel.copyWith(fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
