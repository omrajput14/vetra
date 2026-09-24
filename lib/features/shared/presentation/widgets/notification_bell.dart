import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/services/notification_center.dart';

/// App-bar bell with the server's unread count.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    notificationCenter.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notificationCenter,
      builder: (context, _) {
        final count = notificationCenter.unread;
        return IconButton(
          tooltip: count > 0 ? 'Notifications, $count unread' : 'Notifications',
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text(count > 99 ? '99+' : '$count'),
            child: Icon(count > 0 ? Icons.notifications_active : Icons.notifications_none,
                color: AppColors.textPrimary),
          ),
          onPressed: () => context.push('/notifications'),
        );
      },
    );
  }
}
