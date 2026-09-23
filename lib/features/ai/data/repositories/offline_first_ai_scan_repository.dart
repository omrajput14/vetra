import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/network_exceptions.dart';
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
    // One id for this scan: the Idempotency-Key of the online request and the
    // operation id of its queued copy. AI inference can outlast the 35s timeout
    // after the server has saved the scan; the replay then returns that scan
    // instead of creating a second one.
    final localId = _uuid.v4();

    // --- Online Path: try immediate AI inference ---
    if (isOnline && !animalNeedsSync) {
      try {
        final serverScan = await _remote.createScan(
          animalId: animalId,
          imagePath: imagePath,
          idempotencyKey: localId,
        );

        // Save result locally in SQLite
        final permanentPath = await _imageStorage.copyToPermanentStorage(imagePath, serverScan.id);
        await _local.insert(
          localId: serverScan.id,
          animalLocalId: animalId,
          animalServerId: animalId,
          localImagePath: permanentPath,
          status: serverScan.isAnalysisFailure ? 'FAILED' : 'COMPLETED',
          syncStatus: 'synced',
        );

        if (serverScan.isAnalysisFailure) {
          // Record the failure as it is. Never substitute a diagnosis the AI did not make.
          await _local.markAnalysisFailed(
            localId: serverScan.id,
            serverId: serverScan.id,
            rawResultJson: json.encode(serverScan.toJson()),
          );
          return serverScan;
        }

        await _local.updateWithResult(
          localId: serverScan.id,
          serverId: serverScan.id,
          diagnosis: serverScan.diagnosis!,
          confidenceScore: serverScan.confidenceScore,
          severity: serverScan.severity,
          observationsJson: json.encode(serverScan.observations),
          rawResultJson: json.encode(serverScan.toJson()),
        );

        return serverScan;
      } catch (e) {
        // The server answered and refused the scan (400/401/500...): show why.
        if (isServerRejection(e)) rethrow;
        final connectivity = e is NetworkException || e is SocketException || e is DioException;
        if (!connectivity) rethrow; // e.g. unreadable image: not something a retry fixes
        debugPrint('[OfflineFirstAIScanRepo] No answer from server (offline or timed out), queueing: $e');
      }
    }

    // --- Offline Path: copy image, save local entry, enqueue operation ---
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
