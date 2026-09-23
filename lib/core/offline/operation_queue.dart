import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/daos/offline_operation_dao.dart';
import '../database/vetra_database.dart';
import 'models/offline_operation.dart';

/// Durable offline operation queue backed by SQLite.
///
/// Survives app restarts. All mutations that cannot be immediately sent to the
/// Spring Boot backend are enqueued here and processed sequentially by
/// [SyncEngine] when the backend becomes reachable.
///
/// Key invariants:
/// • Operations are processed FIFO, with [dependsOn] chain respected.
/// • Each operation carries a [idempotencyKey] sent as `Idempotency-Key`
///   HTTP header so the backend can safely reject duplicates (V29 table).
/// • [resetAllProcessing] is called on app startup to recover from crashes.
class OperationQueue {
  OperationQueue._();

  static final OperationQueue instance = OperationQueue._();

  OfflineOperationDao get _dao => VetraDatabase.instance.offlineOperationDao;

  static const _uuid = Uuid();

  // ─── Enqueue ───────────────────────────────────────────────────────────────

  /// Adds a new operation to the queue.
  Future<String> enqueue({
    required OfflineOperationType operationType,
    required String entityType,
    required String entityLocalId,
    required String payloadJson,
    String? operationId,
    String? dependsOn,
    int maxRetries = 5,
  }) async {
    final id = operationId ?? _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _dao.enqueue(OfflineOperationsTableCompanion(
      operationId: Value(id),
      operationType: Value(_typeToString(operationType)),
      entityType: Value(entityType),
      entityLocalId: Value(entityLocalId),
      payloadJson: Value(payloadJson),
      status: const Value('pending'),
      retryCount: const Value(0),
      maxRetries: Value(maxRetries),
      idempotencyKey: Value(id), // operationId IS the idempotency key
      dependsOn: Value(dependsOn),
      createdAt: Value(now),
    ));

    debugPrint('[OperationQueue] Enqueued $operationType for entity=$entityLocalId (id=$id)');
    return id;
  }

  // ─── Peek ──────────────────────────────────────────────────────────────────

  /// Returns the next PENDING operation that is ready to process.
  Future<OfflineOperation?> peekNext() async {
    final row = await _dao.peekNext();
    return row != null ? _fromRow(row) : null;
  }

  // ─── Status updates ────────────────────────────────────────────────────────

  /// Marks an operation as PROCESSING (in-flight).
  Future<void> markAsProcessing(String operationId) {
    return _dao.markAsProcessing(operationId);
  }

  /// Marks an operation as COMPLETED after successful API response.
  Future<void> markCompleted(String operationId) {
    debugPrint('[OperationQueue] Completed operation $operationId');
    return _dao.markCompleted(operationId);
  }

  /// Increments retryCount; promotes to FAILED after maxRetries attempts, or at
  /// once when [permanent] (the server definitively rejected the operation).
  Future<void> markFailed(String operationId, String error, {bool permanent = false}) {
    debugPrint('[OperationQueue] Failed operation $operationId: $error');
    return _dao.markFailed(operationId, error, permanent: permanent);
  }

  /// Sends a failed (or cancelled) operation again, with fresh retries.
  Future<void> retry(String operationId) => _dao.requeue(operationId);

  Future<void> retryAllFailed() async {
    for (final op in await _dao.getAllFailed()) {
      await _dao.requeue(op.operationId);
    }
  }

  // ─── Startup recovery ──────────────────────────────────────────────────────

  /// Resets all PROCESSING operations back to PENDING.
  /// Called on app startup to recover from mid-sync crashes.
  Future<void> resetAllProcessing() {
    return _dao.resetAllProcessing();
  }

  /// Resets any PROCESSING operations older than [staleThreshold] to PENDING.
  Future<void> resetStaleProcessing({
    Duration staleThreshold = const Duration(minutes: 2),
  }) {
    return _dao.resetStaleProcessing(staleThreshold: staleThreshold);
  }

  // ─── Reactive streams ──────────────────────────────────────────────────────

  /// Stream of pending operation count — drives the sync status UI badge.
  Stream<int> watchPendingCount() => _dao.watchPendingCount();

  /// Operations that will not sync without the user retrying them.
  Stream<int> watchFailedCount() => _dao.watchFailedCount();

  Stream<List<OfflineOperation>> watchFailed() =>
      _dao.watchFailed().map((rows) => rows.map(_fromRow).toList());

  // ─── Queries ───────────────────────────────────────────────────────────────

  Future<List<OfflineOperation>> getAllPending() async {
    final rows = await _dao.getAllPending();
    return rows.map(_fromRow).toList();
  }

  Future<List<OfflineOperation>> getAllFailed() async {
    final rows = await _dao.getAllFailed();
    return rows.map(_fromRow).toList();
  }

  Future<OfflineOperation?> getById(String operationId) async {
    final row = await _dao.getById(operationId);
    return row != null ? _fromRow(row) : null;
  }

  // ─── Conversions ───────────────────────────────────────────────────────────

  OfflineOperation _fromRow(OfflineOperationsTableData row) {
    return OfflineOperation(
      operationId: row.operationId,
      operationType: _typeFromString(row.operationType),
      entityType: row.entityType,
      entityLocalId: row.entityLocalId,
      payloadJson: row.payloadJson,
      status: _statusFromString(row.status),
      retryCount: row.retryCount,
      maxRetries: row.maxRetries,
      lastError: row.lastError,
      idempotencyKey: row.idempotencyKey,
      dependsOn: row.dependsOn,
      createdAt: row.createdAt,
      lastAttemptedAt: row.lastAttemptedAt,
      completedAt: row.completedAt,
    );
  }

  static String _typeToString(OfflineOperationType type) {
    return type.name;
  }

  static OfflineOperationType _typeFromString(String value) {
    return OfflineOperationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OfflineOperationType.createAnimal,
    );
  }

  static OperationStatus _statusFromString(String value) {
    return OperationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OperationStatus.pending,
    );
  }
}
