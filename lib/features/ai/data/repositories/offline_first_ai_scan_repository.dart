import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/network_status_service.dart';
import '../../../../core/offline/image_storage_service.dart';
import '../../../../core/offline/models/offline_operation.dart';
import '../../../../core/offline/operation_queue.dart';
import '../../../animal/data/datasources/animal_local_datasource.dart';
import '../../domain/repositories/ai_scan_repository.dart';
import '../datasources/ai_scan_local_datasource.dart';
import '../models/ai_scan_model.dart';
import 'ai_scan_repository_impl.dart';

/// Offline-first implementation of [AIScanRepository].
///
/// Invariants:
/// • AI inference models NEVER execute on device (requires cloud neural networks).
/// • Offline captures store images in permanent app directory and enqueue a sync operation.
/// • Scans in offline mode are placed in PENDING_UPLOAD status.
class OfflineFirstAIScanRepository implements AIScanRepository {
  final AIScanRepositoryImpl _remote;
  final AiScanLocalDatasource _local;
  final AnimalLocalDatasource _animalLocal;
  final ImageStorageService _imageStorage;
  final OperationQueue _queue;
  final NetworkStatusService _network;

  static const _uuid = Uuid();

  OfflineFirstAIScanRepository({
    AIScanRepositoryImpl? remote,
    AiScanLocalDatasource? local,
    AnimalLocalDatasource? animalLocal,
    ImageStorageService? imageStorage,
    OperationQueue? queue,
    NetworkStatusService? network,
  })  : _remote = remote ?? AIScanRepositoryImpl(),
        _local = local ?? AiScanLocalDatasource.instance,
        _animalLocal = animalLocal ?? AnimalLocalDatasource.instance,
        _imageStorage = imageStorage ?? ImageStorageService.instance,
        _queue = queue ?? OperationQueue.instance,
        _network = network ?? NetworkStatusService.instance;

  @override
  Future<AIScanModel> createScan({
    required String animalId,
    required String imagePath,
  }) async {
    final isOnline = await _network.checkNow();
    final bool animalNeedsSync = await _animalLocal.doesAnimalNeedSync(animalId);

    // --- Online Path: try immediate AI inference ---
    if (isOnline && !animalNeedsSync) {
      try {
        final serverScan = await _remote.createScan(
          animalId: animalId,
          imagePath: imagePath,
        );

        // Save result locally in SQLite
        final permanentPath = await _imageStorage.copyToPermanentStorage(imagePath, serverScan.id);
        await _local.insert(
          localId: serverScan.id,
          animalLocalId: animalId,
          animalServerId: animalId,
          localImagePath: permanentPath,
          status: 'COMPLETED',
          syncStatus: 'synced',
        );

        await _local.updateWithResult(
          localId: serverScan.id,
          serverId: serverScan.id,
          diagnosis: serverScan.diagnosis ?? 'Healthy / No Acute Anomalies',
          confidenceScore: serverScan.confidenceScore ?? 0.85,
          severity: serverScan.severity,
          observationsJson: json.encode(serverScan.observations),
          rawResultJson: json.encode(serverScan.toJson()),
        );

        return serverScan;
      } on SocketException catch (e) {
        debugPrint('[OfflineFirstAIScanRepo] Connection dropped during online scan, queueing offline: $e');
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          debugPrint('[OfflineFirstAIScanRepo] Network timeout during online scan, queueing offline: $e');
        } else {
          // Explicit server error (e.g. 400 validation, 401 auth, 500 error)
          debugPrint('[OfflineFirstAIScanRepo] Server rejected scan: ${e.response?.statusCode} ${e.message}');
          rethrow;
        }
      } catch (e) {
        debugPrint('[OfflineFirstAIScanRepo] Online scan unexpected error: $e');
        rethrow;
      }
    }

    // --- Offline Path: copy image, save local entry, enqueue operation ---
    final localId = _uuid.v4();
    final permanentPath = await _imageStorage.copyToPermanentStorage(imagePath, localId);

    await _local.insert(
      localId: localId,
      animalLocalId: animalId,
      animalServerId: animalNeedsSync ? null : animalId,
      localImagePath: permanentPath,
      status: 'PENDING_UPLOAD',
      syncStatus: 'pendingSync',
    );

    final String? dependsOn = animalNeedsSync ? animalId : null;

    await _queue.enqueue(
      operationId: localId,
      operationType: OfflineOperationType.submitAiScan,
      entityType: 'aiScan',
      entityLocalId: localId,
      payloadJson: json.encode({
        'animalId': animalId,
        'localImagePath': permanentPath,
      }),
      dependsOn: dependsOn,
    );

    debugPrint('[OfflineFirstAIScanRepo] Queued offline AI scan $localId (dependsOn=$dependsOn)');

    return AIScanModel(
      id: localId,
      animalId: animalId,
      imageUrl: permanentPath,
      diagnosis: 'Saved locally (Pending Upload)',
      confidenceScore: 0.0,
      severity: 'UNKNOWN',
      observations: const ['Captured offline. Analysis will begin when connected.'],
      status: 'PENDING_UPLOAD',
      recommendedNextStep: 'Connect to internet to submit scan for cloud AI diagnosis.',
      requiresVeterinarianReview: true,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<AIScanModel> getScanById(String scanId) async {
    final local = await _local.getByLocalId(scanId);
    if (local != null) return local;

    if (await _network.checkNow()) {
      return await _remote.getScanById(scanId);
    }

    throw Exception('AI scan not found locally and device is offline');
  }
}
