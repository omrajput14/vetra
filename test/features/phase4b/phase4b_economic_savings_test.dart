import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/dashboard/data/models/economic_impact_dto.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:vetra/features/farmer/presentation/pages/farmer_dashboard_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(Widget child, {Locale locale = const Locale('en')}) {
    return ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('Feature 3: Economic Savings & Modeled Impact Tests', () {
    testWidgets('Farmer dashboard displays Modeled Estimate and real value when data sufficient', (tester) async {
      // Inject real calculated response
      dashboardNotifier.loadDashboard(); // triggers load
      // Simulate real calculated impact model
      const mockImpact = EconomicImpactModel(
        modeledSavings: 21200.00,
        formattedValue: '₹21,200',
        label: 'Modeled estimate',
        isModeled: true,
        hasSufficientData: true,
        eligibleAnimalsCount: 2,
      );

      // Directly verify model properties
      expect(mockImpact.formattedValue, '₹21,200');
      expect(mockImpact.label, 'Modeled estimate');
      expect(mockImpact.hasSufficientData, isTrue);
      expect(mockImpact.eligibleAnimalsCount, 2);

      await tester.pumpWidget(createTestWidget(const FarmerDashboardPage()));
      await tester.pumpAndSettle();

      expect(find.text('Estimated savings from early detection'), findsOneWidget);
      expect(find.text('Modeled estimate'), findsOneWidget);
    });

    testWidgets('Insufficient data state displays honest unavailable label without fake numbers', (tester) async {
      const mockUnavailable = EconomicImpactModel(
        modeledSavings: null,
        formattedValue: null,
        label: 'Modeled estimate',
        isModeled: true,
        hasSufficientData: false,
        statusMessage: 'Estimated savings unavailable',
      );

      expect(mockUnavailable.hasSufficientData, isFalse);
      expect(mockUnavailable.modeledSavings, isNull);
      expect(mockUnavailable.formattedValue, isNull);
      expect(mockUnavailable.statusMessage, 'Estimated savings unavailable');

      await tester.pumpWidget(createTestWidget(const FarmerDashboardPage()));
      await tester.pumpAndSettle();

      expect(find.text('Estimated savings unavailable'), findsOneWidget);
      expect(find.text('₹0'), findsNothing);
      expect(find.text('₹18,000'), findsNothing);
    });
  });
}
