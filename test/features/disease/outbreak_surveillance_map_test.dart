import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/features/disease/data/models/disease_report_dto.dart';
import 'package:vetra/features/disease/data/models/outbreak_dto.dart';
import 'package:vetra/features/disease/domain/repositories/disease_repository.dart';
import 'package:vetra/features/disease/presentation/pages/nearby_outbreak_details_page.dart';
import 'package:vetra/features/disease/presentation/providers/outbreak_provider.dart';
import 'package:vetra/features/maps/presentation/pages/outbreak_map_page.dart';
import 'package:vetra/features/maps/presentation/pages/risk_zone_page.dart';
import 'package:vetra/features/veterinarian/presentation/pages/vet_outbreak_map_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

class MockOutbreakRepository implements DiseaseRepository {
  List<OutbreakModel> stubOutbreaks = [];
  OutbreakStatisticsModel stubStatistics = const OutbreakStatisticsModel(
    totalOutbreaks: 2,
    activeOutbreaks: 2,
    criticalOutbreaks: 1,
    highRiskOutbreaks: 1,
    totalAnimalsAffected: 12,
  );
  List<DiseaseReportModel> stubReports = [];
  bool shouldFail = false;

  @override
  Future<List<OutbreakModel>> listOutbreaks({String? status}) async {
    if (shouldFail) throw Exception('API connection timeout');
    return stubOutbreaks;
  }

  @override
  Future<OutbreakStatisticsModel> getOutbreakStatistics() async {
    if (shouldFail) throw Exception('API connection timeout');
    return stubStatistics;
  }

  @override
  Future<List<OutbreakModel>> getHighRiskOutbreaks() async {
    return stubOutbreaks.where((o) => o.riskScore == 'HIGH' || o.riskScore == 'CRITICAL').toList();
  }

  @override
  Future<OutbreakModel> getOutbreakById(String id) async {
    return stubOutbreaks.firstWhere((o) => o.id == id);
  }

  @override
  Future<List<DiseaseReportModel>> getReportsForOutbreak(String id) async {
    return stubReports;
  }

  @override
  Future<List<NearbyReportModel>> searchNearbyReports({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  }) async {
    return [];
  }

  @override
  Future<DiseaseReportModel> createDiseaseReport(CreateDiseaseReportDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<DiseaseReportModel> getDiseaseReport(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DiseaseReportModel>> listMyDiseaseReports({int page = 0, int size = 20}) async {
    return [];
  }
}

Widget _wrapWithApp(Widget child, {Locale locale = const Locale('en')}) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith((ref) => LocaleNotifier(initialLocale: locale)),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  group('Outbreak DTO & Serialization Tests', () {
    test('OutbreakModel parses valid JSON correctly with multi-signal breakdown', () {
      final json = {
        'id': 'outbreak-123',
        'diseaseName': 'Foot and Mouth Disease (FMD)',
        'severity': 'CRITICAL',
        'status': 'ACTIVE',
        'riskScore': 'CRITICAL',
        'centerLatitude': 18.5204,
        'centerLongitude': 73.8567,
        'radiusKm': 5.0,
        'affectedReportsCount': 7,
        'evaluationWindowHours': 48,
        'lastCaseReportedAt': '2026-08-28T12:00:00Z',
        'createdAt': '2026-08-28T08:00:00Z',
        'compositeRiskScore': 85,
        'riskBreakdown': {
          'clusterScore': 90.0,
          'weatherScore': 80.0,
          'historyScore': 75.0,
          'vaccinationGapScore': 70.0,
          'weatherTemperature': 28.5,
          'weatherHumidity': 82.0,
          'weatherPrecipitation': 5.2,
          'vaccinationCoveragePct': 30.0,
          'riskExplanation': 'High density and aerosol transmission risk.',
          'recommendedAction': 'Ring vaccination within 5km.',
        },
      };

      final model = OutbreakModel.fromJson(json);
      expect(model.id, 'outbreak-123');
      expect(model.diseaseName, 'Foot and Mouth Disease (FMD)');
      expect(model.riskScore, 'CRITICAL');
      expect(model.compositeRiskScore, 85);
      expect(model.riskBreakdown, isNotNull);
      expect(model.riskBreakdown!.clusterScore, 90.0);
      expect(model.riskBreakdown!.weatherTemperature, 28.5);
      expect(model.riskBreakdown!.vaccinationCoveragePct, 30.0);
      expect(model.riskBreakdown!.recommendedAction, 'Ring vaccination within 5km.');
    });

    test('OutbreakStatisticsModel parses valid JSON correctly', () {
      final json = {
        'totalOutbreaks': 5,
        'activeOutbreaks': 3,
        'criticalOutbreaks': 1,
        'highRiskOutbreaks': 2,
        'totalAnimalsAffected': 24,
      };

      final stats = OutbreakStatisticsModel.fromJson(json);
      expect(stats.totalOutbreaks, 5);
      expect(stats.activeOutbreaks, 3);
      expect(stats.criticalOutbreaks, 1);
      expect(stats.highRiskOutbreaks, 2);
      expect(stats.totalAnimalsAffected, 24);
    });
  });

  group('OutbreakNotifier State Management Tests', () {
    late MockOutbreakRepository mockRepo;
    late OutbreakNotifier notifier;

    setUp(() {
      mockRepo = MockOutbreakRepository();
      notifier = OutbreakNotifier(repository: mockRepo);
    });

    test('loadOutbreaks successfully populates state from repository', () async {
      mockRepo.stubOutbreaks = const [
        OutbreakModel(
          id: 'o1',
          diseaseName: 'Foot and Mouth Disease (FMD)',
          severity: 'CRITICAL',
          status: 'ACTIVE',
          riskScore: 'CRITICAL',
          centerLatitude: 18.5204,
          centerLongitude: 73.8567,
          radiusKm: 5.0,
          affectedReportsCount: 7,
          evaluationWindowHours: 24,
          compositeRiskScore: 82,
        ),
        OutbreakModel(
          id: 'o2',
          diseaseName: 'Lumpy Skin Disease (LSD)',
          severity: 'WARNING',
          status: 'ACTIVE',
          riskScore: 'MEDIUM',
          centerLatitude: 18.6000,
          centerLongitude: 73.9000,
          radiusKm: 3.0,
          affectedReportsCount: 5,
          evaluationWindowHours: 24,
          compositeRiskScore: 48,
        ),
      ];

      await notifier.loadOutbreaks();

      expect(notifier.outbreaks.length, 2);
      expect(notifier.statistics?.activeOutbreaks, 2);
      expect(notifier.errorMessage, isNull);
      expect(notifier.isLoading, isFalse);
    });

    test('filteredOutbreaks accurately filters by disease, risk, and status', () async {
      mockRepo.stubOutbreaks = const [
        OutbreakModel(
          id: 'o1',
          diseaseName: 'Foot and Mouth Disease',
          severity: 'CRITICAL',
          status: 'ACTIVE',
          riskScore: 'CRITICAL',
          centerLatitude: 18.5204,
          centerLongitude: 73.8567,
          radiusKm: 5.0,
          affectedReportsCount: 7,
          evaluationWindowHours: 24,
          compositeRiskScore: 85,
        ),
        OutbreakModel(
          id: 'o2',
          diseaseName: 'Lumpy Skin Disease',
          severity: 'WARNING',
          status: 'MONITORING',
          riskScore: 'MEDIUM',
          centerLatitude: 18.6000,
          centerLongitude: 73.9000,
          radiusKm: 3.0,
          affectedReportsCount: 5,
          evaluationWindowHours: 24,
          compositeRiskScore: 45,
        ),
      ];

      await notifier.loadOutbreaks();

      expect(notifier.filteredOutbreaks.length, 2);

      notifier.setDiseaseFilter('Foot and Mouth Disease');
      expect(notifier.filteredOutbreaks.length, 1);
      expect(notifier.filteredOutbreaks.first.id, 'o1');

      notifier.setDiseaseFilter('All Diseases');
      notifier.setRiskFilter('MEDIUM');
      expect(notifier.filteredOutbreaks.length, 1);
      expect(notifier.filteredOutbreaks.first.id, 'o2');

      notifier.setRiskFilter('All Risks');
      notifier.setStatusFilter('MONITORING');
      expect(notifier.filteredOutbreaks.length, 1);
      expect(notifier.filteredOutbreaks.first.id, 'o2');
    });

    test('handles API errors without mock fallback', () async {
      mockRepo.shouldFail = true;
      await notifier.loadOutbreaks();

      expect(notifier.outbreaks.isEmpty, isTrue);
      expect(notifier.errorMessage, isNotNull);
    });
  });

  group('Veterinarian Surveillance Map Widget Tests', () {
    late MockOutbreakRepository mockRepo;

    setUp(() async {
      mockRepo = MockOutbreakRepository();
      mockRepo.stubOutbreaks = const [
        OutbreakModel(
          id: 'o1',
          diseaseName: 'Foot and Mouth Disease',
          severity: 'CRITICAL',
          status: 'ACTIVE',
          riskScore: 'CRITICAL',
          centerLatitude: 18.5204,
          centerLongitude: 73.8567,
          radiusKm: 5.0,
          affectedReportsCount: 7,
          evaluationWindowHours: 24,
          compositeRiskScore: 88,
        ),
      ];
      outbreakNotifier.setRepository(mockRepo);
      await outbreakNotifier.loadOutbreaks();
    });

    testWidgets('VetOutbreakMapPage renders map interface and live metrics', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const VetOutbreakMapPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Outbreak Surveillance Map'), findsOneWidget);
      expect(find.text('Active Clusters'), findsOneWidget);
      expect(find.text('Critical'), findsOneWidget);
      expect(find.text('Affected Cases'), findsOneWidget);

      expect(find.text('All Diseases'), findsOneWidget);
      expect(find.text('All Risks'), findsOneWidget);
      expect(find.text('All Statuses'), findsOneWidget);
    });

    testWidgets('VetOutbreakMapPage shows empty banner when no outbreaks match filter', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const VetOutbreakMapPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      outbreakNotifier.setDiseaseFilter('Non-Existent Disease');
      await tester.pump();

      expect(find.text('No Active Outbreak Clusters'), findsOneWidget);
    });
  });

  group('Farmer Outbreak Map Widget Tests', () {
    late MockOutbreakRepository mockRepo;

    setUp(() async {
      mockRepo = MockOutbreakRepository();
      mockRepo.stubOutbreaks = const [
        OutbreakModel(
          id: 'o1',
          diseaseName: 'Foot and Mouth Disease (FMD)',
          severity: 'CRITICAL',
          status: 'ACTIVE',
          riskScore: 'CRITICAL',
          centerLatitude: 18.5204,
          centerLongitude: 73.8567,
          radiusKm: 5.0,
          affectedReportsCount: 7,
          evaluationWindowHours: 24,
          compositeRiskScore: 82,
        ),
      ];
      outbreakNotifier.setRepository(mockRepo);
      await outbreakNotifier.loadOutbreaks();
    });

    testWidgets('OutbreakMapPage renders farmer operational view and alert banner', (tester) async {
      await tester.pumpWidget(_wrapWithApp(const OutbreakMapPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Nearby Outbreak Alerts'), findsOneWidget);
      expect(find.textContaining('Alert: Active Foot and Mouth Disease (FMD) Zone'), findsOneWidget);
      expect(find.text('Notice any symptoms?'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
    });
  });

  group('RiskZonePage & NearbyOutbreakDetailsPage Widget Tests', () {
    testWidgets('RiskZonePage renders high-risk outbreak details', (tester) async {
      const outbreak = OutbreakModel(
        id: 'o-crit',
        diseaseName: 'Anthrax Spore Cluster',
        severity: 'CRITICAL',
        status: 'ACTIVE',
        riskScore: 'CRITICAL',
        centerLatitude: 18.5204,
        centerLongitude: 73.8567,
        radiusKm: 10.0,
        affectedReportsCount: 4,
        evaluationWindowHours: 24,
        compositeRiskScore: 92,
      );

      await tester.pumpWidget(_wrapWithApp(const RiskZonePage(initialOutbreak: outbreak)));
      await tester.pumpAndSettle();

      expect(find.text('High Risk Surveillance Zones'), findsOneWidget);
      expect(find.text('Anthrax Spore Cluster'), findsOneWidget);
      expect(find.text('92 • CRITICAL'), findsOneWidget);
      expect(find.textContaining('Radius: 10.0 km Bio-containment Area'), findsOneWidget);
    });

    testWidgets('NearbyOutbreakDetailsPage renders complete outbreak parameters with multi-signal intelligence', (tester) async {
      const outbreak = OutbreakModel(
        id: 'o-det',
        diseaseName: 'Bovine Respiratory Syncytial',
        severity: 'WARNING',
        status: 'ACTIVE',
        riskScore: 'HIGH',
        centerLatitude: 18.5204,
        centerLongitude: 73.8567,
        radiusKm: 4.5,
        affectedReportsCount: 9,
        evaluationWindowHours: 48,
        compositeRiskScore: 72,
        riskBreakdown: RiskBreakdownModel(
          clusterScore: 75.0,
          weatherScore: 60.0,
          historyScore: 50.0,
          vaccinationGapScore: 80.0,
          riskExplanation: 'Dense herd grouping in cool moist environment.',
          recommendedAction: 'Enforce pasture separation and booster shots.',
        ),
      );

      await tester.pumpWidget(_wrapWithApp(const NearbyOutbreakDetailsPage(outbreak: outbreak)));
      await tester.pumpAndSettle();

      expect(find.text('Outbreak Zone Details'), findsOneWidget);
      expect(find.text('Bovine Respiratory Syncytial'), findsOneWidget);
      expect(find.text('72 • HIGH'), findsOneWidget);
      expect(find.text('MULTI-SIGNAL RISK INTELLIGENCE'), findsOneWidget);
      expect(find.text('Spatial Density (40%)'), findsOneWidget);
      expect(find.text('Weather Factors (20%)'), findsOneWidget);
      expect(find.text('Enforce pasture separation and booster shots.'), findsOneWidget);
      expect(find.text('4.5 km'), findsOneWidget);
      expect(find.text('9 Reports'), findsOneWidget);
      expect(find.text('48 Hours'), findsOneWidget);
    });
  });
}
