import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';

class VetDashboardPage extends StatefulWidget {
  const VetDashboardPage({super.key});

  @override
  State<VetDashboardPage> createState() => _VetDashboardPageState();
}

class _VetDashboardPageState extends State<VetDashboardPage> {
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
        final vetName = dash?.userName ?? 'Practitioner';
        final clinicName = dash?.facilityName ?? 'Veterinary Clinic';
        final animalCount = dash?.registeredAnimalCount ?? 0;

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.medical_services, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Text('VET DASHBOARD', style: AppTypography.screenTitle.copyWith(color: AppColors.primary)),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, $vetName', style: AppTypography.sectionHeading),
                        Text(clinicName, style: AppTypography.captionMetadata),
                      ],
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
                            Text('$animalCount', style: AppTypography.screenTitle.copyWith(color: AppColors.primary, fontSize: 32)),
                            Text('Surveillance Animals', style: AppTypography.captionMetadata),
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
                            Text('Pending Requests', style: AppTypography.captionMetadata),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Quick Clinical Actions', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.qr_code_scanner,
                        label: 'Scan Animal QR',
                        onTap: () => context.push('/qr-scanner-vet'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        icon: Icons.add_task,
                        label: 'Diagnosis Entry',
                        onTap: () => context.push('/diagnosis-entry'),
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
