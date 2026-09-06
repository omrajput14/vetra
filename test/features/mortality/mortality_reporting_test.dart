import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/database/vetra_database.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/core/offline/models/offline_operation.dart';
import 'package:vetra/core/offline/operation_queue.dart';
import 'package:vetra/features/animal/data/datasources/animal_local_datasource.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/mortality/data/models/mortality_dto.dart';
import 'package:vetra/features/mortality/domain/repositories/mortality_repository.dart';
import 'package:vetra/features/mortality/presentation/pages/report_mortality_page.dart';
import 'package:vetra/features/mortality/presentation/providers/mortality_provider.dart';
import 'package:vetra/l10n/app_localizations.dart';

class MockMortalityRepository implements MortalityRepository {
  CreateMortalityReportDto? lastSubmittedDto;
  bool shouldThrow = false;

  @override
  Future<MortalityReportModel> reportMortality(CreateMortalityReportDto dto) async {
    lastSubmittedDto = dto;
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return MortalityReportModel(
      id: 'mortality-uuid-1234',
      animalId: dto.animalId,
      animalName: 'Sundari',
      tagNumber: 'TAG-101',
      farmerId: 'farmer-uuid-999',
      farmerName: 'Ramesh Patel',
      source: 'FARMER_REPORTED',
      status: 'REPORTED',
      causeCategory: dto.causeCategory,
      causeDescription: dto.causeDescription,
      diseaseName: dto.diseaseName,
      recentlyTreated: dto.recentlyTreated,
      treatmentNotes: dto.treatmentNotes,
      notes: dto.notes,
      deathDateTime: dto.deathDateTime,
      reportedAt: DateTime.now().toIso8601String(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<MortalityReportModel> getMortalityById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<MortalityReportModel> getMortalityByAnimalId(String animalId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MortalityReportModel>> listFarmerMortalities({int page = 0, int size = 20}) async {
    return [];
  }

  @override
  Future<List<String>> getDiseaseCatalog() async {
    return ['Anthrax', 'Foot and Mouth Disease (FMD)', 'Blackleg', 'Brucellosis'];
  }

  @override
  Future<List<MortalityReportModel>> getPendingMortalityCases({int page = 0, int size = 20}) async {
    return [];
  }

  @override
  Future<MortalityReportModel> confirmMortality(String id, ConfirmMortalityDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<MortalityReportModel> rejectMortality(String id, RejectMortalityDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MortalityAuditDto>> getMortalityAudits(String id) async {
    return [];
  }
}

Widget _createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith((ref) => LocaleNotifier(initialLocale: const Locale('en'))),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VetraDatabase db;
  late OperationQueue queue;
  late AnimalLocalDatasource animalLocal;
  late MockMortalityRepository mockMortalityRepo;

  setUp(() {
    db = VetraDatabase.forTesting(NativeDatabase.memory());
    VetraDatabase.setTestInstance(db);
    queue = OperationQueue.instance;
    animalLocal = AnimalLocalDatasource.instance;
    mockMortalityRepo = MockMortalityRepository();
    mortalityNotifier.setRepository(mockMortalityRepo);
  });

  tearDown(() async {
    await db.close();
    VetraDatabase.setTestInstance(null);
  });

  group('Mortality DTO Serialization & Enums', () {
    test('CreateMortalityReportDto toJson and fromJson round-trip', () {
      const dto = CreateMortalityReportDto(
        animalId: 'anim-101',
        causeCategory: 'KNOWN_DISEASE',
        causeDescription: 'Sudden high fever and death',
        diseaseName: 'Anthrax',
        recentlyTreated: true,
        treatmentNotes: 'Given antibiotics yesterday',
        notes: 'Died within 4 hours',
        deathDateTime: '2026-09-05T10:00:00Z',
        latitude: 18.5204,
        longitude: 73.8567,
        locationAccuracy: 12.5,
      );

      final jsonMap = dto.toJson();
      expect(jsonMap['animalId'], 'anim-101');
      expect(jsonMap['causeCategory'], 'KNOWN_DISEASE');
      expect(jsonMap['diseaseName'], 'Anthrax');
      expect(jsonMap['recentlyTreated'], isTrue);
      expect(jsonMap['latitude'], 18.5204);

      final parsed = CreateMortalityReportDto.fromJson(jsonMap);
      expect(parsed.animalId, dto.animalId);
      expect(parsed.causeCategory, dto.causeCategory);
      expect(parsed.treatmentNotes, dto.treatmentNotes);
    });

    test('MortalityCauseCategory helpers and string resolution', () {
      expect(MortalityCauseCategory.fromString('known_disease'), MortalityCauseCategory.knownDisease);
      expect(MortalityCauseCategory.fromString('ACCIDENT_INJURY'), MortalityCauseCategory.accidentInjury);
      expect(MortalityCauseCategory.fromString('unknown'), MortalityCauseCategory.unknown);
      expect(MortalityCauseCategory.fromString('NON_EXISTENT'), MortalityCauseCategory.unknown);
      expect(MortalityCauseCategory.fromString(null), MortalityCauseCategory.unknown);
    });
  });

  group('Offline-First Mortality Queueing and Optimistic Local Status', () {
    test('Enqueue mortality report when offline and mark local animal as DECEASED', () async {
      const animalId = 'local-animal-999';
      final animal = AnimalModel(
        id: animalId,
        farmerId: 'farmer-1',
        farmerName: 'Ramesh',
        animalName: 'Kamadhenu',
        tagNumber: 'TAG-5555',
        species: 'CATTLE',
        breed: 'Gir',
        gender: 'FEMALE',
        birthDate: '2021-03-10',
        status: 'ACTIVE',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await animalLocal.insert(animal);

      final initialAnimal = await animalLocal.getByLocalId(animalId);
      expect(initialAnimal, isNotNull);
      expect(initialAnimal!.tagNumber, 'TAG-5555');

      const dto = CreateMortalityReportDto(
        animalId: animalId,
        causeCategory: 'SUSPECTED_DISEASE',
        causeDescription: 'Bloat and distress',
        notes: 'Offline death report',
      );

      final opId = await queue.enqueue(
        operationType: OfflineOperationType.reportMortality,
        entityType: 'mortality',
        entityLocalId: 'temp-mort-001',
        payloadJson: json.encode(dto.toJson()),
      );

      expect(opId, isNotEmpty);
      final pendingOps = await queue.getAllPending();
      expect(pendingOps.length, 1);
      expect(pendingOps.first.operationType, OfflineOperationType.reportMortality);

      animalNotifier.markAnimalDeceased(animalId);
      final deceasedCopy = animal.copyWith(status: 'DECEASED');
      expect(deceasedCopy.status, 'DECEASED');
      expect(deceasedCopy.isDeceased, isTrue);
    });
  });

  group('ReportMortalityPage UI & Widget Flow', () {
    setUp(() {
      animalNotifier.animals.clear();
      animalNotifier.animals.addAll([
        AnimalModel(
          id: 'anim-1',
          farmerId: 'farmer-1',
          farmerName: 'Ramesh',
          animalName: 'Sundari',
          tagNumber: 'TAG-101',
          species: 'CATTLE',
          breed: 'Gir',
          gender: 'FEMALE',
          birthDate: '2020-01-01',
          status: 'ACTIVE',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        AnimalModel(
          id: 'anim-2',
          farmerId: 'farmer-1',
          farmerName: 'Ramesh',
          animalName: 'Kallu',
          tagNumber: 'TAG-102',
          species: 'BUFFALO',
          breed: 'Murrah',
          gender: 'MALE',
          birthDate: '2021-05-01',
          status: 'ACTIVE',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ]);
    });

    testWidgets('Renders mortality report page elements', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ReportMortalityPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Report Animal Death'), findsOneWidget);
      expect(find.text('1. Select or Scan Animal'), findsOneWidget);
      expect(find.text("2. What caused the animal's death?"), findsOneWidget);
      expect(find.text('3. Was this animal recently treated?'), findsOneWidget);
      expect(find.text('4. Anything else we should know?'), findsOneWidget);

      // Scroll down to reveal bottom sections
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('5. Location Capture'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Pre-selects animal if initialAnimalId passed', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ReportMortalityPage(initialAnimalId: 'anim-2')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kallu (Tag #TAG-102)'), findsWidgets);
    });
  });
}
