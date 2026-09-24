import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ponytail: no per-type switches. The server stores notification preferences but
// never checks them before sending, so a switch here would not stop anything.
// Add switches once the backend honours NotificationPreference when dispatching.
class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() => _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState extends State<NotificationPreferencesPage> {
  static const _settings = MethodChannel('app.vetra/settings');
  AuthorizationStatus? _status;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Re-check when the user comes back from the phone's notification settings.
    _lifecycle = AppLifecycleListener(onResume: _readStatus);
    _readStatus();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _readStatus() async {
    try {
      final s = await FirebaseMessaging.instance.getNotificationSettings();
      if (mounted) setState(() => _status = s.authorizationStatus);
    } catch (_) {}
  }

  Future<void> _allow() async {
    // Android stops showing the permission dialog once it has been denied; then the only
    // way is the app's notification settings.
    if (!await PushNotificationService.instance.requestPermissions()) {
      try {
        await _settings.invokeMethod('openNotificationSettings');
      } catch (_) {}
    }
    await PushNotificationService.instance.syncDeviceTokenWithBackend();
    await _readStatus();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = _status == AuthorizationStatus.authorized || _status == AuthorizationStatus.provisional;
    final isVet = authNotifier.currentRole == UserRole.veterinarian;
    final topics = isVet
        ? const [
            'Outbreak alerts when reports cluster into a possible outbreak',
            'Appointment requests, updates and chat messages',
            'Death reports assigned to you for review',
          ]
        : const [
            'AI scan results, and a vet\'s review of your scan',
            'Appointment updates and chat messages from your vet',
            'The vet\'s decision on a death report you filed',
          ];

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
          if (_status != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (allowed ? AppColors.primary : AppColors.alertCritical).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(allowed ? Icons.notifications_active : Icons.notifications_off,
                        color: allowed ? AppColors.primary : AppColors.alertCritical),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        allowed ? 'Notifications are on for this phone' : 'Notifications are off for this phone',
                        style: AppTypography.cardTitle,
                      ),
                    ),
                  ]),
                  if (!allowed) ...[
                    const SizedBox(height: 8),
                    Text('You will miss alerts until you allow them.', style: AppTypography.captionMetadata),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _allow, child: const Text('Allow notifications')),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 20),
          Text('You are notified about:', style: AppTypography.cardTitle),
          const SizedBox(height: 12),
          for (final item in topics)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('•  $item', style: AppTypography.bodyDefault),
            ),
          const SizedBox(height: 16),
          Text(
            'Choosing which of these you receive is not available in the app yet. '
            'To stop all PASHU SATHI notifications, turn them off in your phone\'s settings.',
            style: AppTypography.captionMetadata,
          ),
        ],
      ),
    );
  }
}
