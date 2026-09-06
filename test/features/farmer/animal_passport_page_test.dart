import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/data/models/animal_health_record_dto.dart';
import 'package:vetra/features/animal/domain/repositories/animal_repository.dart';
import 'package:vetra/features/animal/presentation/pages/animal_passport_page.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/l10n/app_localizations.dart';

class MockAnimalRepository implements AnimalRepository {
  @override
  Future<String> uploadAnimalPhoto(String animalId, String filePath) async => '';
  @override
  Future<void> deleteAnimalPhoto(String animalId) async {}
  List<AnimalHealthRecordModel> records = [];

  @override
  Future<List<AnimalHealthRecordModel>> getAnimalHealthRecords(String animalId) async {
    return records;
  }

  @override
  Future<AnimalHealthStatusModel> getLatestHealthStatus(String animalId) async {
    return AnimalHealthStatusModel(
      animalId: animalId,
      status: records.isNotEmpty ? 'ATTENTION_REQUIRED' : 'HEALTHY',
      statusSummary: records.isNotEmpty ? 'Recent timeline events' : 'Healthy',
    );
  }

  @override
  Future<AnimalHealthRecordModel> createHealthRecord(String animalId, Map<String, dynamic> body) async {
    final record = AnimalHealthRecordModel.fromJson(body);
    records.insert(0, record);
    return record;
  }

  @override
  Future<AnimalModel> createAnimal({
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate, String? localPhotoPath,
    String? photoUrl,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteAnimal(String id) async {}

  @override
  Future<AnimalModel> getAnimalById(String id) async => throw UnimplementedError();

  @override
  Future<List<AnimalModel>> listAnimals() async => [];

  @override
  Future<List<AnimalModel>> searchAnimals({
    String? animalName,
    String? tagNumber,
    String? qrCodeId,
    String? species,
    String? breed,
    String? gender,
  }) async => [];

  @override
  Future<AnimalModel> updateAnimal({
    required String id,
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate, String? localPhotoPath,
    String? photoUrl,
  }) async => throw UnimplementedError();
}

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
    home: child,
  );
}

void main() {
  late MockAnimalRepository mockRepo;

  setUp(() {
    mockRepo = MockAnimalRepository();
    animalNotifier.setRepository(mockRepo);
    animalNotifier.animals.clear();
    animalNotifier.healthTimelines.clear();
    animalNotifier.healthStatuses.clear();
  });

  testWidgets('AnimalPassportPage renders identity card and empty timeline in English', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final animal = AnimalModel(
      id: 'a-101',
      farmerId: 'f-1',
      farmerName: 'Ramesh Patil',
      animalName: 'Gauri',
      tagNumber: 'MH-PUN-001',
      species: 'CATTLE',
      breed: 'Gir',
      gender: 'FEMALE',
      createdAt: '2026-01-01',
      updatedAt: '2026-01-01',
    );
    animalNotifier.animals.add(animal);

    await tester.pumpWidget(createTestApp(child: const AnimalPassportPage(animalId: 'a-101')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Digital Animal Passport'), findsOneWidget);
    expect(find.text('Gauri'), findsOneWidget);
    expect(find.textContaining('MH-PUN-001'), findsWidgets);
    expect(find.text('Gir'), findsWidgets);
    expect(find.text('QR PASS'), findsOneWidget);
    expect(find.text('Lifetime Health Timeline'), findsOneWidget);
    expect(find.text('No Health Records Yet'), findsOneWidget);
    expect(find.text('Ask AI Advisor'), findsOneWidget);
  });

  testWidgets('AnimalPassportPage renders populated health timeline', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final animal = AnimalModel(
      id: 'a-102',
      farmerId: 'f-1',
      farmerName: 'Ramesh Patil',
      animalName: 'Sundari',
      tagNumber: 'MH-NSK-102',
      species: 'CATTLE',
      breed: 'Sahiwal',
      gender: 'FEMALE',
      createdAt: '2026-01-01',
      updatedAt: '2026-01-01',
    );
    animalNotifier.animals.add(animal);

    final record = AnimalHealthRecordModel(
      id: 'r-1',
      animalId: 'a-102',
      recordType: 'VACCINATION',
      source: 'VETERINARIAN',
      title: 'Anthrax Spore Vaccine',
      treatment: '1ml Subcutaneously',
      veterinarianName: 'Dr. Ananya Roy',
      recordedAt: '2026-08-20T11:00:00Z',
    );
    mockRepo.records = [record];

    await tester.pumpWidget(createTestApp(child: const AnimalPassportPage(animalId: 'a-102')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Sundari'), findsOneWidget);
    expect(find.text('Anthrax Spore Vaccine'), findsOneWidget);
    expect(find.text('1ml Subcutaneously'), findsOneWidget);
    expect(find.text('Dr. Ananya Roy'), findsOneWidget);
  });
}
