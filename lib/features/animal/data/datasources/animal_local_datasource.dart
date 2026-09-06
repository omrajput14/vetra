import 'package:drift/drift.dart';
import '../../../../core/database/daos/animal_dao.dart';
import '../../../../core/database/vetra_database.dart';
import '../../../../core/services/auth_service.dart';
import '../models/animal_dto.dart';
import '../models/animal_health_record_dto.dart';

/// Local data source: converts between Drift [AnimalsTableData] rows and
/// the domain-level [AnimalModel] used by the rest of the app.
///
/// Never communicates with the network. All persistence is SQLite-only.
class AnimalLocalDatasource {
  AnimalLocalDatasource._();

  static final AnimalLocalDatasource instance = AnimalLocalDatasource._();

  AnimalDao get _dao => VetraDatabase.instance.animalDao;

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Current farmer/vet ID from the in-memory auth state.
  /// Falls back to empty string if auth is unavailable (e.g. cold start).
  String get _currentUserId =>
      AuthService.instance.currentUser?.id ?? '';

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns all locally cached animals for the authenticated farmer.
  Future<List<AnimalModel>> getAll() async {
    final farmerId = _currentUserId;
    List<AnimalsTableData> rows;
    if (farmerId.isNotEmpty) {
      final farmerRows = await _dao.getAllForFarmer(farmerId);
      if (farmerRows.isNotEmpty) {
        rows = farmerRows;
      } else {
        rows = await _dao.getAll();
      }
    } else {
      rows = await _dao.getAll();
    }

    final seenIds = <String>{};
    final seenTags = <String>{};
    final List<AnimalModel> result = [];
    for (final r in rows) {
      final model = _toModel(r);
      if (seenIds.add(model.id)) {
        if (model.tagNumber.isNotEmpty && !seenTags.add(model.tagNumber)) {
          continue;
        }
        result.add(model);
      }
    }
    return result;
  }

  /// Checks if an animal was created offline and has not yet synced to the server.
  Future<bool> doesAnimalNeedSync(String animalId) async {
    final row = await _dao.getByLocalId(animalId);
    if (row == null) {
      final serverRow = await _dao.getByServerId(animalId);
      if (serverRow == null) return false;
      return serverRow.serverId == null || serverRow.syncStatus == 'pendingSync' || serverRow.syncStatus == 'localOnly';
    }
    return row.serverId == null || row.syncStatus == 'pendingSync' || row.syncStatus == 'localOnly';
  }

  /// Fetches by local UUID.
  Future<AnimalModel?> getByLocalId(String localId) async {
    final row = await _dao.getByLocalId(localId);
    return row != null ? _toModel(row) : null;
  }

  /// Fetches by server UUID.
  Future<AnimalModel?> getByServerId(String serverId) async {
    final row = await _dao.getByServerId(serverId);
    return row != null ? _toModel(row) : null;
  }

  /// Fetches by server UUID or fallback to local UUID.
  Future<AnimalModel?> getById(String id) async {
    final byServer = await getByServerId(id);
    if (byServer != null) return byServer;
    return await getByLocalId(id);
  }

  /// Watches animal list — reactive stream for live UI updates.
  Stream<List<AnimalModel>> watchAll() {
    final farmerId = _currentUserId;
    return _dao
        .watchAllForFarmer(farmerId)
        .map((rows) => rows.map(_toModel).toList());
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  /// Inserts a new animal record created offline.
  Future<void> insert(AnimalModel model) async {
    await _dao.insertAnimal(_toCompanion(model));
  }

  /// Upserts a list of animals pulled from the server (cache refresh).
  Future<void> upsertAll(List<AnimalModel> models) async {
    for (final model in models) {
      await _dao.upsertByServerId(_toServerCompanion(model));
    }
  }

  /// Updates the server ID and marks as synced after SyncEngine confirms.
  Future<void> updateServerId(String localId, String serverId) {
    return _dao.updateServerId(localId, serverId);
  }

  /// Updates sync status for an animal.
  Future<void> updateSyncStatus(String localId, String status) {
    return _dao.updateSyncStatus(localId, status);
  }

  /// Deletes an animal by local ID.
  Future<void> deleteByLocalId(String localId) {
    return _dao.deleteByLocalId(localId);
  }

  /// Updates photo URL for local animal.
  Future<void> updatePhotoUrl(String localId, String photoUrl) {
    return _dao.updatePhotoUrl(localId, photoUrl);
  }

  // ─── Conversions ──────────────────────────────────────────────────────────

  /// Row → domain model.
  /// [localId] is used as [id] for unsynced animals (serverId is null).
  AnimalModel _toModel(AnimalsTableData row) {
    return AnimalModel(
      id: row.serverId ?? row.localId, // expose server ID if available
      farmerId: row.farmerId,
      farmerName: '', // not cached locally — only used in server responses
      animalName: row.animalName,
      tagNumber: row.tagNumber,
      qrCodeId: row.qrCodeId,
      species: row.species,
      breed: row.breed,
      gender: row.gender,
      birthDate: row.birthDate,
      photoUrl: row.photoUrl,
      localPhotoPath: row.localPhotoPath,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt).toIso8601String(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt).toIso8601String(),
    );
  }

  /// Domain model → Drift companion (for locally-created animals).
  AnimalsTableCompanion _toCompanion(AnimalModel model) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return AnimalsTableCompanion(
      localId: Value(model.id),
      serverId: const Value.absent(), // no server ID yet
      farmerId: Value(_currentUserId),
      animalName: Value(model.animalName),
      tagNumber: Value(model.tagNumber),
      qrCodeId: Value(model.qrCodeId),
      species: Value(model.species),
      breed: Value(model.breed),
      gender: Value(model.gender),
      birthDate: Value(model.birthDate),
      photoUrl: Value(model.photoUrl),
      localPhotoPath: Value(model.localPhotoPath),
      syncStatus: const Value('pendingSync'),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }

  /// Server-fetched animal → Drift companion (for upsert-by-serverId).
  AnimalsTableCompanion _toServerCompanion(AnimalModel model) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return AnimalsTableCompanion(
      localId: Value(model.id), // server UUID used as localId for server-known animals
      serverId: Value(model.id),
      farmerId: Value(_currentUserId.isNotEmpty ? _currentUserId : model.farmerId),
      animalName: Value(model.animalName),
      tagNumber: Value(model.tagNumber),
      qrCodeId: Value(model.qrCodeId),
      species: Value(model.species),
      breed: Value(model.breed),
      gender: Value(model.gender),
      birthDate: Value(model.birthDate),
      photoUrl: Value(model.photoUrl),
      localPhotoPath: Value(model.localPhotoPath),
      syncStatus: const Value('synced'),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
  }
}

/// Stub — health records are not cached locally in MVP.
/// Kept here so [OfflineFirstAnimalRepository] compiles against the interface.
class AnimalHealthRecordLocalDatasource {
  Future<List<AnimalHealthRecordModel>> getForAnimal(String animalLocalId) async => [];
}
