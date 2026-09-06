import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/ai/data/models/ai_scan_model.dart';
import 'package:vetra/features/ai/presentation/pages/scan_results_page.dart';
import 'package:vetra/features/ai/presentation/providers/ai_scan_provider.dart';
import 'package:vetra/features/disease/presentation/pages/disease_information_page.dart';
import 'package:vetra/features/disease/presentation/widgets/zoonotic_warning_banner.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('Feature 2: Zoonotic Disease Alert Styling Tests', () {
    testWidgets('Zoonotic disease (Rabies) displays distinct human health warning banner', (tester) async {
      aiScanNotifier.setLastScanResult(AIScanModel(
        id: 'scan-rabies',
        animalId: 'dog-01',
        imageUrl: 'http://example.com/dog.jpg',
        diagnosis: 'Rabies',
        severity: 'CRITICAL',
        status: 'COMPLETED',
      ));

      await tester.pumpWidget(createTestWidget(const ScanResultsPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ZoonoticWarningBanner), findsOneWidget);
      expect(find.text('ZOONOTIC / HUMAN HEALTH RISK'), findsOneWidget);
      expect(
        find.text('This disease may affect humans. Avoid direct contact and seek veterinary/public-health guidance.'),
        findsOneWidget,
      );
      expect(find.text('Public Health Advisory'), findsOneWidget);
    });

    testWidgets('Non-zoonotic disease (Foot and Mouth Disease) does NOT display zoonotic warning', (tester) async {
      aiScanNotifier.setLastScanResult(AIScanModel(
        id: 'scan-fmd',
        animalId: 'cow-01',
        imageUrl: 'http://example.com/cow.jpg',
        diagnosis: 'Foot and Mouth Disease',
        severity: 'HIGH',
        status: 'COMPLETED',
      ));

      await tester.pumpWidget(createTestWidget(const ScanResultsPage()));
      await tester.pumpAndSettle();

      expect(find.byType(ZoonoticWarningBanner), findsNothing);
      expect(find.text('ZOONOTIC / HUMAN HEALTH RISK'), findsNothing);
    });

    testWidgets('DiseaseInformationPage displays zoonotic banner for Anthrax', (tester) async {
      await tester.pumpWidget(createTestWidget(const DiseaseInformationPage(diseaseName: 'Anthrax')));
      await tester.pumpAndSettle();

      expect(find.byType(ZoonoticWarningBanner), findsOneWidget);
      expect(find.text('ZOONOTIC / HUMAN HEALTH RISK'), findsOneWidget);
    });

    testWidgets('Hindi and Marathi translations render correctly for zoonotic warning', (tester) async {
      // Hindi
      await tester.pumpWidget(createTestWidget(
        const ZoonoticWarningBanner(diseaseName: 'Rabies'),
        locale: const Locale('hi'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('ज़ूनोटिक / मानव स्वास्थ्य जोखिम'), findsOneWidget);
      expect(find.text('जन स्वास्थ्य परामर्श'), findsOneWidget);

      // Marathi
      await tester.pumpWidget(createTestWidget(
        const ZoonoticWarningBanner(diseaseName: 'Rabies'),
        locale: const Locale('mr'),
      ));
      await tester.pumpAndSettle();
      expect(find.text('झुनोटिक / मानवी आरोग्य धोका'), findsOneWidget);
      expect(find.text('सार्वजनिक आरोग्य सल्ला'), findsOneWidget);
    });
  });
}
