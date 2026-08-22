import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/design_system/cards/vet_card.dart';
import 'package:vetra/core/services/call_service.dart';
import 'package:vetra/l10n/app_localizations.dart';

Widget createTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
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
    home: Scaffold(body: child),
  );
}

void main() {
  group('VetCard Widget Tests', () {
    testWidgets('renders verified vet information, badge and dual action buttons in English', (tester) async {
      bool callTapped = false;
      bool bookTapped = false;

      await tester.pumpWidget(
        createTestApp(
          child: VetCard(
            name: 'Dr. Ananya Roy',
            designation: 'Bovine Medicine • Roy Animal Hospital',
            rating: 5.0,
            phoneNumber: '+919876543210',
            emergencyAvailable: true,
            isVerified: true,
            onCallTap: () => callTapped = true,
            onBookTap: () => bookTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Ananya Roy'), findsOneWidget);
      expect(find.text('Verified Veterinarian'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Bovine Medicine • Roy Animal Hospital'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('Emergency Available'), findsOneWidget);
      expect(find.text('Call Vet'), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);

      await tester.tap(find.text('Call Vet'));
      expect(callTapped, isTrue);

      await tester.tap(find.text('Book Appointment'));
      expect(bookTapped, isTrue);
    });

    testWidgets('renders Verified Veterinarian badge in Hindi localization correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          locale: const Locale('hi'),
          child: const VetCard(
            name: 'डॉ. अनन्या रॉय',
            designation: 'बोवाइन मेडिसिन • रॉय एनिमल हॉस्पिटल',
            rating: 5.0,
            phoneNumber: '+919876543210',
            emergencyAvailable: true,
            isVerified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('डॉ. अनन्या रॉय'), findsOneWidget);
      expect(find.text('प्रमाणित पशु चिकित्सक'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('आपातकालीन सेवा उपलब्ध'), findsOneWidget);
      expect(find.text('पशु चिकित्सक को कॉल करें'), findsOneWidget);
      expect(find.text('अपॉइंटमेंट बुक करें'), findsOneWidget);
    });

    testWidgets('renders Verified Veterinarian badge in Marathi localization correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          locale: const Locale('mr'),
          child: const VetCard(
            name: 'डॉ. अनन्या रॉय',
            designation: 'बोव्हाइन मेडिसिन • रॉय ॲनिमल हॉस्पिटल',
            rating: 5.0,
            phoneNumber: '+919876543210',
            emergencyAvailable: true,
            isVerified: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('डॉ. अनन्या रॉय'), findsOneWidget);
      expect(find.text('प्रमाणित पशुवैद्यक'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('तातडीची सेवा उपलब्ध'), findsOneWidget);
      expect(find.text('पशुवैद्यकांना कॉल करा'), findsOneWidget);
      expect(find.text('तपासणी बुक करा'), findsOneWidget);
    });

    testWidgets('handleCall displays error snackbar when phone number is unavailable', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  final l10n = AppLocalizations.of(context);
                  CallService.instance.handleCall(context, null, l10n: l10n);
                },
                child: const Text('Test Trigger'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Trigger'));
      await tester.pump(); // trigger snackbar

      expect(find.text('Contact unavailable'), findsOneWidget);
    });
  });
}
