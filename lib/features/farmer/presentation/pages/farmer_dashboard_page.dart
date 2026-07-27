import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';

class FarmerDashboardPage extends StatefulWidget {
  const FarmerDashboardPage({super.key});

  @override
  State<FarmerDashboardPage> createState() => _FarmerDashboardPageState();
}

class _FarmerDashboardPageState extends State<FarmerDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardNotifier.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dashboardNotifier,
      builder: (context, _) {
        final dash = dashboardNotifier.dashboard;
        final animalCount = dash?.registeredAnimalCount ?? 0;
        final facilityName = dash?.facilityName ?? 'My Farm';
        final userName = dash?.userName ?? 'Farmer';

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
                Text('Welcome back, $userName', style: AppTypography.screenTitle.copyWith(fontSize: 22)),
                Text(facilityName, style: AppTypography.captionMetadata.copyWith(fontSize: 14)),
                const SizedBox(height: 20),
                Text('Overview', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
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
                            Text('$animalCount', style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 32)),
                            Text('Registered Animals', style: AppTypography.captionMetadata),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            Text('${dash?.pendingAppointmentsCount ?? 0}', style: AppTypography.screenTitle.copyWith(color: AppColors.cautionAmber, fontSize: 32)),
                            Text('Checkups Due', style: AppTypography.captionMetadata),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Quick Actions', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.camera_alt,
                        label: 'AI Disease Scan',
                        onTap: () => context.push('/disease-scanner'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.add_circle_outline,
                        label: 'Add Animal',
                        onTap: () => context.push('/add-animal'),
                      ),
                    ),
                  ],
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
