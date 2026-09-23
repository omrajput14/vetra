import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/network/network_status_service.dart';
import '../../../../core/offline/models/offline_operation.dart';
import '../../../../core/offline/operation_queue.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_local_datasource.dart';
import '../models/animal_dto.dart';
import '../models/animal_health_record_dto.dart';
import 'animal_repository_impl.dart';

/// Offline-first implementation of [AnimalRepository].
///
/// Strategy:
/// • READ — returns local SQLite data immediately; refreshes from server in
///   background if backend is reachable (stale-while-revalidate pattern).
/// • WRITE — saves to SQLite first, returns optimistic result, then queues
///   a sync operation. SyncEngine submits it when backend is reachable.
///
/// Existing [AnimalRepositoryImpl] (remote-only) is composed as [_remote].
/// No existing code is modified — this class simply wraps it.
class OfflineFirstAnimalRepository implements AnimalRepository {
  final AnimalRepositoryImpl _remote;
  final AnimalLocalDatasource _local;
  final OperationQueue _queue;
  final NetworkStatusService _network;

  static const _uuid = Uuid();

  OfflineFirstAnimalRepository({
    AnimalRepositoryImpl? remote,
    AnimalLocalDatasource? local,
    OperationQueue? queue,
    NetworkStatusService? network,
  })  : _remote = remote ?? AnimalRepositoryImpl(),
        _local = local ?? AnimalLocalDatasource.instance,
        _queue = queue ?? OperationQueue.instance,
        _network = network ?? NetworkStatusService.instance;

  // ─── READ: list ───────────────────────────────────────────────────────────

  List<AnimalModel> _deduplicateAnimals(List<AnimalModel> list) {
    final seenIds = <String>{};
    final seenTags = <String>{};
    final result = <AnimalModel>[];
    for (final a in list) {
      if (seenIds.add(a.id)) {
        if (a.tagNumber.isNotEmpty && !seenTags.add(a.tagNumber)) {
          continue;
        }
        result.add(a);
      }
    }
    return result;
  }

  @override
  Future<List<AnimalModel>> listAnimals({VoidCallback? onCacheRefreshed}) async {
    // 1. Check local cache first
    var localData = await _local.getAll();

    // 2. If backend is reachable:
    if (await _network.checkNow()) {
      if (localData.isEmpty) {
        // Warm the cache synchronously on initial load so the user does not see
        // an empty state while online.
        try {
          final serverList = await _remote.listAnimals();
          await _local.upsertAll(serverList);
          debugPrint('[OfflineFirstAnimalRepo] Initial cache populated: ${serverList.length} animals');
          onCacheRefreshed?.call();
          return _deduplicateAnimals(serverList);
        } catch (e) {
          debugPrint('[OfflineFirstAnimalRepo] Initial server fetch failed: $e');
        }
      } else {
        // Cache is already warm — refresh in background
        _refreshCacheFromServer(onComplete: onCacheRefreshed);
      }
    }

    return _deduplicateAnimals(localData);
  }

  /// Background refresh: pull fresh list from server, upsert into local cache.
  /// [onComplete] is an optional callback fired after the cache is updated,
  /// allowing the presentation layer to reload without polling.
  void _refreshCacheFromServer({VoidCallback? onComplete}) {
    _remote.listAnimals().then((serverList) async {
      await _local.upsertAll(serverList);
      debugPrint('[OfflineFirstAnimalRepo] Cache refreshed: \${serverList.length} animals');
      onComplete?.call();
    }).catchError((e) {
      debugPrint('[OfflineFirstAnimalRepo] Cache refresh failed: \$e');
    });
  }

  // ─── READ: get by ID ──────────────────────────────────────────────────────

  @override
  Future<AnimalModel> getAnimalById(String id) async {
    // Check local cache first
    final local = await _local.getByLocalId(id) ?? await _local.getByServerId(id);
    if (local != null) return local;

    // Not in cache — fetch from server and cache
    final model = await _remote.getAnimalById(id);
    await _local.upsertAll([model]);
    return model;
  }

  // ─── READ: search ─────────────────────────────────────────────────────────

  @override
  Future<List<AnimalModel>> searchAnimals({
    String? animalName,
    String? tagNumber,
    String? qrCodeId,
    String? species,
    String? breed,
    String? gender,
  }) async {
    // For search: try server first if online; fall back to local list
    if (await _network.checkNow()) {
      try {
        return await _remote.searchAnimals(
          animalName: animalName,
          tagNumber: tagNumber,
          qrCodeId: qrCodeId,
          species: species,
          breed: breed,
          gender: gender,
        );
      } catch (_) {
        // Fall through to local
      }
    }
    // Offline: simple local filter (case-insensitive tag number / name match)
    final all = await _local.getAll();
    return all.where((a) {
      if (tagNumber != null && !a.tagNumber.toLowerCase().contains(tagNumber.toLowerCase())) return false;
      if (animalName != null && a.displayName.toLowerCase().contains(animalName.toLowerCase()) == false) return false;
      if (species != null && a.species.toUpperCase() != species.toUpperCase()) return false;
      return true;
    }).toList();
  }

  // ─── WRITE: create ────────────────────────────────────────────────────────

  @override
  Future<AnimalModel> createAnimal({
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
    String? localPhotoPath,
  }) async {
    // One id for this registration: the Idempotency-Key of the online request and
    // the operation id of its queued copy. A request that timed out after the
    // server saved it is then not created a second time when the queue replays it.
    final localId = _uuid.v4();

    // --- Online path: try server directly, cache result ---
    if (await _network.checkNow()) {
      try {
        var serverModel = await _remote.createAnimal(
          animalName: animalName,
          tagNumber: tagNumber,
          qrCodeId: qrCodeId,
          species: species,
          breed: breed,
          gender: gender,
          birthDate: birthDate,
          photoUrl: photoUrl,
          idempotencyKey: localId,
        );

        if (localPhotoPath != null && localPhotoPath.isNotEmpty) {
          try {
            final photoUrl = await _remote.uploadAnimalPhoto(serverModel.id, localPhotoPath);
            if (photoUrl.isNotEmpty) {
              serverModel = serverModel.copyWith(
                photoUrl: photoUrl,
                localPhotoPath: localPhotoPath,
              );
            }
          } catch (e) {
            debugPrint('[OfflineFirstAnimalRepo] Online photo upload failed: $e');
          }
        }

        // Cache the server response
        await _local.upsertAll([serverModel]);
        debugPrint('[OfflineFirstAnimalRepo] Created online: ${serverModel.id}');
        return serverModel;
      } catch (e) {
        // The server answered and refused it: show why, do not queue.
        if (isServerRejection(e)) rethrow;
        debugPrint('[OfflineFirstAnimalRepo] Server unreachable, saving offline: $e');
      }
    }

    // --- Offline path: save locally, queue with the same id ---
    final now = DateTime.now();

    final optimisticModel = AnimalModel(
      id: localId,
      farmerId: AuthService.instance.currentUser?.id ?? '',
      farmerName: AuthService.instance.currentUser?.name ?? 'You',
      animalName: animalName,
      tagNumber: tagNumber,
      qrCodeId: qrCodeId,
      species: species.toUpperCase(),
      breed: breed,
      gender: gender.toUpperCase(),
      birthDate: birthDate,
      photoUrl: null, // Remote URL is null when offline
      localPhotoPath: localPhotoPath,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
      isPendingSync: true,
    );

    await _local.insert(optimisticModel);

    await _queue.enqueue(
      operationId: localId, // localId IS the idempotency key
      operationType: OfflineOperationType.createAnimal,
      entityType: 'animal',
      entityLocalId: localId,
      payloadJson: json.encode({
        'animalName': animalName,
        'tagNumber': tagNumber,
        'qrCodeId': qrCodeId,
        'species': species.toUpperCase(),
        'breed': breed,
        'gender': gender.toUpperCase(),
        'birthDate': birthDate,
        'photoUrl': null,
        // SyncEngine uploads this photo once the server has created the animal.
        if (localPhotoPath != null && localPhotoPath.isNotEmpty) 'localPhotoPath': localPhotoPath,
      }),
    );

    debugPrint('[OfflineFirstAnimalRepo] Queued offline create: $localId');
    return optimisticModel;
  }

  // ─── WRITE: update ────────────────────────────────────────────────────────

  @override
  Future<AnimalModel> updateAnimal({
    required String id,
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
    String? localPhotoPath,
  }) async {
    final ids = await _local.resolveIds(id);
    // Never synced: the server does not know this animal yet, so the edit has to
    // wait for its pending registration instead of going to an id that does not exist.
    final neverSynced = ids != null && ids.serverId == null;
    // Only a photo picked in this edit is uploaded; the one already on record is not.
    final newPhoto = localPhotoPath != null && localPhotoPath.isNotEmpty && localPhotoPath != ids?.localPhotoPath;

    if (!neverSynced && await _network.checkNow()) {
      final serverId = ids?.serverId ?? id;
      try {
        var updated = await _remote.updateAnimal(
          id: serverId,
          animalName: animalName,
          tagNumber: tagNumber,
          qrCodeId: qrCodeId,
          species: species,
          breed: breed,
          gender: gender,
          birthDate: birthDate,
          photoUrl: photoUrl,
        );
        if (newPhoto) {
          try {
            final uploaded = await _remote.uploadAnimalPhoto(serverId, localPhotoPath);
            if (uploaded.isNotEmpty) {
              updated = updated.copyWith(photoUrl: uploaded, localPhotoPath: localPhotoPath);
            }
          } catch (e) {
            debugPrint('[OfflineFirstAnimalRepo] Online photo upload failed: $e');
          }
        }
        await _local.upsertAll([updated]);
        return updated;
      } catch (e) {
        // The server answered and refused the edit: show why, do not queue.
        if (isServerRejection(e)) rethrow;
        debugPrint('[OfflineFirstAnimalRepo] Server unreachable, saving edit offline: $e');
      }
    }

    // Offline, or not yet on the server: apply the edit locally and queue it.
    final existing = await _local.getById(id);
    final localId = ids?.localId ?? id;

    final updated = AnimalModel(
      id: existing?.id ?? id,
      farmerId: existing?.farmerId ?? '',
      farmerName: existing?.farmerName ?? '',
      animalName: animalName,
      tagNumber: tagNumber,
      qrCodeId: qrCodeId,
      species: species.toUpperCase(),
      breed: breed,
      gender: gender.toUpperCase(),
      birthDate: birthDate,
      photoUrl: photoUrl,
      localPhotoPath: localPhotoPath ?? existing?.localPhotoPath,
      createdAt: existing?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      isPendingSync: true,
    );

    if (ids != null) {
      await _local.applyLocalEdit(localId, updated);
    } else {
      await _local.upsertAll([updated]);
      await _local.updateSyncStatus(localId, 'pendingSync');
    }

    await _queue.enqueue(
      operationId: _uuid.v4(),
      operationType: OfflineOperationType.updateAnimal,
      entityType: 'animal',
      entityLocalId: localId,
      // The create operation's id is the animal's local id.
      dependsOn: neverSynced ? localId : null,
      payloadJson: json.encode({
        // Null until the animal is on the server; SyncEngine resolves it at send time.
        'serverId': ids?.serverId,
        'animalName': animalName,
        'tagNumber': tagNumber,
        'qrCodeId': qrCodeId,
        'species': species.toUpperCase(),
        'breed': breed,
        'gender': gender.toUpperCase(),
        'birthDate': birthDate,
        'photoUrl': photoUrl,
        if (newPhoto) 'localPhotoPath': localPhotoPath,
      }),
    );

    return updated;
  }

  // ─── WRITE: delete ────────────────────────────────────────────────────────

  @override
  Future<void> deleteAnimal(String id) async {
    final ids = await _local.resolveIds(id);
    final neverSynced = ids != null && ids.serverId == null;
    final localId = ids?.localId ?? id;

    if (!neverSynced && await _network.checkNow()) {
      try {
        await _remote.deleteAnimal(ids?.serverId ?? id);
        await _local.deleteByLocalId(localId);
        return;
      } catch (e) {
        // The server answered and refused the delete: show why, do not queue.
        if (isServerRejection(e)) rethrow;
        debugPrint('[OfflineFirstAnimalRepo] Server unreachable, queuing delete: $e');
      }
    }

    // Offline, or not yet on the server: mark it and queue the deletion.
    await _local.updateSyncStatus(localId, 'pendingSync');
    await _queue.enqueue(
      operationType: OfflineOperationType.deleteAnimal,
      entityType: 'animal',
      entityLocalId: localId,
      dependsOn: neverSynced ? localId : null,
      payloadJson: json.encode({'localId': localId}),
    );
  }

  // ─── Health records (delegated to remote — not cached in MVP) ────────────

  @override
  Future<List<AnimalHealthRecordModel>> getAnimalHealthRecords(String animalId) {
    return _remote.getAnimalHealthRecords(animalId);
  }

  @override
  Future<AnimalHealthRecordModel> createHealthRecord(
      String animalId, Map<String, dynamic> body) {
    return _remote.createHealthRecord(animalId, body);
  }

  @override
  Future<AnimalHealthStatusModel> getLatestHealthStatus(String animalId) {
    return _remote.getLatestHealthStatus(animalId);
  }

  @override
  Future<String> uploadAnimalPhoto(String animalId, String filePath) async {
    final photoUrl = await _remote.uploadAnimalPhoto(animalId, filePath);
    if (photoUrl.isNotEmpty) {
      final cached = await _local.getById(animalId);
      if (cached != null) {
        final updated = cached.copyWith(photoUrl: photoUrl, localPhotoPath: filePath);
        await _local.upsertAll([updated]);
      }
    }
    return photoUrl;
  }

  @override
  Future<void> deleteAnimalPhoto(String animalId) async {
    await _remote.deleteAnimalPhoto(animalId);
    final cached = await _local.getById(animalId);
    if (cached != null) {
      final updated = cached.copyWith(photoUrl: null, localPhotoPath: null);
      await _local.upsertAll([updated]);
    }
  }
}
