import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/design_system/cards/vet_card.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
import 'package:vetra/features/farmer/presentation/pages/nearby_vets_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  testWidgets('NearbyVetsPage displays match context badges and verification pending badges correctly',
      (WidgetTester tester) async {
    // Seed authNotifier with sample discovered vets across hierarchy tiers
    authNotifier.setVetsList([
      {
        'id': 'vet-1',
        'name': 'Dr. Amit Patil',
        'specialization': 'Bovine Medicine',
        'clinic': 'Patil Veterinary Clinic',
        'phoneNumber': '+919876543210',
        'rating': 4.9,
        'emergencyAvailable': true,
        'verificationStatus': 'VERIFIED',
        'verified': true,
        'matchType': 'GPS_RADIUS',
        'distanceKm': 2.4,
      },
      {
        'id': 'vet-2',
        'name': 'Dr. Sneha Shinde',
        'specialization': 'Livestock Health',
        'clinic': 'Rural Vet Care',
        'phoneNumber': '+919876543211',
        'rating': 5.0,
        'emergencyAvailable': false,
        'verificationStatus': 'PENDING',
        'verified': false,
        'matchType': 'SAME_VILLAGE',
        'village': 'Baramati',
      },
    ]);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: NearbyVetsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify both vets appear
    expect(find.text('Dr. Amit Patil'), findsOneWidget);
    expect(find.text('Dr. Sneha Shinde'), findsOneWidget);

    // Verify explainable match badges
    expect(find.text('📍 2.4 km away'), findsOneWidget);
    expect(find.text('🏘️ Same village (Baramati)'), findsOneWidget);

    // Verify verification pending badge on the newly registered PENDING vet
    expect(find.text('Verification Pending'), findsOneWidget);

    // Verify emergency badge on Dr. Amit Patil
    expect(find.text('Emergency Available'), findsOneWidget);
  });

  testWidgets('VetCard renders matchTypeLabel and custom distance without breaking layout',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: VetCard(
            name: 'Dr. Ramesh Pawar',
            designation: 'Veterinary Officer • Taluka Hospital',
            matchTypeLabel: '📍 Same taluka (Haveli)',
            rating: 4.8,
            isVerified: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dr. Ramesh Pawar'), findsOneWidget);
    expect(find.text('📍 Same taluka (Haveli)'), findsOneWidget);
    expect(find.text('Verification Pending'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
  });
}
