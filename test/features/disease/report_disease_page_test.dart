import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/disease/data/models/disease_report_dto.dart';
import 'package:vetra/features/disease/data/models/outbreak_dto.dart';
import 'package:vetra/features/disease/domain/repositories/disease_repository.dart';

import 'package:vetra/features/disease/presentation/pages/report_disease_page.dart';
import 'package:vetra/features/disease/presentation/providers/disease_report_provider.dart';
import 'package:vetra/l10n/app_localizations.dart';

class MockDiseaseRepository implements DiseaseRepository {
  CreateDiseaseReportDto? lastSubmittedDto;
  bool shouldFail = false;

  @override
  Future<DiseaseReportModel> createDiseaseReport(CreateDiseaseReportDto dto) async {
    lastSubmittedDto = dto;
    if (shouldFail) {
      throw Exception('Network connection failed');
    }
    return DiseaseReportModel(
      id: 'rep-uuid-12345678',
      animalId: dto.animalId,
      animalName: 'Sundari',
      tagNumber: 'TAG-101',
      reportedById: 'user-farmer-1',
      reportedByName: 'Ramesh',
      reportSource: dto.reportSource,
      diseaseName: dto.diseaseName,
      diagnosisStatus: dto.diagnosisStatus,
      latitude: dto.latitude,
      longitude: dto.longitude,
      notes: dto.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<DiseaseReportModel> getDiseaseReport(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DiseaseReportModel>> listMyDiseaseReports({int page = 0, int size = 20}) async {
    return [];
  }

  @override
  Future<List<OutbreakModel>> listOutbreaks({String? status}) async {
    return [];
  }

  @override
  Future<List<OutbreakModel>> getHighRiskOutbreaks() async {
    return [];
  }

  @override
  Future<OutbreakStatisticsModel> getOutbreakStatistics() async {
    return const OutbreakStatisticsModel(
      totalOutbreaks: 0,
      activeOutbreaks: 0,
      criticalOutbreaks: 0,
      highRiskOutbreaks: 0,
      totalAnimalsAffected: 0,
    );
  }

  @override
  Future<OutbreakModel> getOutbreakById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DiseaseReportModel>> getReportsForOutbreak(String id) async {
    return [];
  }

  @override
  Future<List<NearbyReportModel>> searchNearbyReports({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  }) async {
    return [];
  }
}

Widget _createTestApp(Widget child, {Locale locale = const Locale('en')}) {
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportDiseasePage UI & Surveillance Pipeline Tests', () {
    late MockDiseaseRepository mockRepository;

    setUp(() {
      mockRepository = MockDiseaseRepository();
      diseaseReportNotifier.setRepository(mockRepository);
      diseaseReportNotifier.setLocation(18.5204, 73.8567);

      animalNotifier.animals.clear();
      animalNotifier.animals.addAll([
        AnimalModel(
          id: 'animal-uuid-101',
          farmerId: 'farmer-1',
          farmerName: 'Ramesh',
          tagNumber: 'TAG-101',
          animalName: 'Sundari',
          species: 'BUFFALO',
          breed: 'Murrah',
          gender: 'FEMALE',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        AnimalModel(
          id: 'animal-uuid-102',
          farmerId: 'farmer-1',
          farmerName: 'Ramesh',
          tagNumber: 'TAG-102',
          animalName: 'Gauri',
          species: 'CATTLE',
          breed: 'Gir',
          gender: 'FEMALE',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ]);
    });

    testWidgets('Renders all report form sections in English',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ReportDiseasePage()));
      await tester.pumpAndSettle();

      // Headers & Notices
      expect(find.text('Report Health Issue'), findsOneWidget);
      expect(find.text('Disease Surveillance & Outbreak Detection'), findsOneWidget);
      expect(find.text('Rapid Disease Surveillance & Early Warning'), findsOneWidget);

      // Section titles
      expect(find.text('1. Select Affected Animal'), findsOneWidget);
      expect(find.text('2. Observed Symptoms'), findsOneWidget);
      expect(find.text('3. Suspected Condition'), findsOneWidget);
      expect(find.text('4. Additional Observations / Notes'), findsOneWidget);
      expect(find.text('5. Surveillance GPS Location'), findsOneWidget);

      // Dropdown with animal
      expect(find.text('Sundari (TAG-101)'), findsOneWidget);

      // Symptom chips
      expect(find.text('🌡️ High Fever'), findsOneWidget);
      expect(find.text('🍽️ Off-feed / Low Appetite'), findsOneWidget);
      expect(find.text('💧 Excess Salivation'), findsOneWidget);
      expect(find.text('🦿 Lameness / Limping'), findsOneWidget);

      // Location Card
      expect(find.text('GPS Location Captured'), findsOneWidget);
      expect(find.text('18.5204° N, 73.8567° E'), findsOneWidget);

      // Submit Button
      expect(find.text('Submit Disease Report'), findsOneWidget);
    });

    testWidgets('Renders ReportDiseasePage in Marathi',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(
        const ReportDiseasePage(),
        locale: const Locale('mr'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('रोग लक्षण नोंदवा'), findsOneWidget);
      expect(find.text('साथीचे रोग नियंत्रण व सर्वेक्षण'), findsOneWidget);
      expect(find.text('१. बाधित प्राणी निवडा'), findsOneWidget);
      expect(find.text('२. दिसून आलेली लक्षणे'), findsOneWidget);
      expect(find.text('३. संशयित आजार (प्राथमिक)'), findsOneWidget);
      expect(find.text('५. जीपीएस स्थान (साथरोग सर्वेक्षण)'), findsOneWidget);
      expect(find.text('रोग अहवाल सबमिट करा'), findsOneWidget);
    });

    testWidgets('Selecting symptoms and submitting creates report and displays success screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ReportDiseasePage()));
      await tester.pumpAndSettle();

      // Tap symptom chips
      await tester.tap(find.text('🌡️ High Fever'));
      await tester.pump();
      await tester.tap(find.text('💧 Excess Salivation'));
      await tester.pump();

      // Enter notes
      await tester.enterText(
        find.byType(TextField),
        'High temperature observed for 2 days. Excess drooling from mouth.',
      );
      await tester.pump();

      // Tap Submit
      await tester.tap(find.text('Submit Disease Report'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify payload sent to repository
      expect(mockRepository.lastSubmittedDto, isNotNull);
      expect(mockRepository.lastSubmittedDto!.animalId, 'animal-uuid-101');
      expect(mockRepository.lastSubmittedDto!.diagnosisStatus, 'SUSPECTED');
      expect(mockRepository.lastSubmittedDto!.reportSource, 'MANUAL');
      expect(mockRepository.lastSubmittedDto!.latitude, 18.5204);
      expect(mockRepository.lastSubmittedDto!.longitude, 73.8567);
      expect(mockRepository.lastSubmittedDto!.notes, contains('High Fever'));
      expect(mockRepository.lastSubmittedDto!.notes, contains('Excess Salivation'));
      expect(mockRepository.lastSubmittedDto!.notes, contains('Excess drooling from mouth.'));

      // Verify Success State rendered
      expect(find.text('Disease Report Submitted Successfully!'), findsOneWidget);
      expect(find.text('Report received by the VETRA Outbreak Detection Engine.'), findsOneWidget);
      expect(find.text('Saved on This Device — Not Yet Submitted'), findsNothing);
      expect(find.text('SUSPECTED'), findsOneWidget);
      expect(find.text('18.5204° N, 73.8567° E'), findsOneWidget);
      expect(find.text('Done / Return to Dashboard'), findsOneWidget);
    });

    testWidgets('Rejects submission if no symptoms and notes are empty',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ReportDiseasePage()));
      await tester.pumpAndSettle();

      // Submit without selecting symptoms
      await tester.tap(find.text('Submit Disease Report'));
      await tester.pump();

      expect(find.text('Please select observed symptoms or enter notes'), findsOneWidget);
      expect(mockRepository.lastSubmittedDto, isNull);
    });
  });
}
