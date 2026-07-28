import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/farmer_bottom_navigation.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';

class FarmerAppointmentsPage extends StatefulWidget {
  const FarmerAppointmentsPage({super.key});

  @override
  State<FarmerAppointmentsPage> createState() => _FarmerAppointmentsPageState();
}

class _FarmerAppointmentsPageState extends State<FarmerAppointmentsPage> {
  String _selectedFilter = 'ALL';

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
        final allList = appointmentNotifier.appointments;
        final filteredList = allList.where((a) {
          if (_selectedFilter == 'PENDING') return a.status == AppointmentStatus.pending;
          if (_selectedFilter == 'CONFIRMED') return a.status == AppointmentStatus.confirmed;
          if (_selectedFilter == 'COMPLETED') return a.status == AppointmentStatus.completed;
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceCard,
            elevation: 0,
            title: Text('My Appointments', style: AppTypography.screenTitle),
          ),
          body: Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: appointmentNotifier.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async => await appointmentNotifier.loadAppointments(),
                        child: filteredList.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final app = filteredList[index];
                                  return _buildAppointmentCard(context, app);
                                },
                              ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_task, color: Colors.white),
            label: Text('Book Checkup', style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
            onPressed: () => context.push('/appointment-booking'),
          ),
          bottomNavigationBar: FarmerBottomNavigation(
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) context.go('/farmer-dashboard');
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

  Widget _buildFilterChips() {
    final filters = ['ALL', 'PENDING', 'CONFIRMED', 'COMPLETED'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = _selectedFilter == f;
          return ChoiceChip(
            label: Text(f, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceCard,
            onSelected: (val) {
              if (val) setState(() => _selectedFilter = f);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.calendar_month_outlined, size: 64, color: AppColors.textSecondary),
        const SizedBox(height: 16),
        Center(
          child: Text('No appointments found', style: AppTypography.sectionHeading.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('Request a veterinary checkup for your livestock anytime.', style: AppTypography.captionMetadata, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel app) {
    Color statusColor = AppColors.cautionAmber;
    if (app.status == AppointmentStatus.confirmed) statusColor = AppColors.primary;
    if (app.status == AppointmentStatus.completed) statusColor = Colors.green;
    if (app.status == AppointmentStatus.cancelled || app.status == AppointmentStatus.rejected) statusColor = AppColors.alertCritical;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.borderHairline)),
      color: AppColors.surfaceCard,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => context.push('/appointment-details', extra: app.id),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${app.animalName ?? "Animal"} (${app.tagNumber ?? "No Tag"})',
                style: AppTypography.cardTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(app.status.toDisplayString(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(app.veterinarianName ?? 'Veterinarian', style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('${app.appointmentDate} at ${app.appointmentTime}', style: AppTypography.captionMetadata),
                const Spacer(),
                Text(app.visitType.toDisplayString(), style: AppTypography.captionMetadata.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
