import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';

class VetRequestsPage extends StatefulWidget {
  const VetRequestsPage({super.key});

  @override
  State<VetRequestsPage> createState() => _VetRequestsPageState();
}

class _VetRequestsPageState extends State<VetRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appointmentNotifier.loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appointmentNotifier,
      builder: (context, _) {
        final pendingList = appointmentNotifier.pendingAppointments;
        final upcomingList = appointmentNotifier.upcomingAppointments;
        final completedList = appointmentNotifier.completedAppointments;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.surfaceBackground,
            appBar: AppBar(
              backgroundColor: AppColors.surfaceCard,
              elevation: 0,
              title: Text('Incoming Clinical Requests', style: AppTypography.screenTitle),
              bottom: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            body: appointmentNotifier.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildRequestList(context, pendingList, isPending: true),
                      _buildRequestList(context, upcomingList, isUpcoming: true),
                      _buildRequestList(context, completedList, isCompleted: true),
                    ],
                  ),
            bottomNavigationBar: VetBottomNavigation(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) context.go('/vet-dashboard');
                if (index == 1) context.go('/vet-requests');
                if (index == 2) context.go('/consultation-history');
                if (index == 3) context.go('/vet-outbreak-map');
                if (index == 4) context.go('/vet-profile');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestList(BuildContext context, List<AppointmentModel> list, {bool isPending = false, bool isUpcoming = false, bool isCompleted = false}) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => await appointmentNotifier.loadAppointments(),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            const Icon(Icons.inbox, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Center(
              child: Text('No requests in this section', style: AppTypography.sectionHeading.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => await appointmentNotifier.loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final app = list[index];
          return _buildRequestCard(context, app, isPending: isPending, isUpcoming: isUpcoming, isCompleted: isCompleted);
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, AppointmentModel app, {bool isPending = false, bool isUpcoming = false, bool isCompleted = false}) {
    final isCritical = app.visitType == VisitType.emergency;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCritical ? AppColors.alertCritical.withValues(alpha: 0.08) : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCritical ? AppColors.alertCritical : AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${app.animalName ?? "Animal"} (${app.species ?? "Livestock"})', style: AppTypography.cardTitle),
              if (isCritical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.alertCritical, borderRadius: BorderRadius.circular(12)),
                  child: Text('EMERGENCY', style: AppTypography.captionMetadata.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Farmer: ${app.farmerName ?? "Unknown"} ${app.farmerPhone != null ? "(${app.farmerPhone})" : ""}', style: AppTypography.captionMetadata),
          const SizedBox(height: 4),
          Text('Scheduled: ${app.appointmentDate} at ${app.appointmentTime}', style: AppTypography.captionMetadata.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Reason: ${app.reason}', style: AppTypography.bodyDefault),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/appointment-details', extra: app.id),
                  child: const Text('View Details'),
                ),
              ),
              if (isPending) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    onPressed: () async {
                      final ok = await appointmentNotifier.confirmAppointment(app.id);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Accepted!')));
                      }
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
