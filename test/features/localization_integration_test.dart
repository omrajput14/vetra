import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/features/settings/presentation/pages/language_settings_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  testWidgets('LanguageSettingsPage switches language to Marathi and updates strings dynamically',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final activeLocale = ref.watch(localeProvider);
            return MaterialApp(
              locale: activeLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const LanguageSettingsPage(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial English strings
    expect(find.text('Language Settings'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('मराठी'), findsOneWidget);
    expect(find.text('हिंदी'), findsOneWidget);

    // Tap Marathi option
    await tester.tap(find.text('मराठी'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify UI switched to Marathi
    expect(find.text('भाषा निवडा'), findsOneWidget);

    // Tap Hindi option
    await tester.tap(find.text('हिंदी'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify UI switched to Hindi
    expect(find.text('भाषा सेटिंग्स'), findsOneWidget);
  });
}
