import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/database/vetra_database.dart';
import 'package:vetra/core/offline/models/offline_operation.dart';
import 'package:vetra/core/offline/operation_queue.dart';
import 'package:vetra/core/offline/sync_engine.dart';

void main() {
  // The test binding answers every HTTP request itself, so the engine's health
  // ping never leaves the machine.
  TestWidgetsFlutterBinding.ensureInitialized();

  late VetraDatabase db;
  final queue = OperationQueue.instance;

  setUp(() {
    db = VetraDatabase.forTesting(NativeDatabase.memory());
    VetraDatabase.setTestInstance(db);
  });

  tearDown(() async {
    await db.close();
    VetraDatabase.setTestInstance(null);
  });

  Future<String> enqueue(String id, {String? dependsOn}) => queue.enqueue(
        operationId: id,
        operationType: OfflineOperationType.createDiseaseReport,
        entityType: 'diseaseReport',
        entityLocalId: id,
        payloadJson: '{"diseaseName":"Lumpy Skin Disease"}',
        dependsOn: dependsOn,
      );

  test('a transient failure is attempted exactly 5 times, then kept as failed (not dropped)', () async {
    await enqueue('op-1');
    for (var attempt = 1; attempt <= 4; attempt++) {
      await queue.markFailed('op-1', 'Internal server error (server error 500)');
      expect((await queue.getById('op-1'))!.status, OperationStatus.pending, reason: 'attempt $attempt');
    }
    await queue.markFailed('op-1', 'Internal server error (server error 500)');
    final op = (await queue.getById('op-1'))!;
    expect(op.status, OperationStatus.failed);
    expect(op.retryCount, 5);

    expect(await queue.watchPendingCount().first, 0);
    expect(await queue.watchFailedCount().first, 1, reason: 'failed items are counted, not dropped');
    expect((await queue.watchFailed().first).single.lastError, contains('500'));
  });

  test('a definitive rejection fails on the first attempt with the server reason', () async {
    await enqueue('op-2');
    await queue.markFailed('op-2', 'An animal with tag number MH12-7788 is already registered', permanent: true);
    final op = (await queue.getById('op-2'))!;
    expect(op.status, OperationStatus.failed);
    expect(op.retryCount, 1);
  });

  test('Retry revives the failed item and everything cancelled because of it', () async {
    await enqueue('parent');
    await enqueue('child', dependsOn: 'parent');
    await queue.markFailed('parent', 'rejected', permanent: true);
    expect(await queue.peekNext(), isNull, reason: 'peek cancels the orphaned child');
    expect((await queue.getById('child'))!.status, OperationStatus.cancelled);
    expect(await queue.watchFailedCount().first, 2);

    await queue.retry('child'); // retrying the child restarts from its failed parent

    final parent = (await queue.getById('parent'))!;
    final child = (await queue.getById('child'))!;
    expect(parent.status, OperationStatus.pending);
    expect(parent.retryCount, 0);
    expect(child.status, OperationStatus.pending);
    expect(await queue.watchFailedCount().first, 0);
  });

  test('sync guard is claimed before the first await, so a second trigger is skipped', () async {
    final engine = SyncEngine.instance;
    final first = engine.runSync();
    expect(engine.isSyncing, isTrue, reason: 'must be set synchronously, before the health ping');
    await engine.runSync(); // a concurrent trigger returns immediately
    expect(engine.isSyncing, isTrue);
    await first;
    expect(engine.isSyncing, isFalse);
  });
}
