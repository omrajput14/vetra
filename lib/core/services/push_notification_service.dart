import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../router/app_router.dart';
import 'auth_service.dart';

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

  /// Routes the user to the destination screen based on notification payload data.
  void handleNotificationTap(Map<String, dynamic> data) {
    try {
      final route = data['route']?.toString();
      final appointmentId = data['appointmentId']?.toString();
      final animalId = data['animalId']?.toString();
      final outbreakId = data['outbreakId']?.toString();
      final reportId = data['reportId']?.toString();

      if (route != null && route.isNotEmpty) {
        debugPrint('[FCM Deep-Link] Navigating to route: $route');
        AppRouter.router.push(route);
        return;
      }

      if (appointmentId != null && appointmentId.isNotEmpty) {
        debugPrint('[FCM Deep-Link] Navigating to appointment details: $appointmentId');
        AppRouter.router.push('/appointment-details', extra: appointmentId);
        return;
      }

      if (animalId != null && animalId.isNotEmpty) {
        debugPrint('[FCM Deep-Link] Navigating to animal passport: $animalId');
        AppRouter.router.push('/animal-passport', extra: animalId);
        return;
      }

      if (outbreakId != null && outbreakId.isNotEmpty) {
        debugPrint('[FCM Deep-Link] Navigating to outbreak map');
        AppRouter.router.push('/outbreak-map');
        return;
      }

      if (reportId != null && reportId.isNotEmpty) {
        debugPrint('[FCM Deep-Link] Navigating to disease information');
        AppRouter.router.push('/disease-information');
        return;
      }

      // Default fallback
      AppRouter.router.push('/notifications');
    } catch (e) {
      debugPrint('[FCM Routing Error] Could not navigate to notification destination: $e');
    }
  }
}
