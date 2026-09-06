import 'package:drift/drift.dart';

/// Offline cache for farmer's animal records.
/// [localId]  — UUID generated on device; stable identity even before sync.
/// [serverId] — populated by SyncEngine after the backend confirms creation.
/// [syncStatus] — one of: localOnly, pendingSync, syncing, synced, failed, conflict.
class AnimalsTable extends Table {
  @override
  String get tableName => 'local_animals';

  /// Device-generated UUID — primary key; never changes.
  TextColumn get localId => text()();

  /// Server-assigned UUID — null until this record is synced successfully.
  TextColumn get serverId => text().nullable()();

  /// UUID of the farmer who owns this animal (from auth token cache).
  TextColumn get farmerId => text()();

  TextColumn get animalName => text().nullable()();
  TextColumn get tagNumber => text()();
  TextColumn get qrCodeId => text().nullable()();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  TextColumn get gender => text()();
  TextColumn get birthDate => text().nullable()();

  /// Remote photo URL (from server response).
  TextColumn get photoUrl => text().nullable()();

  /// Local file path for a photo captured/selected offline before upload.
  TextColumn get localPhotoPath => text().nullable()();

  /// Serialised sync status enum value.
  TextColumn get syncStatus => text().withDefault(const Constant('localOnly'))();

  /// Unix milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Used for optimistic concurrency — incremented by server on update.
  IntColumn get serverVersion => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {localId};
}
