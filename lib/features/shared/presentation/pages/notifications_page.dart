import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_typography.dart';
import '../../../../core/models/notification.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/notification_center.dart';
import '../../../../core/services/push_notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    notificationCenter.addListener(_reloadQuietly);
  }

  @override
  void dispose() {
    notificationCenter.removeListener(_reloadQuietly);
    super.dispose();
  }

  // A push arrived or an item was read: refresh without the full-screen spinner.
  void _reloadQuietly() => _fetchNotifications(quiet: true);

  Future<void> _open(AppNotification notif) async {
    notificationCenter.markRead(notif.status == 'READ' ? null : notif.id);
    Map<String, dynamic> payload = const {};
    try {
      payload = jsonDecode(notif.payloadJson ?? '') as Map<String, dynamic>;
    } catch (_) {}
    if (!PushNotificationService.instance.openNotificationTarget(payload)) {
      context.push('/notification-details', extra: notif);
    }
  }

  Future<void> _fetchNotifications({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final dio = ApiClient.instance.dio;
      final response = await dio.get('/api/v1/notifications');
      final data = response.data;

      List<dynamic> list = [];
      if (data is Map<String, dynamic> && data['data'] != null) {
        if (data['data'] is List) {
          list = data['data'] as List<dynamic>;
        } else if (data['data']['content'] != null && data['data']['content'] is List) {
          list = data['data']['content'] as List<dynamic>;
        }
      } else if (data is List) {
        list = data;
      }

      final parsed = list.map((item) => AppNotification.fromJson(item as Map<String, dynamic>)).toList();

      if (mounted) {
        setState(() {
          _notifications = parsed;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        title: Text('Notifications', style: AppTypography.screenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                        const SizedBox(height: 12),
                        Text('Could not load notifications', style: AppTypography.cardTitle),
                        const SizedBox(height: 6),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: AppTypography.captionMetadata),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchNotifications, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.notifications_none, size: 48, color: AppColors.textMetadata),
                            const SizedBox(height: 12),
                            Text('No notifications yet', style: AppTypography.cardTitle),
                            const SizedBox(height: 6),
                            Text(
                              'You will receive clinical alerts, appointment booking updates, and disease notices here.',
                              textAlign: TextAlign.center,
                              style: AppTypography.captionMetadata,
                            ),
                          ],
                        ),
                      ),
                    )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final notif = _notifications[idx];
                    final isHighPriority = notif.priority == 'HIGH' || notif.priority == 'CRITICAL';
                    final unread = notif.status != 'READ';

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isHighPriority ? AppColors.cautionAmber.withValues(alpha: 0.5) : AppColors.borderHairline,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      // Own Material so the tap ripple shows above the card colour.
                      child: Material(type: MaterialType.transparency, child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isHighPriority ? AppColors.cautionAmber : AppColors.primary).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isHighPriority ? Icons.warning_amber_rounded : Icons.notifications_active,
                            color: isHighPriority ? AppColors.cautionAmber : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          notif.title,
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 15,
                            fontWeight: unread ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notif.message, style: AppTypography.bodySmall),
                            const SizedBox(height: 6),
                            Text(
                              notif.timestamp.toLocal().toString().split('.').first,
                              style: AppTypography.captionMetadata.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        trailing: unread
                            ? Semantics(
                                label: 'Unread',
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                ),
                              )
                            : null,
                        onTap: () => _open(notif),
                      )),
                    );
                  },
                ),
    );
  }
}
