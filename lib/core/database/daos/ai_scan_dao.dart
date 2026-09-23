import 'package:drift/drift.dart';
import '../tables/ai_scans_table.dart';
import '../vetra_database.dart';

part 'ai_scan_dao.g.dart';

@DriftAccessor(tables: [AiScansTable])
class AiScanDao extends DatabaseAccessor<VetraDatabase>
    with _$AiScanDaoMixin {
  AiScanDao(super.db);

  /// Returns all AI scans ordered by most recent first.
  Future<List<AiScansTableData>> getAll() {
    return (select(aiScansTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Fetches a single scan by local UUID.
  Future<AiScansTableData?> getByLocalId(String localId) {
    return (select(aiScansTable)..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
  }

  /// Returns all scans in PENDING_UPLOAD status awaiting sync.
  Future<List<AiScansTableData>> getPendingUpload() {
    return (select(aiScansTable)
          ..where((t) => t.status.equals('PENDING_UPLOAD')))
        .get();
  }

  /// Inserts a new AI scan record.
  Future<void> insertScan(AiScansTableCompanion scan) {
    return into(aiScansTable).insert(scan);
  }

  /// Updates the server ID and AI result after successful backend inference.
  Future<void> updateWithResult({
    required String localId,
    required String serverId,
    required String diagnosis,
    required double? confidenceScore,
    required String severity,
    required String observationsJson,
    required String rawResultJson,
  }) {
    return (update(aiScansTable)..where((t) => t.localId.equals(localId)))
        .write(AiScansTableCompanion(
          serverId: Value(serverId),
          status: const Value('COMPLETED'),
          syncStatus: const Value('synced'),
          diagnosis: Value(diagnosis),
          confidenceScore: Value(confidenceScore),
          severity: Value(severity),
          observationsJson: Value(observationsJson),
          rawResultJson: Value(rawResultJson),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Updates scan status (e.g. UPLOADING → PENDING_ANALYSIS).
  Future<void> updateStatus(String localId, String status) {
    return (update(aiScansTable)..where((t) => t.localId.equals(localId)))
        .write(AiScansTableCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Updates sync status.
  Future<void> updateSyncStatus(String localId, String syncStatus) {
    return (update(aiScansTable)..where((t) => t.localId.equals(localId)))
        .write(AiScansTableCompanion(
          syncStatus: Value(syncStatus),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Updates the animal server UUID once that animal has been synced.
  Future<void> updateAnimalServerId(String animalLocalId, String animalServerId) {
    return (update(aiScansTable)..where((t) => t.animalLocalId.equals(animalLocalId)))
        .write(AiScansTableCompanion(
          animalServerId: Value(animalServerId),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// The server accepted the upload but its AI produced no diagnosis.
  /// The record exists on the server, so it is synced; only the analysis failed.
  Future<void> markAnalysisFailed({
    required String localId,
    required String serverId,
    required String rawResultJson,
  }) {
    return (update(aiScansTable)..where((t) => t.localId.equals(localId)))
        .write(AiScansTableCompanion(
          serverId: Value(serverId),
          status: const Value('FAILED'),
          syncStatus: const Value('synced'),
          diagnosis: const Value(null),
          confidenceScore: const Value(null),
          rawResultJson: Value(rawResultJson),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Marks a scan as FAILED.
  Future<void> markFailed(String localId, String error) {
    return (update(aiScansTable)..where((t) => t.localId.equals(localId)))
        .write(AiScansTableCompanion(
          status: const Value('FAILED'),
          syncStatus: const Value('failed'),
          rawResultJson: Value(error),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Watches all scans — emits on any change (used in scan history UI).
  Stream<List<AiScansTableData>> watchAll() {
    return (select(aiScansTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
