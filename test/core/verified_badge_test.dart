import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/design_system/badges/verified_badge.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget({required Locale locale, String? customLabel, bool compact = false}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Center(
          child: VerifiedBadge(
            customLabel: customLabel,
            compact: compact,
          ),
        ),
      ),
    );
  }

  group('VerifiedBadge Widget Tests', () {
    testWidgets('renders Verified Veterinarian badge in English', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Verified Veterinarian'), findsOneWidget);
    });

    testWidgets('renders Verified Veterinarian badge in Hindi', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('hi')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('प्रमाणित पशु चिकित्सक'), findsOneWidget);
    });

    testWidgets('renders Verified Veterinarian badge in Marathi', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('mr')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('प्रमाणित पशुवैद्यक'), findsOneWidget);
    });

    testWidgets('renders custom label when provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        locale: const Locale('en'),
        customLabel: 'Top Verified Specialist',
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Top Verified Specialist'), findsOneWidget);
    });
  });
}
