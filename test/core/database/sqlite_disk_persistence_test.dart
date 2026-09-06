import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/database/vetra_database.dart';

void main() {
  late File diskDbFile;

  setUp(() {
    final tempDir = Directory.systemTemp.createTempSync('vetra_sqlite_test_');
    diskDbFile = File('${tempDir.path}/vetra_offline_db.sqlite');
  });

  tearDown(() {
    if (diskDbFile.existsSync()) {
      diskDbFile.parent.deleteSync(recursive: true);
    }
  });

  test('Real SQLite Disk File Persistence: Save data -> Kill app -> Restart -> Verify offline data', () async {
    // ═══════════════════════════════════════════════════════════════════════════
    // SESSION 1: Initial App Launch & Offline Data Creation
    // ═══════════════════════════════════════════════════════════════════════════
    debugPrint('--> Step 1: Starting Session 1 on physical SQLite file: ${diskDbFile.path}');
    final dbSession1 = VetraDatabase.forTesting(NativeDatabase(diskDbFile));

    // 1. Insert Animal offline
    const animalLocalId = 'animal-disk-uuid-001';
    await dbSession1.animalDao.insertAnimal(
      AnimalsTableCompanion(
        localId: const Value(animalLocalId),
        tagNumber: const Value('MH-12-TEST-7788'),
        animalName: const Value('Lakshmi'),
        species: const Value('CATTLE'),
        breed: const Value('Gir Cow'),
        gender: const Value('FEMALE'),
        farmerId: const Value('farmer-uuid-999'),
        syncStatus: const Value('localOnly'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // 2. Insert Disease Report referencing that animal offline
    const reportLocalId = 'report-disk-uuid-002';
    await dbSession1.diseaseReportDao.insertReport(
      DiseaseReportsTableCompanion(
        localId: const Value(reportLocalId),
        animalLocalId: const Value(animalLocalId),
        diseaseName: const Value('Foot and Mouth Disease (FMD)'),
        diagnosisStatus: const Value('SUSPECTED'),
        reportSource: const Value('MANUAL'),
        latitude: const Value(18.5204),
        longitude: const Value(73.8567),
        notes: const Value('Severe oral blisters observed'),
        syncStatus: const Value('pendingSync'),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // 3. Enqueue Offline Mutation Operation
    const opId = 'op-disk-uuid-003';
    await dbSession1.offlineOperationDao.enqueue(
      OfflineOperationsTableCompanion(
        operationId: const Value(opId),
        operationType: const Value('createAnimal'),
        entityType: const Value('animal'),
        entityLocalId: const Value(animalLocalId),
        payloadJson: const Value('{"tagNumber":"MH-12-TEST-7788"}'),
        status: const Value('pending'),
        retryCount: const Value(0),
        maxRetries: const Value(5),
        idempotencyKey: const Value(opId),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // Verify records exist in Session 1
    final animal1 = await dbSession1.animalDao.getByLocalId(animalLocalId);
    expect(animal1, isNotNull);
    expect(animal1!.animalName, equals('Lakshmi'));

    // ═══════════════════════════════════════════════════════════════════════════
    // SIMULATE APP TERMINATION / COLD KILL
    // ═══════════════════════════════════════════════════════════════════════════
    debugPrint('--> Step 2: Closing DB and killing app session...');
    await dbSession1.close();

    // Verify physical SQLite file exists on disk
    expect(diskDbFile.existsSync(), isTrue, reason: 'Physical SQLite file must exist on disk');
    debugPrint('--> SQLite file confirmed on disk. File size: ${diskDbFile.lengthSync()} bytes');

    // ═══════════════════════════════════════════════════════════════════════════
    // SESSION 2: Cold App Restart (New instance reading disk file)
    // ═══════════════════════════════════════════════════════════════════════════
    debugPrint('--> Step 3: Re-launching app (Session 2) from cold storage...');
    final dbSession2 = VetraDatabase.forTesting(NativeDatabase(diskDbFile));

    // 1. Verify Animal survived app restart
    final animalSession2 = await dbSession2.animalDao.getByLocalId(animalLocalId);
    expect(animalSession2, isNotNull);
    expect(animalSession2!.tagNumber, equals('MH-12-TEST-7788'));
    expect(animalSession2.animalName, equals('Lakshmi'));
    expect(animalSession2.species, equals('CATTLE'));
    expect(animalSession2.breed, equals('Gir Cow'));
    expect(animalSession2.syncStatus, equals('localOnly'));
    debugPrint('--> Verified: Animal [Lakshmi] successfully retrieved from disk SQLite.');

    // 2. Verify Disease Report survived app restart
    final reportSession2 = await dbSession2.diseaseReportDao.getByLocalId(reportLocalId);
    expect(reportSession2, isNotNull);
    expect(reportSession2!.diseaseName, equals('Foot and Mouth Disease (FMD)'));
    expect(reportSession2.latitude, equals(18.5204));
    expect(reportSession2.longitude, equals(73.8567));
    expect(reportSession2.animalLocalId, equals(animalLocalId));
    debugPrint('--> Verified: Disease Report [FMD] successfully retrieved from disk SQLite.');

    // 3. Verify Offline Operation Queue survived app restart
    final opSession2 = await dbSession2.offlineOperationDao.getById(opId);
    expect(opSession2, isNotNull);
    expect(opSession2!.operationType, equals('createAnimal'));
    expect(opSession2.entityLocalId, equals(animalLocalId));
    expect(opSession2.status, equals('pending'));
    debugPrint('--> Verified: Offline Operation Queue is durable and ready for sync.');

    await dbSession2.close();
    debugPrint('--> Step 4: All offline SQLite disk persistence checks PASSED.');
  });
}
