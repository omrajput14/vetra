import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/database/vetra_database.dart';
import 'package:vetra/core/offline/models/offline_operation.dart';
import 'package:vetra/core/offline/operation_queue.dart';
import 'package:vetra/features/animal/data/datasources/animal_local_datasource.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/disease/data/datasources/disease_report_local_datasource.dart';
import 'package:vetra/features/disease/data/models/disease_report_dto.dart';

void main() {
  late VetraDatabase db;
  late OperationQueue queue;
  late AnimalLocalDatasource animalLocal;
  late DiseaseReportLocalDatasource diseaseLocal;

  setUp(() {
    db = VetraDatabase.forTesting(NativeDatabase.memory());
    VetraDatabase.setTestInstance(db);
    queue = OperationQueue.instance;
    animalLocal = AnimalLocalDatasource.instance;
    diseaseLocal = DiseaseReportLocalDatasource.instance;
  });

  tearDown(() async {
    await db.close();
    VetraDatabase.setTestInstance(null);
  });

  group('Offline → Online Full Lifecycle Sync Simulation', () {
    test('Simulate complete offline creation, restart, and sequential server ID resolution', () async {
      // ─── 1. INTERNET OFF: Create animal locally ───
      const localAnimalId = 'local-animal-uuid-001';
      final animalModel = AnimalModel(
        id: localAnimalId,
        farmerId: 'farmer-123',
        farmerName: 'Ramesh',
        animalName: 'Gauri',
        tagNumber: 'MH-14-9988',
        species: 'CATTLE',
        breed: 'Gir',
        gender: 'FEMALE',
        birthDate: '2022-01-15',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await animalLocal.insert(animalModel);

      final animalOpId = await queue.enqueue(
        operationId: localAnimalId,
        operationType: OfflineOperationType.createAnimal,
        entityType: 'animal',
        entityLocalId: localAnimalId,
        payloadJson: '{"tagNumber":"MH-14-9988","species":"CATTLE"}',
      );

      // Verify animal is stored locally with pendingSync status
      final cachedAnimalBefore = await animalLocal.getByLocalId(localAnimalId);
      expect(cachedAnimalBefore, isNotNull);
      expect(cachedAnimalBefore!.tagNumber, equals('MH-14-9988'));

      // ─── 2. INTERNET OFF: Create disease report referencing that animal ───
      const localReportId = 'local-report-uuid-002';
      const reportDto = CreateDiseaseReportDto(
        animalId: localAnimalId, // points to local animal UUID
        diseaseName: 'Foot and Mouth Disease (FMD)',
        diagnosisStatus: 'SUSPECTED',
        latitude: 18.5204,
        longitude: 73.8567,
        notes: 'Excess salivation and mouth lesions',
      );

      await diseaseLocal.insert(
        reportDto,
        localId: localReportId,
        animalServerId: null,
        syncStatus: 'pendingSync',
      );

      final reportOpId = await queue.enqueue(
        operationId: localReportId,
        operationType: OfflineOperationType.createDiseaseReport,
        entityType: 'diseaseReport',
        entityLocalId: localReportId,
        payloadJson: '{"animalId":"$localAnimalId","diseaseName":"Foot and Mouth Disease (FMD)","latitude":18.5204,"longitude":73.8567}',
        dependsOn: localAnimalId, // depends on animal creation!
      );

      // Verify report is saved locally
      final cachedReportBefore = await diseaseLocal.getByLocalId(localReportId);
      expect(cachedReportBefore, isNotNull);
      expect(cachedReportBefore!.diseaseName, equals('Foot and Mouth Disease (FMD)'));

      // ─── 3. SIMULATE APP CRASH & RESTART ───
      await queue.resetAllProcessing();

      // Verify records and queue operations survive
      final pendingOps = await queue.getAllPending();
      expect(pendingOps.length, equals(2));
      expect(pendingOps[0].operationId, equals(animalOpId));
      expect(pendingOps[1].operationId, equals(reportOpId));

      // ─── 4. SEQUENTIAL SYNC EXECUTION ───
      // Step A: Peek next operation -> Animal MUST be first
      final firstOpToProcess = await queue.peekNext();
      expect(firstOpToProcess, isNotNull);
      expect(firstOpToProcess!.operationId, equals(animalOpId));

      // Step B: Mark Animal as processing -> Server returns permanent PostgreSQL UUID
      await queue.markAsProcessing(animalOpId);
      const serverAnimalId = 'srv-animal-uuid-8888';

      // Update local SQLite record with permanent server ID
      await animalLocal.updateServerId(localAnimalId, serverAnimalId);
      await animalLocal.updateSyncStatus(localAnimalId, 'synced');
      await diseaseLocal.updateAnimalServerId(localAnimalId, serverAnimalId);
      await queue.markCompleted(animalOpId);

      // Verify animal is now synced with serverId
      final animalRowAfter = await db.animalDao.getByLocalId(localAnimalId);
      expect(animalRowAfter!.serverId, equals(serverAnimalId));
      expect(animalRowAfter.syncStatus, equals('synced'));

      // Step C: Peek next operation -> Disease report is now unblocked
      final secondOpToProcess = await queue.peekNext();
      expect(secondOpToProcess, isNotNull);
      expect(secondOpToProcess!.operationId, equals(reportOpId));

      // Step D: Process Disease Report -> Resolve animal UUID to server UUID
      await queue.markAsProcessing(reportOpId);
      final resolvedAnimalRow = await db.animalDao.getByLocalId(localAnimalId);
      expect(resolvedAnimalRow!.serverId, equals(serverAnimalId));

      const serverReportId = 'srv-report-uuid-9999';
      await diseaseLocal.updateServerId(localReportId, serverReportId);
      await diseaseLocal.updateSyncStatus(localReportId, 'synced');
      await queue.markCompleted(reportOpId);

      // ─── 5. VERIFY FINAL STATE ───
      final remainingPending = await queue.peekNext();
      expect(remainingPending, isNull, reason: 'Queue should be completely empty');

      final finalReportRow = await db.diseaseReportDao.getByLocalId(localReportId);
      expect(finalReportRow!.serverId, equals(serverReportId));
      expect(finalReportRow.animalServerId, equals(serverAnimalId));
      expect(finalReportRow.syncStatus, equals('synced'));
    });
  });
}
