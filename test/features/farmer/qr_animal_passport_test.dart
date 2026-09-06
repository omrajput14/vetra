import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/presentation/pages/animal_passport_page.dart';
import 'package:vetra/features/animal/presentation/pages/animal_passport_qr_updated_page.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/l10n/app_localizations.dart';

import 'package:vetra/features/animal/domain/repositories/animal_repository.dart';
import 'package:vetra/features/animal/data/models/animal_health_record_dto.dart';

class MockAnimalRepository implements AnimalRepository {
  @override
  Future<String> uploadAnimalPhoto(String animalId, String filePath) async => '';
  @override
  Future<void> deleteAnimalPhoto(String animalId) async {}
  List<AnimalHealthRecordModel> records = [];

  @override
  Future<List<AnimalHealthRecordModel>> getAnimalHealthRecords(String animalId) async => records;

  @override
  Future<AnimalHealthStatusModel> getLatestHealthStatus(String animalId) async => AnimalHealthStatusModel(
        animalId: animalId,
        status: 'HEALTHY',
        statusSummary: 'Healthy',
      );

  @override
  Future<AnimalHealthRecordModel> createHealthRecord(String animalId, Map<String, dynamic> body) async =>
      AnimalHealthRecordModel.fromJson(body);

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
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteAnimal(String id) async {}

  @override
  Future<AnimalModel> getAnimalById(String id) async => AnimalModel(
        id: id,
        farmerId: 'farmer-1',
        farmerName: 'Demo Farmer',
        animalName: 'hi',
        tagNumber: 'hi',
        qrCodeId: 'VTR-DD99E19B',
        species: 'BUFFALO',
        breed: 'Native',
        gender: 'MALE',
        createdAt: '',
        updatedAt: '',
      );

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
  }) async =>
      [];

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
  }) async =>
      throw UnimplementedError();
}

Widget _createTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  setUp(() {
    animalNotifier.setRepository(MockAnimalRepository());
  });
  final testAnimal = AnimalModel(
    id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    farmerId: 'farmer-uuid-1',
    farmerName: 'Demo Farmer',
    animalName: 'hi',
    tagNumber: 'hi',
    qrCodeId: 'VTR-DD99E19B',
    species: 'BUFFALO',
    breed: 'Native',
    gender: 'MALE',
    createdAt: '2026-08-25T10:00:00Z',
    updatedAt: '2026-08-25T10:00:00Z',
  );

  group('QR Animal Passport End-to-End Tests', () {
    testWidgets('AnimalPassportQrUpdatedPage renders QrImageView with real QR Code ID and metadata',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _createTestApp(
          AnimalPassportQrUpdatedPage(animal: testAnimal),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Digital Animal Passport'), findsOneWidget);
      expect(find.text('PASHU SATHI HEALTH PASSPORT'), findsOneWidget);

      // Verify QrImageView is present
      final qrFinder = find.byType(QrImageView);
      expect(qrFinder, findsOneWidget);

      // Verify Metadata
      expect(find.text('VTR-DD99E19B'), findsOneWidget);
      expect(find.text('hi'), findsNWidgets(2)); // Name and Tag
      expect(find.text('BUFFALO • Native'), findsOneWidget);
      expect(find.text('Demo Farmer'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    test('AnimalNotifier.lookupAnimalByQr resolves animal by qrCodeId and tagNumber', () async {
      // Seed test animal
      animalNotifier.animals.clear();
      animalNotifier.animals.add(testAnimal);

      // 1. Lookup by QR Code ID
      final byQr = await animalNotifier.lookupAnimalByQr('VTR-DD99E19B');
      expect(byQr, isNotNull);
      expect(byQr!.id, equals(testAnimal.id));
      expect(byQr.tagNumber, equals('hi'));

      // 2. Lookup by Tag Number
      final byTag = await animalNotifier.lookupAnimalByQr('hi');
      expect(byTag, isNotNull);
      expect(byTag!.qrCodeId, equals('VTR-DD99E19B'));

      // 3. Lookup by direct UUID
      final byId = await animalNotifier.lookupAnimalByQr('f47ac10b-58cc-4372-a567-0e02b2c3d479');
      expect(byId, isNotNull);
      expect(byId!.animalName, equals('hi'));

      // 4. Invalid lookup
      final invalid = await animalNotifier.lookupAnimalByQr('NON-EXISTENT-TAG-999');
      expect(invalid, isNull);
    });

    testWidgets('AnimalPassportPage renders with clickable QR PASS button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      animalNotifier.animals.clear();
      animalNotifier.animals.add(testAnimal);

      await tester.pumpWidget(
        _createTestApp(
          AnimalPassportPage(animalId: testAnimal.id),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Passport details
      expect(find.text('Digital Animal Passport'), findsOneWidget);
      expect(find.text('hi'), findsNWidgets(2)); // Name and Tag
      expect(find.text('QR PASS'), findsOneWidget);
      expect(find.text('VTR-DD99E19B'), findsOneWidget);
      expect(find.text('Native'), findsWidgets);
      expect(find.text('Demo Farmer'), findsOneWidget);
    });
  });
}
