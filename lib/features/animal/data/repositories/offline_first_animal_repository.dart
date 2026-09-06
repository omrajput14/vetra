import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
    final isOnline = await _network.checkNow();

    // --- Online path: try server directly, cache result ---
    if (isOnline) {
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
        debugPrint('[OfflineFirstAnimalRepo] Online create failed, falling back to offline: $e');
      }
    }

    // --- Offline path: generate local UUID, save, queue ---
    final localId = _uuid.v4();
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
    // Try server if online
    if (await _network.checkNow()) {
      try {
        final updated = await _remote.updateAnimal(
          id: id,
          animalName: animalName,
          tagNumber: tagNumber,
          qrCodeId: qrCodeId,
          species: species,
          breed: breed,
          gender: gender,
          birthDate: birthDate,
          photoUrl: photoUrl,
        );
        await _local.upsertAll([updated]);
        return updated;
      } catch (e) {
        debugPrint('[OfflineFirstAnimalRepo] Online update failed: $e');
      }
    }

    // Offline: update local record optimistically
    final existing = await _local.getByLocalId(id) ?? await _local.getByServerId(id);
    final opId = _uuid.v4();
    final serverId = existing?.id; // null for offline-only animals

    final updated = AnimalModel(
      id: id,
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
      createdAt: existing?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    // Re-insert (upsert) the updated record
    await _local.upsertAll([updated]);
    await _local.updateSyncStatus(id, 'pendingSync');

    await _queue.enqueue(
      operationId: opId,
      operationType: OfflineOperationType.updateAnimal,
      entityType: 'animal',
      entityLocalId: id,
      payloadJson: json.encode({
        'serverId': serverId,
        'animalName': animalName,
        'tagNumber': tagNumber,
        'qrCodeId': qrCodeId,
        'species': species.toUpperCase(),
        'breed': breed,
        'gender': gender.toUpperCase(),
        'birthDate': birthDate,
        'photoUrl': photoUrl,
      }),
    );

    return updated;
  }

  // ─── WRITE: delete ────────────────────────────────────────────────────────

  @override
  Future<void> deleteAnimal(String id) async {
    if (await _network.checkNow()) {
      try {
        await _remote.deleteAnimal(id);
        await _local.deleteByLocalId(id);
        return;
      } catch (e) {
        debugPrint('[OfflineFirstAnimalRepo] Online delete failed: $e');
      }
    }

    // Offline: mark as deleted locally; queue deletion
    await _local.updateSyncStatus(id, 'pendingSync');
    await _queue.enqueue(
      operationType: OfflineOperationType.deleteAnimal,
      entityType: 'animal',
      entityLocalId: id,
      payloadJson: json.encode({'localId': id}),
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
