import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../network/api_client.dart';
import '../router/app_router.dart';
import 'auth_service.dart';
import 'notification_center.dart';

/// Top-level background handler for FCM messages when app is in background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('[FCM Background] messageId=${message.messageId} data=${message.data}');
  } catch (e) {
    debugPrint('[FCM Background Error] $e');
  }
}

/// Given to MaterialApp so a push can show a banner over whatever screen is open.
final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// In-app banner for a push that arrives while the app is open (Android shows nothing
/// on its own in that case). "View" opens the screen the push points at.
void showPushBanner(RemoteMessage message) {
  final title = message.notification?.title ?? message.data['title']?.toString() ?? 'PASHU SATHI Alert';
  final body = message.notification?.body ?? message.data['body']?.toString() ?? '';
  rootMessengerKey.currentState?.showSnackBar(SnackBar(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (body.isNotEmpty) Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    ),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: 'View',
      onPressed: () => PushNotificationService.instance.handleNotificationTap(message.data),
    ),
    duration: const Duration(seconds: 6),
  ));
}

/// Centralized singleton service for Firebase Cloud Messaging lifecycle,
/// device token registration, permission management, and deep-link routing.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onForegroundMessage => _foregroundMessageController.stream;

  /// Initializes Firebase and FCM listeners.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('[PushNotificationService] Firebase initialized successfully.');

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request notification permissions
      await requestPermissions();

      // Configure presentation options for foreground notifications
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('[FCM Token Refresh] token=$newToken');
        _fcmToken = newToken;
        syncDeviceTokenWithBackend();
      });

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('[FCM Foreground] title=${message.notification?.title} body=${message.notification?.body} data=${message.data}');
        _foregroundMessageController.add(message);
      });

      // Listen for notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('[FCM Notification Tap - Background] data=${message.data}');
        handleNotificationTap(message.data);
      });

      // Check if app was opened from terminated state by tapping notification
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM Notification Tap - Terminated] data=${initialMessage.data}');
        // Allow app router to initialize first
        Future.delayed(const Duration(milliseconds: 600), () {
          handleNotificationTap(initialMessage.data);
        });
      }

      // Obtain initial device token
      _fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM Initial Token] $_fcmToken');
    } catch (e) {
      debugPrint('[PushNotificationService Warning] Firebase init failed or running in mock environment: $e');
    }
  }

  /// Requests notification permissions for Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      debugPrint('[FCM Permission Status] status=${settings.authorizationStatus}');
      return granted;
    } catch (e) {
      debugPrint('[FCM Permission Error] $e');
      return false;
    }
  }

  /// Synchronizes active FCM registration token with the VETRA backend.
  Future<void> syncDeviceTokenWithBackend() async {
    try {
      if (_fcmToken == null && _isInitialized) {
        _fcmToken = await FirebaseMessaging.instance.getToken();
      }

      if (_fcmToken == null || _fcmToken!.isEmpty) {
        debugPrint('[FCM Token Sync] No token available to sync.');
        return;
      }

      if (!AuthService.instance.isLoggedIn) {
        debugPrint('[FCM Token Sync] User not authenticated yet. Will sync after login.');
        return;
      }

      final dio = ApiClient.instance.dio;
      final response = await dio.post(
        '/api/v1/notifications/devices/register',
        data: {
          'deviceToken': _fcmToken,
          'platform': 'ANDROID',
          'appVersion': '1.0.0',
        },
      );

      debugPrint('[FCM Token Sync Success] status=${response.statusCode}');
    } catch (e) {
      debugPrint('[FCM Token Sync Warning] Failed to register token with backend: $e');
    }
  }

  /// Deactivates device token on user logout.
  Future<void> deactivateTokenOnLogout() async {
    try {
      if (_fcmToken != null && _fcmToken!.isNotEmpty && AuthService.instance.isLoggedIn) {
        final dio = ApiClient.instance.dio;
        await dio.post(
          '/api/v1/notifications/devices/unregister',
          data: {
            'deviceToken': _fcmToken,
            'platform': 'ANDROID',
          },
        );
        debugPrint('[FCM Token Deactivated on Logout]');
      }
    } catch (e) {
      debugPrint('[FCM Token Deactivation Warning] $e');
    }
  }

  /// Tap on a push: marks it read and opens its screen, or the inbox if it names none.
  void handleNotificationTap(Map<String, dynamic> data) {
    try {
      notificationCenter.markRead(data['notificationId']?.toString());
      if (!openNotificationTarget(data)) AppRouter.router.push('/notifications');
    } catch (e) {
      debugPrint('[FCM Routing Error] Could not navigate to notification destination: $e');
    }
  }

  /// Opens the screen a notification payload points at (push data or an inbox item's
  /// payloadJson). Returns false when it points nowhere.
  bool openNotificationTarget(Map<String, dynamic> data) {
    String? id(String key) {
      final v = data[key]?.toString();
      return v == null || v.isEmpty ? null : v;
    }

    final route = id('route');
    final isVet = AuthService.instance.currentRole == UserRole.veterinarian;
    if (route != null) {
      AppRouter.router.push(route);
    } else if (id('appointmentId') != null) {
      AppRouter.router.push('/appointment-details', extra: id('appointmentId'));
    } else if (id('animalId') != null) {
      AppRouter.router.push('/animal-passport', extra: id('animalId'));
    } else if (id('outbreakId') != null) {
      AppRouter.router.push(isVet ? '/vet-outbreak-map' : '/outbreak-map');
    } else if (id('mortalityEventId') != null && isVet) {
      AppRouter.router.push('/vet-mortality-inbox');
    } else if (id('reportId') != null) {
      AppRouter.router.push('/disease-information');
    } else {
      return false;
    }
    return true;
  }
}
