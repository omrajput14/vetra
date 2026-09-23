import 'package:drift/drift.dart';
import '../../../../core/database/daos/ai_scan_dao.dart';
import '../../../../core/database/vetra_database.dart';
import '../models/ai_scan_model.dart';

/// Local data source for AI livestock scans.
/// Converts between Drift [AiScansTableData] rows and [AIScanModel].
class AiScanLocalDatasource {
  AiScanLocalDatasource._();

  static final AiScanLocalDatasource instance = AiScanLocalDatasource._();

  AiScanDao get _dao => VetraDatabase.instance.aiScanDao;

  Future<List<AIScanModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toModel).toList();
  }

  Future<AIScanModel?> getByLocalId(String localId) async {
    final row = await _dao.getByLocalId(localId);
    return row != null ? _toModel(row) : null;
  }

  Future<List<AIScanModel>> getPendingUpload() async {
    final rows = await _dao.getPendingUpload();
    return rows.map(_toModel).toList();
  }

  Stream<List<AIScanModel>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toModel).toList());
  }

  Future<void> insert({
    required String localId,
    required String animalLocalId,
    String? animalServerId,
    required String localImagePath,
    String status = 'PENDING_UPLOAD',
    String syncStatus = 'pendingSync',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.insertScan(AiScansTableCompanion(
      localId: Value(localId),
      serverId: const Value.absent(),
      animalLocalId: Value(animalLocalId),
      animalServerId: Value(animalServerId),
      localImagePath: Value(localImagePath),
      status: Value(status),
      syncStatus: Value(syncStatus),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<void> updateWithResult({
    required String localId,
    required String serverId,
    required String diagnosis,
    required double? confidenceScore,
    required String severity,
    required String observationsJson,
    required String rawResultJson,
  }) {
    return _dao.updateWithResult(
      localId: localId,
      serverId: serverId,
      diagnosis: diagnosis,
      confidenceScore: confidenceScore,
      severity: severity,
      observationsJson: observationsJson,
      rawResultJson: rawResultJson,
    );
  }

  Future<void> markAnalysisFailed({
    required String localId,
    required String serverId,
    required String rawResultJson,
  }) {
    return _dao.markAnalysisFailed(
      localId: localId,
      serverId: serverId,
      rawResultJson: rawResultJson,
    );
  }

  Future<void> updateStatus(String localId, String status) {
    return _dao.updateStatus(localId, status);
  }

  Future<void> updateSyncStatus(String localId, String syncStatus) {
    return _dao.updateSyncStatus(localId, syncStatus);
  }

  Future<void> markFailed(String localId, String error) {
    return _dao.markFailed(localId, error);
  }

  AIScanModel _toModel(AiScansTableData row) {
    return AIScanModel(
      id: row.serverId ?? row.localId,
      animalId: row.animalServerId ?? row.animalLocalId,
      imageUrl: row.localImagePath,
      diagnosis: row.diagnosis ?? 'Pending AI Analysis',
      confidenceScore: row.confidenceScore ?? 0.0,
      severity: row.severity ?? 'SUSPECTED',
      observations: row.observationsJson != null ? [row.observationsJson!] : const [],
      status: row.status,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt).toIso8601String(),
    );
  }
}
