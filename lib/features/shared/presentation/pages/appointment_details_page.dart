import '../../../../core/services/location_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
import 'package:vetra/core/models/user_role.dart';
import 'package:vetra/features/medical_record/presentation/providers/medical_record_provider.dart';
import 'package:vetra/features/veterinarian/presentation/pages/create_medical_record_page.dart';
import 'package:vetra/features/shared/presentation/pages/medical_record_details_page.dart';

class AppointmentDetailsPage extends ConsumerStatefulWidget {
  final String? appointmentId;

  const AppointmentDetailsPage({super.key, this.appointmentId});

  @override
  ConsumerState<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends ConsumerState<AppointmentDetailsPage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  AppointmentLiveLocationDto? _liveLocation;
  Timer? _liveLocationTimer;

  void _startLiveLocationPolling(String appointmentId) {
    _liveLocationTimer?.cancel();
    _fetchLiveLocation(appointmentId);
    _liveLocationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchLiveLocation(appointmentId);
    });
  }

  Future<void> _fetchLiveLocation(String appointmentId) async {
    final loc = await appointmentNotifier.getLiveLocation(appointmentId);
    if (mounted) {
      setState(() {
        _liveLocation = loc;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.appointmentId != null && widget.appointmentId!.isNotEmpty) {
        appointmentNotifier.getAppointmentById(widget.appointmentId!).then((_) {
          final app = appointmentNotifier.selectedAppointment;
          if (app != null) {
            ref.read(medicalRecordProvider.notifier).fetchRecordForAppointment(app.id);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _liveLocationTimer?.cancel();
    _notesController.dispose();
    _reasonController.dispose();
    appointmentNotifier.clearSelectedAppointment();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicalState = ref.watch(medicalRecordProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Appointment Details', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: appointmentNotifier,
        builder: (context, _) {
          final app = appointmentNotifier.selectedAppointment;
          if (appointmentNotifier.isLoading && (app == null || (widget.appointmentId != null && app.id != widget.appointmentId))) {
            return const Center(child: CircularProgressIndicator());
          }

          if (app == null || (widget.appointmentId != null && app.id != widget.appointmentId)) {
            return Center(
              child: Text('Appointment details unavailable', style: AppTypography.bodyDefault),
            );
          }

          final isVet = authNotifier.currentRole == UserRole.veterinarian;
          final existingRecord = medicalState.appointmentRecords[app.id];

          if (app.status == AppointmentStatus.enRoute && !isVet && _liveLocationTimer == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _liveLocationTimer == null) {
                _startLiveLocationPolling(app.id);
              }
            });
          } else if (app.status != AppointmentStatus.enRoute && _liveLocationTimer != null) {
            _liveLocationTimer?.cancel();
            _liveLocationTimer = null;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildStatusHeader(app),
              if (app.status == AppointmentStatus.enRoute || app.status == AppointmentStatus.arrived) ...[
                const SizedBox(height: 16),
                _buildLiveTrackingCard(app, isVet),
              ],
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Animal Details',
                icon: Icons.pets,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${app.animalName ?? "Animal"} (${app.tagNumber ?? "No Tag"})', style: AppTypography.cardTitle),
                    Text('Species: ${app.species ?? "N/A"}', style: AppTypography.captionMetadata),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Schedule & Purpose',
                icon: Icons.event,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${app.appointmentDate}', style: AppTypography.bodyDefault),
                    Text('Time: ${app.appointmentTime}', style: AppTypography.bodyDefault),
                    Text('Visit Type: ${app.visitType.toDisplayString()}', style: AppTypography.bodyDefault.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Reason:', style: AppTypography.captionMetadata),
                    Text(app.reason, style: AppTypography.bodyDefault),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: isVet ? 'Farmer Contact' : 'Veterinarian Clinic',
                icon: isVet ? Icons.person : Icons.local_hospital,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isVet ? (app.farmerName ?? 'Farmer') : (app.veterinarianName ?? 'Doctor'), style: AppTypography.cardTitle),
                    if (isVet && app.farmerPhone != null) Text('Phone: ${app.farmerPhone}', style: AppTypography.captionMetadata),
                    if (!isVet && app.clinicName != null) Text('Clinic: ${app.clinicName}', style: AppTypography.captionMetadata),
                  ],
                ),
              ),
              if (app.veterinarianNotes != null && app.veterinarianNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Veterinarian Consultation Notes',
                  icon: Icons.assignment,
                  content: Text(app.veterinarianNotes!, style: AppTypography.bodyDefault),
                ),
              ],
              if (app.cancellationReason != null && app.cancellationReason!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Cancellation / Rejection Reason',
                  icon: Icons.cancel,
                  content: Text(app.cancellationReason!, style: AppTypography.bodyDefault.copyWith(color: AppColors.alertCritical)),
                ),
              ],
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Consultation Chat & Instructions', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  context.push('/appointment-chat', extra: app.id);
                },
              ),
              const SizedBox(height: 16),
              _buildActionButtons(context, app, isVet, existingRecord),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(AppointmentModel app) {
    final statusColor = app.status.color;
    final statusIcon = app.status.icon;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Status: ${app.status.toDisplayString()}', style: AppTypography.cardTitle.copyWith(color: statusColor)),
          Icon(statusIcon, color: statusColor),
        ],
      ),
    );
  }

  Widget _buildLiveTrackingCard(AppointmentModel app, bool isVet) {
    if (app.status == AppointmentStatus.arrived) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVet ? "You have arrived on-site" : "Veterinarian has arrived!",
                    style: AppTypography.cardTitle.copyWith(color: Colors.teal, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isVet
                        ? "Location tracking ended. Ready to conduct clinical examination."
                        : "Dr. ${app.veterinarianName ?? "Veterinarian"} has reached your farm location.",
                    style: AppTypography.captionMetadata,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // EN_ROUTE state
    if (isVet) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.vetAccent, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_car, color: AppColors.vetAccent, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("En Route to Farm", style: AppTypography.cardTitle.copyWith(color: AppColors.vetAccent, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    "Foreground GPS is actively streaming your location to the farmer.",
                    style: AppTypography.captionMetadata,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Farmer view of EN_ROUTE:
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.vetAccent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car, color: AppColors.vetAccent, size: 22),
                  const SizedBox(width: 8),
                  Text("Doctor is En Route", style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text("LIVE", style: AppTypography.captionMetadata.copyWith(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dr. ${app.veterinarianName ?? "Veterinarian"}", style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                  if (_liveLocation != null && _liveLocation!.distanceKm != null)
                    Text(
                      "${_liveLocation!.distanceKm!.toStringAsFixed(1)} km away",
                      style: AppTypography.screenTitle.copyWith(fontSize: 22, color: AppColors.primary),
                    )
                  else
                    Text("Traveling to farm...", style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: "Refresh live location",
                onPressed: () => _fetchLiveLocation(app.id),
              ),
            ],
          ),
          if (_liveLocation?.updatedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Updated at: ${_liveLocation!.updatedAt!}",
                style: AppTypography.captionMetadata.copyWith(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget content}) {
    return Container(
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
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
            ],
          ),
          const Divider(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppointmentModel app, bool isVet, dynamic existingRecord) {
    if (app.status == AppointmentStatus.completed) {
      if (existingRecord != null) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B4D3E),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.assignment_turned_in),
          label: const Text('View Medical Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicalRecordDetailsPage(record: existingRecord),
              ),
            );
          },
        );
      } else if (isVet) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[800],
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.post_add),
          label: const Text('Create Medical Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: () async {
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => CreateMedicalRecordPage(appointment: app),
              ),
            );
            if (created == true) {
              ref.read(medicalRecordProvider.notifier).fetchRecordForAppointment(app.id);
            }
          },
        );
      }
      return const SizedBox.shrink();
    }

    if (app.status == AppointmentStatus.cancelled || app.status == AppointmentStatus.rejected) {
      return const SizedBox.shrink();
    }

    if (isVet) {
      if (app.status == AppointmentStatus.pending) {
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await appointmentNotifier.confirmAppointment(app.id);
                  if (ok) {
                    messenger.showSnackBar(const SnackBar(content: Text('Appointment Confirmed!')));
                  }
                },
                child: const Text('Accept Request'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.alertCritical),
                onPressed: () => _showRejectDialog(context, app.id),
                child: const Text('Reject'),
              ),
            ),
          ],
        );
      } else if (app.status == AppointmentStatus.confirmed) {
        return Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.directions_car),
              label: const Text('Start Travel (En Route)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await appointmentNotifier.startEnRoute(app.id);
                if (ok) {
                  LocationService.instance.startEnRouteTracking(app.id);
                  messenger.showSnackBar(const SnackBar(content: Text('En Route: Live location sharing active'), backgroundColor: Colors.teal));
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showCompleteDialog(context, app.id),
              child: const Text('Complete Checkup & Add Notes'),
            ),
          ],
        );
      } else if (app.status == AppointmentStatus.enRoute) {
        return Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.location_on),
              label: const Text('Mark Arrived (At Location)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await appointmentNotifier.markArrived(app.id);
                if (ok) {
                  LocationService.instance.stopEnRouteTracking();
                  messenger.showSnackBar(const SnackBar(content: Text('Arrival confirmed on-site!'), backgroundColor: Colors.teal));
                }
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showCompleteDialog(context, app.id),
              child: const Text('Complete Consultation'),
            ),
          ],
        );
      } else if (app.status == AppointmentStatus.arrived) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Complete Consultation & Add Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: () => _showCompleteDialog(context, app.id),
        );
      }
    } else {
      // Farmer actions
      return OutlinedButton(
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.alertCritical, side: const BorderSide(color: AppColors.alertCritical)),
        onPressed: () => _showCancelDialog(context, app.id),
        child: const Center(child: Text('Cancel Appointment')),
      );
    }

    return const SizedBox.shrink();
  }

  void _showCompleteDialog(BuildContext parentContext, String id) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete Consultation'),
        content: TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Enter clinical observations, treatment, or notes...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(parentContext);
              Navigator.pop(dialogContext);
              final ok = await appointmentNotifier.completeAppointment(id, notes: _notesController.text.trim());
              if (ok) {
                messenger.showSnackBar(const SnackBar(content: Text('Appointment Completed!'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Submit & Complete'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext parentContext, String id) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(hintText: 'Reason for rejection (optional)...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Back')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCritical),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(parentContext);
              Navigator.pop(dialogContext);
              final ok = await appointmentNotifier.rejectAppointment(id, reason: _reasonController.text.trim());
              if (ok) {
                messenger.showSnackBar(const SnackBar(content: Text('Appointment Rejected')));
              }
            },
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext parentContext, String id) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(hintText: 'Reason for cancellation...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Keep Appointment')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertCritical),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(parentContext);
              Navigator.pop(dialogContext);
              final ok = await appointmentNotifier.cancelAppointment(id, reason: _reasonController.text.trim());
              if (ok) {
                messenger.showSnackBar(const SnackBar(content: Text('Appointment Cancelled')));
              }
            },
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }
}
