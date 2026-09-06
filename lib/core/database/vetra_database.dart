import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'tables/animals_table.dart';
import 'tables/disease_reports_table.dart';
import 'tables/ai_scans_table.dart';
import 'tables/offline_operations_table.dart';
import 'tables/sync_metadata_table.dart';
import 'daos/animal_dao.dart';
import 'daos/disease_report_dao.dart';
import 'daos/ai_scan_dao.dart';
import 'daos/offline_operation_dao.dart';

part 'vetra_database.g.dart';

/// The single Drift SQLite database for all offline-first operations.
///
/// Architecture:
///   Mobile SQLite (this DB) → OfflineFirstRepositories → SyncEngine
///                          → Spring Boot API → PostgreSQL
///
/// Invariants:
/// • Outbreak detection NEVER runs here — disease reports are only queued.
/// • AI inference NEVER runs here — scans are queued for cloud submission.
/// • No direct SQLite ↔ PostgreSQL sync — all data flows through REST API.
@DriftDatabase(
  tables: [
    AnimalsTable,
    DiseaseReportsTable,
    AiScansTable,
    OfflineOperationsTable,
    SyncMetadataTable,
  ],
  daos: [
    AnimalDao,
    DiseaseReportDao,
    AiScanDao,
    OfflineOperationDao,
  ],
)
class VetraDatabase extends _$VetraDatabase {
  VetraDatabase._() : super(_openConnection());

  @visibleForTesting
  VetraDatabase.forTesting(super.e);

  // ─── Singleton ─────────────────────────────────────────────────────────────
  static VetraDatabase? _instance;

  static VetraDatabase get instance {
    _instance ??= VetraDatabase._();
    return _instance!;
  }

  @visibleForTesting
  static void setTestInstance(VetraDatabase? db) {
    _instance = db;
  }

  // ─── Schema version ────────────────────────────────────────────────────────
  @override
  int get schemaVersion => 1;

  // ─── Migrations ────────────────────────────────────────────────────────────
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        // Create all tables on first install.
        await m.createAll();
        debugPrint('[VetraDatabase] Schema v1 created.');
      },
      onUpgrade: (m, from, to) async {
        // Future migrations will be added here as new schema versions are needed.
        debugPrint('[VetraDatabase] Schema upgrade from v$from → v$to.');
      },
      beforeOpen: (details) async {
        // Enable WAL mode for better concurrent read performance.
        await customStatement('PRAGMA journal_mode=WAL');
        // Enforce foreign key constraints.
        await customStatement('PRAGMA foreign_keys=ON');
        debugPrint(
          '[VetraDatabase] Opened (created=${details.wasCreated}, '
          'version=${details.versionNow}).',
        );
      },
    );
  }

  // ─── Connection factory ────────────────────────────────────────────────────
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'vetra_offline_db');
  }

  // ─── Utility: wipe all local data (for logout / account switch) ─────────
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(animalsTable).go();
      await delete(diseaseReportsTable).go();
      await delete(aiScansTable).go();
      await delete(offlineOperationsTable).go();
      await delete(syncMetadataTable).go();
    });
    debugPrint('[VetraDatabase] All local data cleared.');
  }
}
