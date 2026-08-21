import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';

class FarmerDashboardPage extends ConsumerStatefulWidget {
  const FarmerDashboardPage({super.key});

  @override
  ConsumerState<FarmerDashboardPage> createState() => _FarmerDashboardPageState();
}

class _FarmerDashboardPageState extends ConsumerState<FarmerDashboardPage> {
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
    final activeLocale = ref.watch(localeProvider);

    return AnimatedBuilder(
      animation: dashboardNotifier,
      builder: (context, _) {
        final dash = dashboardNotifier.dashboard;
        final animalCount = dash?.registeredAnimalCount ?? 0;
        final facilityName = dash?.facilityName ?? 'My Farm';
        final userName = dash?.userName ?? (l10n?.welcomeFarmer ?? 'Farmer');

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.health_and_safety, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Text('VETRA', style: AppTypography.screenTitle.copyWith(color: AppColors.primary)),
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
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => await dashboardNotifier.loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('${l10n?.welcomeFarmer ?? "Welcome"}, $userName', style: AppTypography.screenTitle.copyWith(fontSize: 22)),
                Text(facilityName, style: AppTypography.captionMetadata.copyWith(fontSize: 14)),
                const SizedBox(height: 20),
                Text(l10n?.statsAnimals ?? 'Overview', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go('/my-animals'),
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
                              Text('$animalCount', style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 32)),
                              Text(l10n?.statsAnimals ?? 'Registered Animals', style: AppTypography.captionMetadata),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/farmer-appointments'),
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
                              Text('${dash?.pendingAppointmentsCount ?? 0}', style: AppTypography.screenTitle.copyWith(color: AppColors.cautionAmber, fontSize: 32)),
                              Text(l10n?.statsAppointments ?? 'Checkups Due', style: AppTypography.captionMetadata),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n?.quickActions ?? 'Quick Actions', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.camera_alt,
                        label: l10n?.scanDisease ?? 'AI Scan',
                        onTap: () => context.push('/disease-scanner'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.add_circle_outline,
                        label: l10n?.addAnimal ?? 'Add Animal',
                        onTap: () => context.push('/add-animal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.calendar_month,
                        label: l10n?.bookConsultation ?? 'Book Checkup',
                        onTap: () => context.push('/appointment-booking'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // AI Veterinary Advisor Shortcut Card
                GestureDetector(
                  onTap: () => context.push('/ai-advisor'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.surfaceContainer,
                          AppColors.surfaceCard,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.aiVeterinaryAdvisor ?? 'AI Veterinary Advisor',
                                style: AppTypography.cardTitle.copyWith(fontSize: 16),
                              ),
                              Text(
                                l10n?.assistiveClinicalScreening ?? 'Assistive Clinical Screening & Care',
                                style: AppTypography.captionMetadata,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: FarmerBottomNavigation(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) context.go('/my-animals');
              if (index == 2) context.go('/alerts');
              if (index == 3) context.go('/nearby-vets');
              if (index == 4) context.go('/profile');
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
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
