import 'package:drift/drift.dart';

/// Durable operation queue that survives app restarts.
///
/// Each row represents one mutation to be sent to the Spring Boot backend.
/// Operations are processed sequentially by [SyncEngine] in order of [createdAt],
/// with [dependsOn] respected to guarantee server-ID resolution before submission.
///
/// [idempotencyKey] is sent as the `Idempotency-Key` HTTP header so the
/// backend's V29 idempotency table can reject duplicate submissions.
class OfflineOperationsTable extends Table {
  @override
  String get tableName => 'offline_operations';

  /// Client-generated UUID; also used as [idempotencyKey].
  TextColumn get operationId => text()();

  /// createAnimal | updateAnimal | deleteAnimal |
  /// createDiseaseReport | submitAiScan
  TextColumn get operationType => text()();

  /// animal | diseaseReport | aiScan
  TextColumn get entityType => text()();

  /// FK to the relevant local_* table's localId.
  TextColumn get entityLocalId => text()();

  /// Full JSON request body to replay against the API.
  TextColumn get payloadJson => text()();

  /// pending | processing | completed | failed | cancelled
  TextColumn get status => text().withDefault(const Constant('pending'))();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(5))();

  TextColumn get lastError => text().nullable()();

  /// Sent as `Idempotency-Key: <value>` HTTP header. Equals [operationId].
  TextColumn get idempotencyKey => text().unique()();

  /// [operationId] of a prior operation that MUST be COMPLETED before this one runs.
  /// Used to ensure createAnimal finishes before createDiseaseReport is submitted.
  TextColumn get dependsOn => text().nullable()();

  IntColumn get createdAt => integer()();
  IntColumn get lastAttemptedAt => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {operationId};
}
