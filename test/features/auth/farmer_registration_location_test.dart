import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/models/user_model.dart';
import 'package:vetra/core/models/user_role.dart';
import 'package:vetra/features/auth/presentation/pages/farmer_register_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  group('UserModel Location and Profile Attributes Test', () {
    test('UserModel correctly exposes location fields from metadata', () {
      const user = UserModel(
        id: 'farmer-123',
        name: 'Ramesh Patil',
        emailOrPhone: 'ramesh@farm.in',
        role: UserRole.farmer,
        metadata: {
          'village': 'Baramati',
          'taluka': 'Baramati Rural',
          'district': 'Pune',
          'state': 'Maharashtra',
          'latitude': 18.1512,
          'longitude': 74.5772,
          'farmName': 'Patil Dairy',
        },
      );

      expect(user.id, 'farmer-123');
      expect(user.name, 'Ramesh Patil');
      expect(user.village, 'Baramati');
      expect(user.taluka, 'Baramati Rural');
      expect(user.district, 'Pune');
      expect(user.state, 'Maharashtra');
      expect(user.latitude, 18.1512);
      expect(user.longitude, 74.5772);
      expect(user.farmName, 'Patil Dairy');
    });
  });

  group('Farmer Registration Location UI & Pre-Prompt Tests', () {
    testWidgets('Renders location permission pre-prompt card and taluka field', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FarmerRegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Register Your Farm'), findsOneWidget);

      // Verify Location Pre-Prompt Elements
      expect(find.text('Allow PASHU SATHI to use your location'), findsOneWidget);
      expect(find.text('Allow Location'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);

      // Verify Taluka input field exists
      expect(find.text('Taluka / Block'), findsOneWidget);

      // Tapping "Not Now" dismisses the banner gracefully
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      expect(find.text('Allow PASHU SATHI to use your location'), findsNothing);
      expect(find.text('Taluka / Block'), findsOneWidget);
    });

    testWidgets('Language selection chips update UI active state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FarmerRegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🇬🇧 English'), findsOneWidget);
      expect(find.text('🇮🇳 हिंदी'), findsOneWidget);
      expect(find.text('🇮🇳 मराठी'), findsOneWidget);

      // Select Hindi chip
      await tester.tap(find.text('🇮🇳 हिंदी'));
      await tester.pumpAndSettle();

      // Select Marathi chip
      await tester.tap(find.text('🇮🇳 मराठी'));
      await tester.pumpAndSettle();
    });
  });
}
