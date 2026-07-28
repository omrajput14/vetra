import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/design_system/buttons/primary_button.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
import 'package:vetra/core/models/user_role.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String? appointmentId;

  const AppointmentDetailsPage({super.key, this.appointmentId});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.appointmentId != null && widget.appointmentId!.isNotEmpty) {
        appointmentNotifier.getAppointmentById(widget.appointmentId!);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          if (appointmentNotifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final app = appointmentNotifier.selectedAppointment;
          if (app == null) {
            return Center(
              child: Text('Appointment details unavailable', style: AppTypography.bodyDefault),
            );
          }

          final isVet = authNotifier.currentRole == UserRole.veterinarian;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildStatusHeader(app),
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
              const SizedBox(height: 28),
              _buildActionButtons(context, app, isVet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(AppointmentModel app) {
    Color statusColor = AppColors.cautionAmber;
    if (app.status == AppointmentStatus.confirmed) statusColor = AppColors.primary;
    if (app.status == AppointmentStatus.completed) statusColor = Colors.green;
    if (app.status == AppointmentStatus.cancelled || app.status == AppointmentStatus.rejected) statusColor = AppColors.alertCritical;

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
          Icon(Icons.info_outline, color: statusColor),
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

  Widget _buildActionButtons(BuildContext context, AppointmentModel app, bool isVet) {
    if (app.status == AppointmentStatus.completed ||
        app.status == AppointmentStatus.cancelled ||
        app.status == AppointmentStatus.rejected) {
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
        return PrimaryButton(
          label: 'Complete Checkup & Add Notes',
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
