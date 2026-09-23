import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/navigation/vet_bottom_navigation.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../appointment/data/models/appointment_dto.dart';
import '../../../appointment/presentation/providers/appointment_provider.dart';

class ClinicalSchedulePage extends StatefulWidget {
  final bool showBottomNav;

  /// Filter to open with, e.g. 'COMPLETED' when the vet came to record a diagnosis.
  final String? initialFilter;

  const ClinicalSchedulePage({super.key, this.showBottomNav = true, this.initialFilter});

  @override
  State<ClinicalSchedulePage> createState() => _ClinicalSchedulePageState();
}

class _ClinicalSchedulePageState extends State<ClinicalSchedulePage> {
  late String _selectedFilter = widget.initialFilter ?? 'ALL'; // 'ALL', 'TODAY', 'UPCOMING', 'COMPLETED', 'CANCELLED'
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appointmentNotifier.loadAppointments();
    });
  }

  Color _getStatusColor(AppointmentStatus status) => status.color;

  Color _getVisitTypeColor(VisitType type) {
    switch (type) {
      case VisitType.emergency:
        return AppColors.alertCritical;
      case VisitType.surgery:
        return Colors.purple;
      case VisitType.vaccination:
        return Colors.teal;
      case VisitType.pregnancy:
        return Colors.indigo;
      case VisitType.followUp:
        return Colors.blue;
      case VisitType.generalCheckup:
      case VisitType.other:
        return AppColors.primary;
    }
  }

  List<AppointmentModel> _filterAppointments(List<AppointmentModel> all) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    return all.where((a) {
      // 1. Date filter if user picked a calendar date
      if (_selectedDateFilter != null) {
        final dateFilterStr = DateFormat('yyyy-MM-dd').format(_selectedDateFilter!);
        if (a.appointmentDate != dateFilterStr) return false;
      }

      // 2. Segmented filter
      switch (_selectedFilter) {
        case 'TODAY':
          return a.appointmentDate == todayStr;
        case 'UPCOMING':
          return a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.pending;
        case 'COMPLETED':
          return a.status == AppointmentStatus.completed;
        case 'CANCELLED':
          return a.status == AppointmentStatus.cancelled || a.status == AppointmentStatus.rejected;
        case 'ALL':
        default:
          return true;
      }
    }).toList();
  }

  Map<String, List<AppointmentModel>> _groupByDate(List<AppointmentModel> list) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final tomorrowStr = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));

    final Map<String, List<AppointmentModel>> groups = {};

    // Sort list by date and time
    final sorted = List<AppointmentModel>.from(list)
      ..sort((a, b) {
        final cmpDate = a.appointmentDate.compareTo(b.appointmentDate);
        if (cmpDate != 0) return cmpDate;
        return a.appointmentTime.compareTo(b.appointmentTime);
      });

    for (final app in sorted) {
      String label;
      if (app.appointmentDate == todayStr) {
        label = 'Today';
      } else if (app.appointmentDate == tomorrowStr) {
        label = 'Tomorrow';
      } else {
        try {
          final dt = DateTime.parse(app.appointmentDate);
          label = DateFormat('EEEE, MMM d, yyyy').format(dt);
        } catch (_) {
          label = app.appointmentDate;
        }
      }

      groups.putIfAbsent(label, () => []).add(app);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text(l10n?.clinicalSchedule ?? 'My Clinical Schedule', style: AppTypography.screenTitle),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                tooltip: 'Back',
                onPressed: () => context.pop(),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              _selectedDateFilter == null ? Icons.calendar_month_outlined : Icons.event_available,
              color: _selectedDateFilter == null ? AppColors.textPrimary : AppColors.primary,
            ),
            tooltip: 'Filter by Date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDateFilter ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              setState(() => _selectedDateFilter = picked);
            },
          ),
          if (_selectedDateFilter != null)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.alertCritical, size: 20),
              tooltip: 'Clear Date Filter',
              onPressed: () => setState(() => _selectedDateFilter = null),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: 'Refresh Schedule',
            onPressed: () => appointmentNotifier.loadAppointments(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedBuilder(
        animation: appointmentNotifier,
        builder: (context, _) {
          // Loading State
          if (appointmentNotifier.isLoading && appointmentNotifier.appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('Loading your schedule...', style: AppTypography.bodyDefault),
                ],
              ),
            );
          }

          // Error State
          if (appointmentNotifier.errorMessage != null && appointmentNotifier.appointments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.alertCritical),
                    const SizedBox(height: 12),
                    Text('Unable to load your schedule.', style: AppTypography.sectionHeading),
                    const SizedBox(height: 6),
                    Text(
                      appointmentNotifier.errorMessage ?? 'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: AppTypography.captionMetadata,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () => appointmentNotifier.loadAppointments(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n?.retry ?? 'Retry'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ),
            );
          }

          final allAppointments = appointmentNotifier.appointments;
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final todayCount = allAppointments.where((a) => a.appointmentDate == todayStr).length;
          final upcomingCount = appointmentNotifier.upcomingAppointments.length + appointmentNotifier.pendingAppointments.length;
          final completedCount = appointmentNotifier.completedAppointments.length;
          final cancelledCount = allAppointments.where((a) => a.status == AppointmentStatus.cancelled || a.status == AppointmentStatus.rejected).length;

          final filteredList = _filterAppointments(allAppointments);
          final grouped = _groupByDate(filteredList);

          return RefreshIndicator(
            onRefresh: () async => await appointmentNotifier.loadAppointments(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Summary Workload Metrics Grid
                Row(
                  children: [
                    _buildMetricCard("Today's Visits", '$todayCount', AppColors.primary, Icons.today),
                    const SizedBox(width: 8),
                    _buildMetricCard("Upcoming", '$upcomingCount', Colors.blue, Icons.event),
                    const SizedBox(width: 8),
                    _buildMetricCard("Completed", '$completedCount', Colors.green, Icons.check_circle_outline),
                    const SizedBox(width: 8),
                    _buildMetricCard("Cancelled", '$cancelledCount', AppColors.textSecondary, Icons.cancel_outlined),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Filter Segment Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'All (${allAppointments.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('TODAY', "Today ($todayCount)"),
                      const SizedBox(width: 8),
                      _buildFilterChip('UPCOMING', "Upcoming ($upcomingCount)"),
                      const SizedBox(width: 8),
                      _buildFilterChip('COMPLETED', "Completed ($completedCount)"),
                      const SizedBox(width: 8),
                      _buildFilterChip('CANCELLED', "Cancelled ($cancelledCount)"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (_selectedDateFilter != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filtered by Date: ${DateFormat('MMM d, yyyy').format(_selectedDateFilter!)}',
                          style: AppTypography.captionMetadata.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          onTap: () => setState(() => _selectedDateFilter = null),
                          child: const Text('Reset', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Empty Schedule State
                if (filteredList.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_note_outlined, size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: 14),
                          Text('No appointments scheduled.', style: AppTypography.sectionHeading),
                          const SizedBox(height: 6),
                          Text(
                            _selectedDateFilter != null
                                ? 'No consultations found for the selected date.'
                                : 'No appointment cases found in this filter section.',
                            textAlign: TextAlign.center,
                            style: AppTypography.captionMetadata,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // 4. Chronological Grouped Appointment Cards
                  ...grouped.entries.map((entry) {
                    final dateLabel = entry.key;
                    final appts = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Text(dateLabel, style: AppTypography.sectionHeading.copyWith(fontSize: 16, color: AppColors.primary)),
                              const SizedBox(width: 8),
                              Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.3))),
                            ],
                          ),
                        ),
                        ...appts.map((appt) => _buildAppointmentCard(appt)),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNav
          ? VetBottomNavigation(
              currentIndex: 2,
              onTap: (index) {
                if (index == 0) context.go('/vet-dashboard');
                if (index == 1) context.go('/vet-requests');
                if (index == 2) context.go('/clinical-schedule');
                if (index == 3) context.go('/vet-outbreak-map');
                if (index == 4) context.go('/vet-profile');
              },
            )
          : null,
    );
  }

  Widget _buildMetricCard(String label, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(count, style: AppTypography.screenTitle.copyWith(fontSize: 18, color: color)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = key);
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel app) {
    final statusColor = _getStatusColor(app.status);
    final visitTypeColor = _getVisitTypeColor(app.visitType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/appointment-details', extra: app.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time & Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        app.appointmentTime.isNotEmpty ? app.appointmentTime.substring(0, 5) : 'Scheduled',
                        style: AppTypography.cardTitle.copyWith(fontSize: 15, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Visit Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: visitTypeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          app.visitType.toDisplayString(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: visitTypeColor),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          app.status.toDisplayString(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Animal & Farmer Identity
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pets, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${app.animalName ?? "Animal"} (${app.tagNumber ?? "No Tag"})',
                          style: AppTypography.cardTitle.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Species: ${app.species ?? "Livestock"} • Farmer: ${app.farmerName ?? "Registered Farmer"}',
                          style: AppTypography.captionMetadata,
                        ),
                        if (app.reason.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Reason: ${app.reason}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyDefault.copyWith(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/animal-passport', extra: app.animalId),
                    icon: const Icon(Icons.qr_code, size: 16, color: AppColors.primary),
                    label: const Text('Passport', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ),
                  Row(
                    children: [
                      if (app.status == AppointmentStatus.pending) ...[
                        OutlinedButton(
                          onPressed: () => appointmentNotifier.rejectAppointment(app.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.alertCritical,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Reject', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => appointmentNotifier.confirmAppointment(app.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Confirm', style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ] else if (app.status == AppointmentStatus.confirmed) ...[
                        ElevatedButton.icon(
                          onPressed: () => appointmentNotifier.completeAppointment(app.id),
                          icon: const Icon(Icons.check, size: 14, color: Colors.white),
                          label: const Text('Complete', style: TextStyle(fontSize: 12, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ] else ...[
                        TextButton.icon(
                          onPressed: () => context.push('/appointment-details', extra: app.id),
                          icon: const Icon(Icons.arrow_forward, size: 14, color: AppColors.textSecondary),
                          label: const Text('View Case', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
