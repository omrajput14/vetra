import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import 'auth_service.dart';

/// Unread count behind the bell badge, and a change signal for open notification lists.
class NotificationCenter extends ChangeNotifier {
  NotificationCenter._();
  static final NotificationCenter instance = NotificationCenter._();

  int _unread = 0;
  int get unread => _unread;

  /// GET /notifications/unread. Keeps the last count when the server can't be reached.
  Future<void> refresh() async {
    if (!AuthService.instance.isLoggedIn) return _set(0);
    try {
      final res = await ApiClient.instance.dio.get('/api/v1/notifications/unread');
      final count = (res.data['data']?['unreadCount'] as num?)?.toInt();
      if (count != null) _set(count);
    } catch (_) {}
  }

  Future<void> markRead(String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      await ApiClient.instance.dio.patch('/api/v1/notifications/$id/read');
    } catch (_) {}
    await refresh();
  }

  /// A push arrived while the app is open: open lists reload and the badge updates.
  void pushArrived() {
    notifyListeners();
    refresh();
  }

  void _set(int count) {
    if (count == _unread) return;
    _unread = count;
    notifyListeners();
  }
}

final notificationCenter = NotificationCenter.instance;
