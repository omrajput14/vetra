// The "Estimated savings" card must fit a phone screen: it overflowed by 4.8 px on a
// Pixel 9 in English, and translations are longer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/farmer/presentation/pages/farmer_dashboard_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  for (final lang in ['en', 'hi', 'mr']) {
    testWidgets('farmer dashboard fits a Pixel 9 screen without overflow ($lang)', (t) async {
      t.view.physicalSize = const Size(1080, 2424);
      t.view.devicePixelRatio = 2.625;
      addTearDown(t.view.reset);

      await t.pumpWidget(ProviderScope(
        child: MaterialApp(
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FarmerDashboardPage(),
        ),
      ));
      await t.pumpAndSettle();

      expect(t.takeException(), isNull);
    });
  }
}
