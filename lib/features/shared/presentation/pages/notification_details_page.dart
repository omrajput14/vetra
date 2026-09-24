import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/models/notification.dart';

class NotificationDetailsPage extends StatelessWidget {
  final AppNotification? notification;

  const NotificationDetailsPage({super.key, this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notification', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: notification == null
          ? _buildMissingState(context)
          : _buildContent(notification!),
    );
  }

  Widget _buildMissingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_outlined,
                size: 48, color: AppColors.textMetadata),
            const SizedBox(height: 12),
            Text('Notification unavailable', style: AppTypography.cardTitle),
            const SizedBox(height: 6),
            Text(
              'This notification could not be loaded. It may have been deleted.',
              textAlign: TextAlign.center,
              style: AppTypography.captionMetadata,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppNotification notif) {
    final isHighPriority =
        notif.priority == 'HIGH' || notif.priority == 'CRITICAL';
    final priorityColor = notif.priority == 'CRITICAL'
        ? AppColors.alertCritical
        : AppColors.cautionAmber;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHighPriority)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                notif.priority!,
                style: AppTypography.captionMetadata.copyWith(
                  color: priorityColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          Text(notif.title, style: AppTypography.screenTitle),
          const SizedBox(height: 6),
          Text(
            notif.timestamp.toLocal().toString().split('.').first,
            style: AppTypography.captionMetadata,
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text(notif.message, style: AppTypography.bodyDefault),
        ],
      ),
    );
  }
}
