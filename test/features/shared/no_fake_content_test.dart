// Every screen here used to show invented data or a control that did nothing.
// Uses only default constructors so it also runs against the old code (BEFORE evidence).
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/domain/repositories/animal_repository.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:vetra/features/disease/presentation/pages/biosecurity_recommendations_page.dart';
import 'package:vetra/features/medical/presentation/pages/add_prescription_page.dart';
import 'package:vetra/features/medical/presentation/pages/add_treatment_page.dart';
import 'package:vetra/features/medical/presentation/pages/deworming_record_page.dart';
import 'package:vetra/features/medical/presentation/pages/vaccination_details_page.dart';
import 'package:vetra/features/medical/presentation/pages/vaccination_schedule_page.dart';
import 'package:vetra/features/profile/presentation/pages/vet_profile_page.dart';
import 'package:vetra/features/settings/presentation/pages/about_legal_page.dart';
import 'package:vetra/features/settings/presentation/pages/notification_preferences_page.dart';
import 'package:vetra/features/settings/presentation/pages/security_page.dart';
import 'package:vetra/features/shared/presentation/pages/search_results_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

class _NoAnimals extends Fake implements AnimalRepository {
  @override
  Future<List<AnimalModel>> listAnimals() async => [];
}

Future<void> _show(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: page,
    ),
  ));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() {
    animalNotifier.setRepository(_NoAnimals());
    PackageInfo.setMockInitialValues(
      appName: 'PASHU SATHI', packageName: 'app.vetra', version: '1.0.0', buildNumber: '1', buildSignature: '',
    );
  });

  group('Reachable screens', () {
    testWidgets('Security has no biometric switch that does nothing; it offers a real password change', (t) async {
      await _show(t, const SecurityPage());
      expect(find.text('Biometric Authentication'), findsNothing);
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Change Password'), findsWidgets);
    });

    testWidgets('Notifications has no switch the server ignores, and says how to turn them off', (t) async {
      await _show(t, const NotificationPreferencesPage());
      expect(find.byType(Switch), findsNothing);
      expect(find.textContaining('not available in the app yet'), findsOneWidget);
    });

    testWidgets('Forgot Password does not pretend to send a reset link', (t) async {
      await _show(t, const ForgotPasswordPage());
      expect(find.text('Send Reset Link'), findsNothing);
      expect(find.textContaining('not available in PASHU SATHI yet'), findsOneWidget);
    });

    testWidgets('About shows the installed version, team, disclaimer and licences', (t) async {
      await _show(t, const AboutLegalPage());
      await t.pumpAndSettle();
      expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
      expect(find.text('Team'), findsOneWidget);
      expect(find.text('Medical disclaimer'), findsOneWidget);
      expect(find.text('Open-source licences'), findsOneWidget);
    });

    testWidgets('Vet profile no longer labels the About page "Documents & Licenses"', (t) async {
      await _show(t, const VetProfilePage());
      expect(find.text('Documents & Licenses'), findsNothing);
      expect(find.text('Security Settings'), findsOneWidget);
    });
  });

  group('Unreachable screens from the audit', () {
    testWidgets('Search results show no invented animal', (t) async {
      await _show(t, const SearchResultsPage());
      expect(find.text('Bessie (NL-93842)'), findsNothing);
      expect(find.text('Holstein Cow • Healthy'), findsNothing);
    });

    testWidgets('Vaccination schedule shows no invented 2023 dose', (t) async {
      await _show(t, const VaccinationSchedulePage());
      expect(find.text('Anthrax Booster'), findsNothing);
      expect(find.text('Due: 15 Nov 2023'), findsNothing);
    });

    testWidgets('Vaccination details show no invented vaccine, batch or vet', (t) async {
      await _show(t, const VaccinationDetailsPage());
      expect(find.text('FMD Quadrivalent Vaccine'), findsNothing);
      expect(find.textContaining('VAX-2023-9904'), findsNothing);
      expect(find.textContaining('Dr. S. Patel'), findsNothing);
      expect(find.textContaining('12 Oct 2025'), findsNothing);
    });

    testWidgets('Deworming history shows no invented 2023 dose', (t) async {
      await _show(t, const DewormingRecordPage());
      expect(find.text('Albendazole Oral Drench'), findsNothing);
      expect(find.textContaining('15 Aug 2023'), findsNothing);
    });

    testWidgets('Biosecurity checklist names no invented pen or product', (t) async {
      await _show(t, const BiosecurityRecommendationsPage());
      expect(find.textContaining('Pen C'), findsNothing);
      expect(find.textContaining('Virkon'), findsNothing);
      expect(find.textContaining('Keep sick animals apart'), findsOneWidget);
    });

    testWidgets('Add Prescription without an animal offers no Save that discards input', (t) async {
      await _show(t, const AddPrescriptionPage());
      expect(find.text('Save Prescription'), findsNothing);
    });

    testWidgets('Record Treatment has no invented vet name', (t) async {
      await _show(t, const AddTreatmentPage());
      expect(find.textContaining('Dr. S. Patel'), findsNothing);
      expect(find.text('Submit Record'), findsNothing);
    });
  });
}
