import 'package:drift/drift.dart';
import '../tables/offline_operations_table.dart';
import '../vetra_database.dart';

part 'offline_operation_dao.g.dart';

@DriftAccessor(tables: [OfflineOperationsTable])
class OfflineOperationDao extends DatabaseAccessor<VetraDatabase>
    with _$OfflineOperationDaoMixin {
  OfflineOperationDao(super.db);

  /// Returns the next PENDING operation to process, respecting [dependsOn].
  ///
  /// Logic:
  /// 1. Get all PENDING operations ordered by createdAt ASC.
  /// 2. For each, if dependsOn is set, check parent status:
  ///    - completed or non-existent: ready to process.
  ///    - failed or cancelled: auto-cancel this child operation and continue loop.
  ///    - pending or processing: skip and inspect next operation.
  /// 3. Return the first ready operation.
  Future<OfflineOperationsTableData?> peekNext() async {
    final pending = await (select(offlineOperationsTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    for (final op in pending) {
      if (op.dependsOn == null) return op;

      final parent = await (select(offlineOperationsTable)
            ..where((t) => t.operationId.equals(op.dependsOn!)))
          .getSingleOrNull();

      if (parent == null || parent.status == 'completed') {
        return op;
      }

      if (parent.status == 'failed' || parent.status == 'cancelled') {
        // Cascade failure: cancel dependent child operation so queue does not block
        await (update(offlineOperationsTable)
              ..where((t) => t.operationId.equals(op.operationId)))
            .write(OfflineOperationsTableCompanion(
              status: const Value('cancelled'),
              lastError: Value('Parent operation ${op.dependsOn} did not succeed (${parent.status})'),
              lastAttemptedAt: Value(DateTime.now().millisecondsSinceEpoch),
            ));
        continue;
      }

      // Parent is pending/processing: wait for parent
    }
    return null;
  }

  /// Fetches a single operation by its ID.
  Future<OfflineOperationsTableData?> getById(String operationId) {
    return (select(offlineOperationsTable)
          ..where((t) => t.operationId.equals(operationId)))
        .getSingleOrNull();
  }

  /// Inserts a new operation into the queue.
  Future<void> enqueue(OfflineOperationsTableCompanion op) {
    return into(offlineOperationsTable).insert(op);
  }

  /// Marks an operation as PROCESSING (in-flight).
  Future<void> markAsProcessing(String operationId) {
    return (update(offlineOperationsTable)
          ..where((t) => t.operationId.equals(operationId)))
        .write(OfflineOperationsTableCompanion(
          status: const Value('processing'),
          lastAttemptedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Marks an operation as COMPLETED.
  Future<void> markCompleted(String operationId) {
    return (update(offlineOperationsTable)
          ..where((t) => t.operationId.equals(operationId)))
        .write(OfflineOperationsTableCompanion(
          status: const Value('completed'),
          completedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Increments retryCount; marks FAILED if maxRetries is exceeded.
  Future<void> markFailed(String operationId, String error) async {
    final op = await getById(operationId);
    if (op == null) return;

    final newRetryCount = op.retryCount + 1;
    final newStatus = newRetryCount >= op.maxRetries ? 'failed' : 'pending';

    await (update(offlineOperationsTable)
          ..where((t) => t.operationId.equals(operationId)))
        .write(OfflineOperationsTableCompanion(
          status: Value(newStatus),
          retryCount: Value(newRetryCount),
          lastError: Value(error),
          lastAttemptedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Resets all PROCESSING operations to PENDING.
  /// Called on app startup to recover from app process termination mid-sync.
  Future<void> resetAllProcessing() {
    return (update(offlineOperationsTable)
          ..where((t) => t.status.equals('processing')))
        .write(const OfflineOperationsTableCompanion(
          status: Value('pending'),
        ));
  }

  /// Resets stale PROCESSING operations older than [staleThreshold].
  Future<void> resetStaleProcessing({
    Duration staleThreshold = const Duration(minutes: 2),
  }) {
    final cutoff = DateTime.now()
        .subtract(staleThreshold)
        .millisecondsSinceEpoch;

    return (update(offlineOperationsTable)
          ..where((t) =>
              t.status.equals('processing') &
              t.lastAttemptedAt.isSmallerOrEqualValue(cutoff)))
        .write(const OfflineOperationsTableCompanion(
          status: Value('pending'),
        ));
  }

  /// Returns the count of PENDING operations as a reactive stream.
  Stream<int> watchPendingCount() {
    final query = selectOnly(offlineOperationsTable)
      ..addColumns([offlineOperationsTable.operationId.count()])
      ..where(offlineOperationsTable.status.equals('pending'));
    return query
        .map((row) => row.read(offlineOperationsTable.operationId.count()) ?? 0)
        .watchSingle();
  }

  /// Returns all PENDING operations.
  Future<List<OfflineOperationsTableData>> getAllPending() {
    return (select(offlineOperationsTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Returns all FAILED operations.
  Future<List<OfflineOperationsTableData>> getAllFailed() {
    return (select(offlineOperationsTable)
          ..where((t) => t.status.equals('failed')))
        .get();
  }
}
