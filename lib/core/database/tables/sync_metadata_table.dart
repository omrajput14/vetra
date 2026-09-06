import 'package:drift/drift.dart';

/// Tracks per-entity-type sync cursors and timestamps.
/// Used to implement efficient incremental syncs (only fetch changes since last sync).
class SyncMetadataTable extends Table {
  @override
  String get tableName => 'sync_metadata';

  /// Entity type identifier: 'animals' | 'diseaseReports' | 'aiScans'
  TextColumn get entityType => text()();

  /// Unix milliseconds of last successful pull from server.
  IntColumn get lastSyncedAt => integer().nullable()();

  /// Monotonically increasing counter; bumped after every successful sync cycle.
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {entityType};
}
