import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design_system/app_theme.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VetraApp()));
}

class VetraApp extends ConsumerWidget {
  const VetraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Vetra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: activeLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: AppRouter.router,
    );
  }
}
