// Push notifications, scan history and app lock working for real.
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vetra/core/models/user_model.dart';
import 'package:vetra/core/models/user_role.dart';
import 'package:vetra/core/network/api_client.dart';
import 'package:vetra/core/router/app_router.dart';
import 'package:vetra/core/services/auth_service.dart';
import 'package:vetra/core/services/notification_center.dart';
import 'package:vetra/core/services/push_notification_service.dart';
import 'package:vetra/core/storage/secure_storage_service.dart';
import 'package:vetra/core/widgets/app_lock.dart';
import 'package:vetra/features/ai/data/models/ai_scan_model.dart';
import 'package:vetra/features/ai/presentation/pages/scan_history_page.dart';
import 'package:vetra/features/settings/presentation/pages/notification_preferences_page.dart';
import 'package:vetra/features/shared/presentation/widgets/notification_bell.dart';

/// Answers Dio requests from a path → JSON map and records what was asked.
class _Server implements HttpClientAdapter {
  final Map<String, Object> answers;
  final requests = <String>[];
  _Server(this.answers);

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? body, Future<void>? cancel) async {
    requests.add('${o.method} ${o.path}');
    return ResponseBody.fromString(jsonEncode(answers[o.path] ?? {'data': null}), 200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  @override
  void close({bool force = false}) {}
}

AIScanModel _scan(String id, String status, {String? diagnosis, String createdAt = '2026-09-24T04:09:00Z'}) =>
    AIScanModel(id: id, animalId: 'a1', animalName: 'Kapila', imageUrl: '', status: status,
        diagnosis: diagnosis, confidenceScore: 0.82, createdAt: createdAt);

void signIn(UserRole role) =>
    AuthService.instance.setCurrentUser(UserModel(id: 'u1', name: 'Test', emailOrPhone: 't@x.in', role: role));

/// Lets real platform-channel futures (local_auth, storage) finish, then rebuilds.
Future<void> settleIo(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await t.pump();
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('Push notifications', () {
    test('every route the backend puts in a push opens a real screen', () {
      // Routes from NotificationEventListener / AppointmentNotificationHelper / AppointmentChatService.
      for (final route in [
        '/ai-history',
        '/outbreaks',
        '/appointment-details?id=b7e1',
        '/appointment-chat?id=b7e1',
      ]) {
        final match = AppRouter.router.configuration.findMatch(Uri.parse(route));
        expect(match.isError, isFalse, reason: '$route has no screen');
      }
    });

    testWidgets('a push that arrives while the app is open shows a banner with View', (t) async {
      await t.pumpWidget(MaterialApp(scaffoldMessengerKey: rootMessengerKey, home: const Scaffold()));
      showPushBanner(const RemoteMessage(
        notification: RemoteNotification(title: 'AI Diagnostic Scan Ready', body: 'Tap to review.'),
        data: {'route': '/ai-history'},
      ));
      await t.pump();
      expect(find.text('AI Diagnostic Scan Ready'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
    });

    test('a payload that names no screen reports false so the inbox shows the item itself', () {
      signIn(UserRole.farmer);
      expect(PushNotificationService.instance.openNotificationTarget({}), isFalse);
      // Death-report decisions for farmers have no screen of their own.
      expect(PushNotificationService.instance.openNotificationTarget({'mortalityEventId': 'm-1'}), isFalse);
    });

    testWidgets('the bell shows the server\'s unread count, and reading one refreshes it', (t) async {
      signIn(UserRole.farmer);
      final server = _Server({'/api/v1/notifications/unread': {'data': {'unreadCount': 3}}});
      ApiClient.instance.dio.httpClientAdapter = server;
      final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => const Scaffold(body: NotificationBell()))]);
      await t.pumpWidget(MaterialApp.router(routerConfig: router));
      await t.runAsync(() => notificationCenter.refresh());
      await t.pump();
      expect(find.text('3'), findsOneWidget);

      server.answers['/api/v1/notifications/unread'] = {'data': {'unreadCount': 2}};
      await t.runAsync(() => notificationCenter.markRead('n-1'));
      await t.pump();
      expect(server.requests, contains('PATCH /api/v1/notifications/n-1/read'));
      expect(find.text('2'), findsOneWidget);
      await t.pump(const Duration(minutes: 1)); // let Dio's timeout timers from initState expire
    });

    testWidgets('notification settings list what each role is actually sent', (t) async {
      signIn(UserRole.veterinarian);
      await t.pumpWidget(const MaterialApp(home: NotificationPreferencesPage()));
      expect(find.textContaining('Outbreak alerts'), findsOneWidget);
      expect(find.byType(Switch), findsNothing);

      signIn(UserRole.farmer);
      await t.pumpWidget(const MaterialApp(home: NotificationPreferencesPage(key: ValueKey('farmer'))));
      expect(find.textContaining('Outbreak alerts'), findsNothing);
      expect(find.textContaining('AI scan results'), findsOneWidget);
    });
  });

  group('Scan history', () {
    testWidgets('lists server scans and scans still waiting to upload, newest first', (t) async {
      await t.pumpWidget(MaterialApp(
        home: ScanHistoryPage(
          loadServer: () async => [_scan('s1', 'COMPLETED', diagnosis: 'Lumpy Skin Disease')],
          loadLocal: () async => [
            _scan('s1', 'COMPLETED', diagnosis: 'Lumpy Skin Disease'), // already uploaded: shown once
            _scan('local-2', 'PENDING_UPLOAD', createdAt: '2026-09-24T05:00:00Z'),
          ],
        ),
      ));
      await t.pumpAndSettle();
      expect(find.textContaining('Lumpy Skin Disease (82%)'), findsOneWidget);
      expect(find.textContaining('Waiting to upload'), findsOneWidget);
      final pendingY = t.getTopLeft(find.textContaining('Waiting to upload')).dy;
      final doneY = t.getTopLeft(find.textContaining('Lumpy Skin Disease')).dy;
      expect(pendingY, lessThan(doneY));
    });

    testWidgets('says so when the server cannot be reached and keeps the scans on this phone', (t) async {
      await t.pumpWidget(MaterialApp(
        home: ScanHistoryPage(
          loadServer: () async => throw Exception('No internet connection'),
          loadLocal: () async => [_scan('local-2', 'PENDING_UPLOAD')],
        ),
      ));
      await t.pumpAndSettle();
      expect(find.textContaining('Showing scans saved on this phone only'), findsOneWidget);
      expect(find.textContaining('Waiting to upload'), findsOneWidget);
    });
  });

  group('App lock', () {
    testWidgets('when on, the app is covered until the phone confirms it is the owner', (t) async {
      await t.runAsync(() => SecureStorageService.instance.setAppLockEnabled(true));
      await t.pumpWidget(const MaterialApp(home: AppLock(child: Text('DASHBOARD'))));
      await settleIo(t);
      await settleIo(t);
      // No fingerprint hardware in tests, so confirmation fails and the lock stays.
      expect(find.text('PASHU SATHI is locked'), findsOneWidget);
      expect(find.text('DASHBOARD').hitTestable(), findsNothing);
    });

    testWidgets('when off, nothing is in the way', (t) async {
      await t.runAsync(() => SecureStorageService.instance.setAppLockEnabled(false));
      await t.pumpWidget(const MaterialApp(home: AppLock(child: Text('DASHBOARD'))));
      await settleIo(t);
      expect(find.text('PASHU SATHI is locked'), findsNothing);
      expect(find.text('DASHBOARD').hitTestable(), findsOneWidget);
    });
  });
}
