import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

class NotificationPreferencesPage extends StatelessWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notification Preferences', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            activeTrackColor: AppColors.primary,
            title: Text('Outbreak Alerts', style: AppTypography.cardTitle.copyWith(fontSize: 16)),
            subtitle: Text('Receive immediate SMS/push for nearby disease reports', style: AppTypography.captionMetadata),
            value: true,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
