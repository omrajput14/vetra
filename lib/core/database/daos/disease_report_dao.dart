import 'package:drift/drift.dart';
import '../tables/disease_reports_table.dart';
import '../vetra_database.dart';

part 'disease_report_dao.g.dart';

@DriftAccessor(tables: [DiseaseReportsTable])
class DiseaseReportDao extends DatabaseAccessor<VetraDatabase>
    with _$DiseaseReportDaoMixin {
  DiseaseReportDao(super.db);

  /// Returns all disease reports ordered by most recent first.
  Future<List<DiseaseReportsTableData>> getAll() {
    return (select(diseaseReportsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Fetches a single report by local UUID.
  Future<DiseaseReportsTableData?> getByLocalId(String localId) {
    return (select(diseaseReportsTable)
          ..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
  }

  /// Fetches all reports linked to a specific animal (by local ID).
  Future<List<DiseaseReportsTableData>> getByAnimalLocalId(String animalLocalId) {
    return (select(diseaseReportsTable)
          ..where((t) => t.animalLocalId.equals(animalLocalId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Inserts a new disease report into the local queue.
  Future<void> insertReport(DiseaseReportsTableCompanion report) {
    return into(diseaseReportsTable).insert(report);
  }

  /// Updates the server-assigned UUID and marks as synced after successful sync.
  Future<void> updateServerId(String localId, String serverId) {
    return (update(diseaseReportsTable)
          ..where((t) => t.localId.equals(localId)))
        .write(DiseaseReportsTableCompanion(
          serverId: Value(serverId),
          syncStatus: const Value('synced'),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Updates the resolved animal server UUID on a report.
  /// Called by SyncEngine when the linked animal has been synced first.
  Future<void> updateAnimalServerId(String animalLocalId, String animalServerId) {
    return (update(diseaseReportsTable)
          ..where((t) => t.animalLocalId.equals(animalLocalId)))
        .write(DiseaseReportsTableCompanion(
          animalServerId: Value(animalServerId),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Updates sync status.
  Future<void> updateSyncStatus(String localId, String status) {
    return (update(diseaseReportsTable)
          ..where((t) => t.localId.equals(localId)))
        .write(DiseaseReportsTableCompanion(
          syncStatus: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Returns all reports that are pending sync.
  Future<List<DiseaseReportsTableData>> getPendingSync() {
    return (select(diseaseReportsTable)
          ..where((t) =>
              t.syncStatus.equals('localOnly') |
              t.syncStatus.equals('pendingSync')))
        .get();
  }

  /// Watches all disease reports — emits on any change.
  Stream<List<DiseaseReportsTableData>> watchAll() {
    return (select(diseaseReportsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
