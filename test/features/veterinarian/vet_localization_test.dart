import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/features/veterinarian/presentation/pages/vet_dashboard_page.dart';
import 'package:vetra/features/veterinarian/presentation/pages/vet_requests_page.dart';
import 'package:vetra/features/veterinarian/presentation/pages/vet_verification_page.dart';
import 'package:vetra/features/profile/presentation/pages/vet_profile_page.dart';
import 'package:vetra/features/medical/presentation/pages/diagnosis_entry_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

Widget createLocalizedVetTestWidget({
  Key? key,
  required Widget child,
  Locale initialLocale = const Locale('en'),
}) {
  return ProviderScope(
    key: key,
    overrides: [
      localeProvider.overrideWith((ref) => LocaleNotifier(initialLocale: initialLocale)),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final locale = ref.watch(localeProvider);
        return MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('mr'),
          ],
          home: child,
        );
      },
    ),
  );
}

void main() {
  group('Vet Module Localization Tests', () {
    testWidgets('VetDashboardPage renders in English', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetDashboardPage(),
          initialLocale: const Locale('en'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Surveillance Animals'), findsOneWidget);
      expect(find.text('Pending Requests'), findsWidgets);
      expect(find.text('Quick Clinical Actions'), findsOneWidget);
      expect(find.text('Scan Animal QR'), findsOneWidget);
      expect(find.text('Diagnosis Entry'), findsOneWidget);
    });

    testWidgets('VetDashboardPage renders in Hindi (हिंदी)', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetDashboardPage(),
          initialLocale: const Locale('hi'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('पशुचिकित्सक डैशबोर्ड'), findsWidgets);
      expect(find.text('निगरानी वाले पशु'), findsOneWidget);
      expect(find.text('लंबित अनुरोध'), findsWidgets);
      expect(find.text('त्वरित नैदानिक क्रियाएँ'), findsOneWidget);
      expect(find.text('पशु QR स्कैन करें'), findsOneWidget);
      expect(find.text('निदान प्रविष्टि'), findsOneWidget);
    });

    testWidgets('VetDashboardPage renders in Marathi (मराठी)', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetDashboardPage(),
          initialLocale: const Locale('mr'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('पशुवैद्यकीय डॅशबोर्ड'), findsWidgets);
      expect(find.text('निगराणीखालील जनावरे'), findsOneWidget);
      expect(find.text('प्रलंबित विनंत्या'), findsWidgets);
      expect(find.text('जलद नैदानिक कृती'), findsOneWidget);
      expect(find.text('जनावर QR स्कॅन करा'), findsOneWidget);
      expect(find.text('निदान नोंदणी'), findsOneWidget);
    });

    testWidgets('VetRequestsPage renders localized tabs in Marathi', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetRequestsPage(),
          initialLocale: const Locale('mr'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('येणाऱ्या नैदानिक विनंत्या'), findsOneWidget);
      expect(find.text('प्रलंबित'), findsOneWidget);
      expect(find.text('आगामी'), findsOneWidget);
      expect(find.text('पूर्ण'), findsOneWidget);
    });

    testWidgets('VetRequestsPage renders localized tabs in Hindi', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetRequestsPage(),
          initialLocale: const Locale('hi'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('आने वाले नैदानिक अनुरोध'), findsOneWidget);
      expect(find.text('लंबित'), findsOneWidget);
      expect(find.text('आगामी'), findsOneWidget);
      expect(find.text('पूर्ण'), findsOneWidget);
    });

    testWidgets('DiagnosisEntryPage renders in Marathi and English', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const DiagnosisEntryPage(),
          initialLocale: const Locale('mr'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('निदान नोंदणी'), findsOneWidget);
      expect(find.text('जतन करा'), findsOneWidget);
    });

    testWidgets('VetVerificationPage renders in Hindi', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetVerificationPage(),
          initialLocale: const Locale('hi'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('लाइसेंस सत्यापित'), findsOneWidget);
      expect(find.text('पशुचिकित्सक डैशबोर्ड पर जाएं'), findsOneWidget);
    });

    testWidgets('VetVerificationPage renders in Marathi', (tester) async {
      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetVerificationPage(),
          initialLocale: const Locale('mr'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('परवाना पडताळणी पूर्ण'), findsOneWidget);
      expect(find.text('पशुवैद्यकीय डॅशबोर्डवर जा'), findsOneWidget);
    });

    testWidgets('VetProfilePage renders localized sections in Marathi', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createLocalizedVetTestWidget(
          child: const VetProfilePage(),
          initialLocale: const Locale('mr'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('पशुवैद्यकीय प्रोफाईल'), findsOneWidget);
      expect(find.text('वैद्यकीय अधिकारी माहिती'), findsOneWidget);
      expect(find.text('पात्रता आणि पदव्या'), findsOneWidget);
      expect(find.text('थेट संपर्क'), findsOneWidget);
    });
  });
}
