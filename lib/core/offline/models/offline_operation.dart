/// Typed enum for the kind of mutation to replay against the Spring Boot API.
enum OfflineOperationType {
  /// POST /api/v1/animals
  createAnimal,

  /// PUT /api/v1/animals/{id}
  updateAnimal,

  /// DELETE /api/v1/animals/{id}
  deleteAnimal,

  /// POST /api/v1/disease/reports
  createDiseaseReport,

  /// POST /api/v1/ai/scans  (uses existing base64 approach for MVP)
  submitAiScan,

  /// POST /api/v1/mortalities
  reportMortality,

  /// POST /api/v1/mortalities/{id}/confirm
  confirmMortality,

  /// POST /api/v1/mortalities/{id}/reject
  rejectMortality,
}

/// Lifecycle state of a queued operation.
enum OperationStatus {
  /// Waiting to be processed.
  pending,

  /// Currently in-flight (SyncEngine is processing this op).
  processing,

  /// Confirmed by the backend — has a server response.
  completed,

  /// Permanently failed after exceeding [maxRetries].
  failed,

  /// Skipped because its parent dependency permanently failed.
  cancelled,
}

/// A single mutation event in the offline operation queue.
///
/// Instances are created from [OfflineOperationsTableData] rows and vice versa.
class OfflineOperation {
  final String operationId;
  final OfflineOperationType operationType;
  final String entityType;
  final String entityLocalId;
  final String payloadJson;
  final OperationStatus status;
  final int retryCount;
  final int maxRetries;
  final String? lastError;
  final String idempotencyKey;
  final String? dependsOn;
  final int createdAt;
  final int? lastAttemptedAt;
  final int? completedAt;

  const OfflineOperation({
    required this.operationId,
    required this.operationType,
    required this.entityType,
    required this.entityLocalId,
    required this.payloadJson,
    this.status = OperationStatus.pending,
    this.retryCount = 0,
    this.maxRetries = 5,
    this.lastError,
    required this.idempotencyKey,
    this.dependsOn,
    required this.createdAt,
    this.lastAttemptedAt,
    this.completedAt,
  });

  bool get isPending => status == OperationStatus.pending;
  bool get isCompleted => status == OperationStatus.completed;
  bool get isFailed => status == OperationStatus.failed;
  bool get hasExceededRetries => retryCount >= maxRetries;

  @override
  String toString() =>
      'OfflineOperation($operationType, entity=$entityLocalId, status=$status, retries=$retryCount/$maxRetries)';
}
