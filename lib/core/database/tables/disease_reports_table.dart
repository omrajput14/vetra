import 'package:drift/drift.dart';

/// Offline queue for disease surveillance reports.
/// Reports are queued here when offline and submitted to Spring Boot on sync.
/// Outbreak detection NEVER runs on-device — this is purely a submission queue.
class DiseaseReportsTable extends Table {
  @override
  String get tableName => 'local_disease_reports';

  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();

  /// FK to local_animals.localId
  TextColumn get animalLocalId => text()();

  /// Populated once the animal has been synced and has a real server UUID.
  TextColumn get animalServerId => text().nullable()();

  TextColumn get diseaseName => text()();
  TextColumn get diagnosisStatus => text().withDefault(const Constant('SUSPECTED'))();
  TextColumn get reportSource => text().withDefault(const Constant('MANUAL'))();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  /// GPS accuracy in metres (from Geolocator).
  RealColumn get gpsAccuracy => real().nullable()();

  /// ACCURATE | APPROXIMATE | UNAVAILABLE | USER_SELECTED
  TextColumn get gpsQuality => text().withDefault(const Constant('ACCURATE'))();

  TextColumn get notes => text().nullable()();

  /// FK to local_ai_scans.localId if this report is linked to a scan.
  TextColumn get aiScanLocalId => text().nullable()();
  TextColumn get aiScanServerId => text().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('localOnly'))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {localId};
}
