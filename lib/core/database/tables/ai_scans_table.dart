import 'package:drift/drift.dart';

/// Offline queue for AI livestock scans.
/// Image is stored as a local file path — NOT as a blob in SQLite.
/// AI inference ONLY happens on the server; this table only tracks local state.
///
/// Status flow: PENDING_UPLOAD → (sync) → COMPLETED | FAILED
class AiScansTable extends Table {
  @override
  String get tableName => 'local_ai_scans';

  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();

  TextColumn get animalLocalId => text()();
  TextColumn get animalServerId => text().nullable()();

  /// Permanent file path inside app documents directory.
  /// Format: <appDocumentsDir>/vetra/scans/<localId>.jpg
  TextColumn get localImagePath => text()();

  /// PENDING_UPLOAD | UPLOADING | PENDING_ANALYSIS | COMPLETED | FAILED
  TextColumn get status => text().withDefault(const Constant('PENDING_UPLOAD'))();

  // Fields populated after backend AI analysis:
  TextColumn get diagnosis => text().nullable()();
  RealColumn get confidenceScore => real().nullable()();
  TextColumn get severity => text().nullable()();

  /// JSON array of observation strings stored as text.
  TextColumn get observationsJson => text().nullable()();

  /// Full raw API response JSON for debugging.
  TextColumn get rawResultJson => text().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('localOnly'))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {localId};
}
