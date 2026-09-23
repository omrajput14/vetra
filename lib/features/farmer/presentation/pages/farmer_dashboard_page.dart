import 'package:flutter/material.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../animal/presentation/providers/animal_provider.dart';
import '../../../disease/presentation/providers/disease_registry_provider.dart';
import '../../../shared/presentation/widgets/sync_status_banner.dart';

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
      diseaseRegistryNotifier.loadRegistry();
    });
  }

  void _showEconomicInfoDialog(BuildContext context, AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.modeledEstimate ?? 'Modeled estimate',
                style: AppTypography.cardTitle.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          l10n?.modeledSavingsTooltip ??
              'Modeled from registered livestock data and early-detection assumptions. Not an audited financial figure.',
          style: AppTypography.bodyDefault.copyWith(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.confirm ?? 'Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeLocale = ref.watch(localeProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([dashboardNotifier, diseaseRegistryNotifier]),
      builder: (context, _) {
        final dash = dashboardNotifier.dashboard;
        final economic = dashboardNotifier.economicImpact;
        // Offline: identity comes from the profile cached at sign-in; counts are
        // unknown ("—") rather than a made-up 0.
        final cachedUser = authNotifier.currentUser;
        final animalCount = dash?.registeredAnimalCount.toString() ?? '—';
        final facilityName = dash?.facilityName ?? cachedUser?.farmName ?? 'My Farm';
        final userName = dash?.userName ?? cachedUser?.name ?? 'Farmer';

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/branding/vetra_logo_transparent.png', height: 28, width: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'PASHU SATHI',
                    style: AppTypography.screenTitle.copyWith(color: AppColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
            onRefresh: () async {
              await Future.wait([
                dashboardNotifier.loadDashboard(),
                diseaseRegistryNotifier.loadRegistry(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SyncStatusBanner(),
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
                              Text(animalCount, style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 32)),
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
                              Text(dash?.pendingAppointmentsCount.toString() ?? '—', style: AppTypography.screenTitle.copyWith(color: AppColors.cautionAmber, fontSize: 32)),
                              Text(l10n?.statsAppointments ?? 'Checkups Due', style: AppTypography.captionMetadata),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Feature 3: Estimated Savings from Early Detection (Modeled Estimate)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderHairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n?.estimatedSavingsTitle ?? 'Estimated savings from early detection',
                              style: AppTypography.cardTitle.copyWith(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _showEconomicInfoDialog(context, l10n),
                            tooltip: l10n?.modeledSavingsTooltip ?? 'Modeled estimate info',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (economic != null && economic.hasSufficientData && economic.formattedValue != null)
                            Text(
                              economic.formattedValue!,
                              style: AppTypography.screenTitle.copyWith(
                                color: AppColors.primary,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            Text(
                              l10n?.estimatedSavingsUnavailable ?? 'Estimated savings unavailable',
                              style: AppTypography.bodyDefault.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              l10n?.modeledEstimate ?? 'Modeled estimate',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (economic != null && economic.hasSufficientData && economic.eligibleAnimalsCount > 0) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${economic.eligibleAnimalsCount} livestock covered by early detection telemetry',
                          style: AppTypography.captionMetadata.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
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
                        label: l10n?.scanDisease ?? 'Scan Disease',
                        onTap: () => context.push('/disease-scanner'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.add_circle_outline,
                        label: l10n?.addAnimal ?? 'Add Animal',
                        onTap: () => context.push('/add-animal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.calendar_month,
                        label: l10n?.bookConsultation ?? 'Book Consultation',
                        onTap: () => context.push('/appointment-booking'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.heart_broken_outlined,
                        label: 'Report Death',
                        onTap: () => context.push('/report-mortality'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // AI Veterinary Advisor Shortcut Card
                GestureDetector(
                  onTap: () {
                    final activeId = animalNotifier.selectedAnimalId ??
                        (animalNotifier.animals.isNotEmpty ? animalNotifier.animals.first.id : '');
                    context.push('/ai-advisor', extra: activeId);
                  },
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

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    // Break multi-word labels cleanly between words at the first space so no word breaks mid-word
    final formattedLabel = label.contains(' ') ? label.replaceFirst(' ', '\n') : label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderHairline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    formattedLabel,
                    style: AppTypography.buttonLabel.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
