import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/ai/data/models/ai_scan_model.dart';
import 'package:vetra/features/ai/presentation/pages/scan_results_page.dart';
import 'package:vetra/features/ai/presentation/providers/ai_scan_provider.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/shared/presentation/pages/appointment_booking_page.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
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

  group('Feature 1: Emergency AI Triage -> Book Vet Now Tests', () {
    testWidgets('EMERGENCY severity displays warning and BOOK VET NOW CTA', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      aiScanNotifier.setLastScanResult(AIScanModel(
        id: 'scan-001',
        animalId: 'cow-123',
        animalName: 'Gauri',
        imageUrl: 'http://example.com/cow.jpg',
        diagnosis: 'Acute Toxic Mastitis',
        severity: 'EMERGENCY',
        confidenceScore: 0.94,
        status: 'COMPLETED',
      ));

      await tester.pumpWidget(createTestWidget(const ScanResultsPage(
        extraData: {'animalId': 'cow-123'},
      )));
      await tester.pumpAndSettle();

      expect(find.text('Immediate veterinary attention recommended.'), findsOneWidget);
      expect(find.text('BOOK VET NOW'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('CRITICAL severity also triggers emergency warning and CTA', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      aiScanNotifier.setLastScanResult(AIScanModel(
        id: 'scan-002',
        animalId: 'cow-456',
        animalName: 'Lakshmi',
        imageUrl: 'http://example.com/cow2.jpg',
        diagnosis: 'Suspected Anthrax',
        severity: 'CRITICAL',
        confidenceScore: 0.98,
        status: 'COMPLETED',
      ));

      await tester.pumpWidget(createTestWidget(const ScanResultsPage(
        extraData: {'animalId': 'cow-456'},
      )));
      await tester.pumpAndSettle();

      expect(find.text('Immediate veterinary attention recommended.'), findsOneWidget);
      expect(find.text('BOOK VET NOW'), findsOneWidget);
    });

    testWidgets('Non-emergency (MILD/MODERATE) does NOT display emergency CTA', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      aiScanNotifier.setLastScanResult(AIScanModel(
        id: 'scan-003',
        animalId: 'cow-789',
        imageUrl: 'http://example.com/cow3.jpg',
        diagnosis: 'Mild Dermatitis',
        severity: 'MILD',
        confidenceScore: 0.82,
        status: 'COMPLETED',
      ));

      await tester.pumpWidget(createTestWidget(const ScanResultsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Immediate veterinary attention recommended.'), findsNothing);
      expect(find.text('BOOK VET NOW'), findsNothing);
      expect(find.text('Book Vet Consultation'), findsOneWidget);
    });

    testWidgets('Appointment booking displays honest unavailable state when no vets available', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      authNotifier.setVetsList([]); // No verified vets available nearby

      await tester.pumpWidget(createTestWidget(const AppointmentBookingPage(
        extraData: {
          'animalId': 'cow-123',
          'isEmergency': true,
          'visitType': VisitType.emergency,
          'reason': 'EMERGENCY AI TRIAGE: Acute Colic',
        },
      )));
      await tester.pumpAndSettle();

      expect(find.text('No verified veterinarians are currently available nearby.'), findsOneWidget);
      expect(find.text('Book Emergency Care'), findsOneWidget);
    });
  });
}
