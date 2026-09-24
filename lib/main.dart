import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design_system/app_theme.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_center.dart';
import 'core/services/push_notification_service.dart';
import 'core/widgets/app_lock.dart';
import 'core/database/vetra_database.dart';
import 'core/network/network_status_service.dart';
import 'core/offline/sync_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Open the local SQLite database (Drift)
  // This initialises the schema on first run and applies any pending migrations.
  final db = VetraDatabase.instance;
  // Reset any operations that were PROCESSING when the app last crashed.
  await db.offlineOperationDao.resetAllProcessing();

  // Start listening for network changes (connectivity_plus + health check).
  NetworkStatusService.instance.initialize();

  // Initialize offline sync service (triggers on connect and initial start)
  SyncService.instance.initialize();

  // Initialize Firebase and Push Notification Service
  await PushNotificationService.instance.initialize();

  runApp(const ProviderScope(child: VetraApp()));
}

class VetraApp extends ConsumerStatefulWidget {
  const VetraApp({super.key});

  @override
  ConsumerState<VetraApp> createState() => _VetraAppState();
}

class _VetraAppState extends ConsumerState<VetraApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        SyncService.instance.triggerSync();
        notificationCenter.refresh();
      },
    );
    PushNotificationService.instance.onForegroundMessage.listen((message) {
      notificationCenter.pushArrived();
      showPushBanner(message);
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'PASHU SATHI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: activeLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: AppRouter.router,
      scaffoldMessengerKey: rootMessengerKey,
      builder: (context, child) => AppLock(child: child ?? const SizedBox.shrink()),
    );
  }
}
