import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';

// ponytail: no per-type switches. The server stores notification preferences but
// never checks them before sending, so a switch here would not stop anything.
// Add switches once the backend honours NotificationPreference when dispatching.
class NotificationPreferencesPage extends StatelessWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notifications', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('PASHU SATHI sends push notifications about:', style: AppTypography.cardTitle),
          const SizedBox(height: 12),
          for (final item in const [
            'Disease outbreaks detected in your area',
            'Appointment updates and chat messages',
            'AI scan results and their review by a vet',
            'Death reports and their review by a vet',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('•  $item', style: AppTypography.bodyDefault),
            ),
          const SizedBox(height: 16),
          Text(
            'Choosing which of these you receive is not available in the app yet. '
            'To stop all PASHU SATHI notifications, open your phone\'s Settings → Apps → '
            'PASHU SATHI → Notifications.',
            style: AppTypography.captionMetadata,
          ),
        ],
      ),
    );
  }
}
