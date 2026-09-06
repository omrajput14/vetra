import 'package:drift/drift.dart';
import '../tables/animals_table.dart';
import '../vetra_database.dart';

part 'animal_dao.g.dart';

@DriftAccessor(tables: [AnimalsTable])
class AnimalDao extends DatabaseAccessor<VetraDatabase> with _$AnimalDaoMixin {
  AnimalDao(super.db);

  /// Returns all animals for a given farmer, ordered by most recently updated.
  Future<List<AnimalsTableData>> getAllForFarmer(String farmerId) {
    return (select(animalsTable)
          ..where((t) => t.farmerId.equals(farmerId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  /// Returns all animals (for vet role or admin debugging).
  Future<List<AnimalsTableData>> getAll() {
    return (select(animalsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  /// Fetches a single animal by its local UUID.
  Future<AnimalsTableData?> getByLocalId(String localId) {
    return (select(animalsTable)..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
  }

  /// Fetches a single animal by its server-assigned UUID.
  Future<AnimalsTableData?> getByServerId(String serverId) {
    return (select(animalsTable)..where((t) => t.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  /// Inserts a new animal record. Throws if localId already exists.
  Future<void> insertAnimal(AnimalsTableCompanion animal) {
    return into(animalsTable).insert(animal);
  }

  /// Upserts an animal — used by SyncEngine when populating server data.
  /// If a record with the same localId exists, it is replaced.
  Future<void> upsertAnimal(AnimalsTableCompanion animal) {
    return into(animalsTable)
        .insertOnConflictUpdate(animal);
  }

  /// Upsert by serverId — used when pulling fresh data from the server.
  /// Matches on server UUID; updates if found, inserts otherwise.
  Future<void> upsertByServerId(AnimalsTableCompanion animal) async {
    final existing = animal.serverId.value != null
        ? await getByServerId(animal.serverId.value!)
        : null;

    if (existing != null) {
      await (update(animalsTable)
            ..where((t) => t.serverId.equals(existing.serverId!)))
          .write(animal);
    } else {
      await into(animalsTable).insertOnConflictUpdate(animal);
    }
  }

  /// Updates the server-assigned UUID after a successful sync.
  Future<void> updateServerId(String localId, String serverId) {
    return (update(animalsTable)..where((t) => t.localId.equals(localId)))
        .write(AnimalsTableCompanion(
          serverId: Value(serverId),
          syncStatus: const Value('synced'),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Updates the sync status of an animal.
  Future<void> updateSyncStatus(String localId, String status) {
    return (update(animalsTable)..where((t) => t.localId.equals(localId)))
        .write(AnimalsTableCompanion(
          syncStatus: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }

  /// Returns all animals with pending sync operations.
  Future<List<AnimalsTableData>> getPendingSync() {
    return (select(animalsTable)
          ..where((t) =>
              t.syncStatus.equals('localOnly') |
              t.syncStatus.equals('pendingSync')))
        .get();
  }

  /// Permanently deletes an animal from local storage.
  Future<int> deleteByLocalId(String localId) {
    return (delete(animalsTable)..where((t) => t.localId.equals(localId)))
        .go();
  }

  /// Watches the animal list for a farmer — emits on any change.
  Stream<List<AnimalsTableData>> watchAllForFarmer(String farmerId) {
    return (select(animalsTable)
          ..where((t) => t.farmerId.equals(farmerId))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Updates the remote photo URL and sync status for an animal.
  Future<void> updatePhotoUrl(String localId, String photoUrl) {
    return (update(animalsTable)..where((t) => t.localId.equals(localId)))
        .write(AnimalsTableCompanion(
          photoUrl: Value(photoUrl),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }
}