import 'package:drift/drift.dart';
import '../../../../core/database/daos/disease_report_dao.dart';
import '../../../../core/database/vetra_database.dart';
import '../../../../core/services/auth_service.dart';
import '../models/disease_report_dto.dart';

/// Local data source for disease reports.
/// Converts between Drift [DiseaseReportsTableData] rows and [DiseaseReportModel].
/// Persists reports in local SQLite storage.
class DiseaseReportLocalDatasource {
  DiseaseReportLocalDatasource._();

  static final DiseaseReportLocalDatasource instance = DiseaseReportLocalDatasource._();

  DiseaseReportDao get _dao => VetraDatabase.instance.diseaseReportDao;

  String get _currentUserId => AuthService.instance.currentUser?.id ?? '';
  String get _currentUserName => AuthService.instance.currentUser?.name ?? 'You';

  /// Returns all locally cached disease reports.
  Future<List<DiseaseReportModel>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toModel).toList();
  }

  /// Fetches a report by its local UUID.
  Future<DiseaseReportModel?> getByLocalId(String localId) async {
    final row = await _dao.getByLocalId(localId);
    return row != null ? _toModel(row) : null;
  }

  /// Returns reports linked to an animal's localId.
  Future<List<DiseaseReportModel>> getByAnimalLocalId(String animalLocalId) async {
    final rows = await _dao.getByAnimalLocalId(animalLocalId);
    return rows.map(_toModel).toList();
  }

  /// Watches all disease reports as a live stream.
  Stream<List<DiseaseReportModel>> watchAll() {
    return _dao.watchAll().map((rows) => rows.map(_toModel).toList());
  }

  /// Inserts a new disease report into local SQLite.
  Future<void> insert(CreateDiseaseReportDto dto, {
    required String localId,
    String? animalServerId,
    String? aiScanServerId,
    String syncStatus = 'pendingSync',
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.insertReport(DiseaseReportsTableCompanion(
      localId: Value(localId),
      serverId: const Value.absent(),
      animalLocalId: Value(dto.animalId),
      animalServerId: Value(animalServerId),
      diseaseName: Value(dto.diseaseName),
      diagnosisStatus: Value(dto.diagnosisStatus),
      reportSource: Value(dto.reportSource),
      latitude: Value(dto.latitude),
      longitude: Value(dto.longitude),
      gpsAccuracy: const Value.absent(),
      gpsQuality: const Value('ACCURATE'),
      notes: Value(dto.notes),
      aiScanLocalId: Value(dto.aiScanId),
      aiScanServerId: Value(aiScanServerId),
      syncStatus: Value(syncStatus),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  /// Updates the server ID after sync completion.
  Future<void> updateServerId(String localId, String serverId) {
    return _dao.updateServerId(localId, serverId);
  }

  /// Updates animalServerId when the linked animal has been synced.
  Future<void> updateAnimalServerId(String localId, String animalServerId) {
    return _dao.updateAnimalServerId(localId, animalServerId);
  }

  /// Updates sync status.
  Future<void> updateSyncStatus(String localId, String status) {
    return _dao.updateSyncStatus(localId, status);
  }

  DiseaseReportModel _toModel(DiseaseReportsTableData row) {
    return DiseaseReportModel(
      id: row.serverId ?? row.localId,
      animalId: row.animalServerId ?? row.animalLocalId,
      tagNumber: null,
      animalName: null,
      medicalRecordId: null,
      aiScanId: row.aiScanServerId ?? row.aiScanLocalId,
      reportedById: _currentUserId,
      reportedByName: _currentUserName,
      reportSource: row.reportSource,
      diagnosisConfidenceSource: null,
      diseaseName: row.diseaseName,
      diagnosisStatus: row.diagnosisStatus,
      latitude: row.latitude,
      longitude: row.longitude,
      notes: row.notes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }
}
