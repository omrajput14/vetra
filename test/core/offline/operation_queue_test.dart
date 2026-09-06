import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/database/vetra_database.dart';
import 'package:vetra/core/offline/models/offline_operation.dart';
import 'package:vetra/core/offline/operation_queue.dart';

void main() {
  late VetraDatabase db;
  late OperationQueue queue;

  setUp(() {
    db = VetraDatabase.forTesting(NativeDatabase.memory());
    VetraDatabase.setTestInstance(db);
    queue = OperationQueue.instance;
  });

  tearDown(() async {
    await db.close();
    VetraDatabase.setTestInstance(null);
  });

  group('OperationQueue Tests', () {
    test('Should enqueue and peek operations in strict FIFO order', () async {
      final id1 = await queue.enqueue(
        operationType: OfflineOperationType.createAnimal,
        entityType: 'animal',
        entityLocalId: 'loc-1',
        payloadJson: '{"tagNumber":"TAG-1"}',
      );

      final id2 = await queue.enqueue(
        operationType: OfflineOperationType.createDiseaseReport,
        entityType: 'diseaseReport',
        entityLocalId: 'loc-2',
        payloadJson: '{"diseaseName":"FMD"}',
      );

      final next1 = await queue.peekNext();
      expect(next1, isNotNull);
      expect(next1!.operationId, equals(id1));

      await queue.markCompleted(id1);

      final next2 = await queue.peekNext();
      expect(next2, isNotNull);
      expect(next2!.operationId, equals(id2));
    });

    test('Should honor dependsOn: child operation is not returned until parent completes', () async {
      final parentId = await queue.enqueue(
        operationType: OfflineOperationType.createAnimal,
        entityType: 'animal',
        entityLocalId: 'loc-parent',
        payloadJson: '{"tagNumber":"PARENT"}',
      );

      final childId = await queue.enqueue(
        operationType: OfflineOperationType.createDiseaseReport,
        entityType: 'diseaseReport',
        entityLocalId: 'loc-child',
        payloadJson: '{"animalId":"loc-parent"}',
        dependsOn: parentId,
      );

      // Peek should return parent first
      final next1 = await queue.peekNext();
      expect(next1!.operationId, equals(parentId));

      // Mark parent as processing - child still should not be returned
      await queue.markAsProcessing(parentId);
      final nextWhileParentProcessing = await queue.peekNext();
      expect(nextWhileParentProcessing, isNull);

      // Complete parent -> child becomes ready
      await queue.markCompleted(parentId);
      final nextAfterParentCompleted = await queue.peekNext();
      expect(nextAfterParentCompleted, isNotNull);
      expect(nextAfterParentCompleted!.operationId, equals(childId));
    });

    test('Should cascade cancel when parent permanently fails', () async {
      final parentId = await queue.enqueue(
        operationType: OfflineOperationType.createAnimal,
        entityType: 'animal',
        entityLocalId: 'loc-parent-fail',
        payloadJson: '{"tagNumber":"FAIL"}',
        maxRetries: 1,
      );

      final childId = await queue.enqueue(
        operationType: OfflineOperationType.createDiseaseReport,
        entityType: 'diseaseReport',
        entityLocalId: 'loc-child-blocked',
        payloadJson: '{"animalId":"loc-parent-fail"}',
        dependsOn: parentId,
      );

      // Fail parent exceeding max retries
      await queue.markFailed(parentId, 'Permanent validation error');
      final parent = await queue.getById(parentId);
      expect(parent!.status, equals(OperationStatus.failed));

      // Peeking should detect parent failure, auto-cancel child, and return null without blocking
      final next = await queue.peekNext();
      expect(next, isNull);

      final child = await queue.getById(childId);
      expect(child!.status, equals(OperationStatus.cancelled));
    });

    test('Should reset all processing operations on startup recovery', () async {
      final id = await queue.enqueue(
        operationType: OfflineOperationType.createAnimal,
        entityType: 'animal',
        entityLocalId: 'loc-crash',
        payloadJson: '{"tagNumber":"CRASH"}',
      );

      await queue.markAsProcessing(id);
      var op = await queue.getById(id);
      expect(op!.status, equals(OperationStatus.processing));

      // Simulate crash recovery
      await queue.resetAllProcessing();

      op = await queue.getById(id);
      expect(op!.status, equals(OperationStatus.pending));
    });
  });
}
