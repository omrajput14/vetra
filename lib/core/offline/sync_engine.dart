import '../../features/mortality/data/api/mortality_api_service.dart';
import '../../features/mortality/data/models/mortality_dto.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/ai/data/api/ai_scan_api_service.dart';
import '../../features/ai/data/datasources/ai_scan_local_datasource.dart';
import '../../features/animal/data/api/animal_api_service.dart';
import '../../features/animal/data/datasources/animal_local_datasource.dart';
import '../../features/disease/data/api/disease_api_service.dart';
import '../../features/disease/data/datasources/disease_report_local_datasource.dart';
import '../../features/disease/data/models/disease_report_dto.dart';
import '../database/vetra_database.dart';
import '../network/network_exceptions.dart';
import '../network/network_status_service.dart';
import 'models/offline_operation.dart';
import 'operation_queue.dart';

/// Sequential synchronization engine.
///
/// Responsibilities:
/// • Processes [OperationQueue] items strictly FIFO.
/// • Guarantees that parent operations (e.g. createAnimal) finish before dependent
///   operations (e.g. createDiseaseReport) execute.
/// • Resolves local client-generated UUIDs into backend PostgreSQL UUIDs before dispatch.
/// • Sends the operation's [idempotencyKey] as `Idempotency-Key` HTTP header.
/// • Only runs when [NetworkStatusService.checkNow] confirms the backend is reachable.
class SyncEngine {
  SyncEngine._();

  static final SyncEngine instance = SyncEngine._();

  final OperationQueue _queue = OperationQueue.instance;
  final NetworkStatusService _network = NetworkStatusService.instance;
  final AnimalApiService _animalApi = AnimalApiService();
  final DiseaseApiService _diseaseApi = DiseaseApiService();
  final AIScanApiService _aiScanApi = AIScanApiService();
  final MortalityApiService _mortalityApi = MortalityApiService();
  final AnimalLocalDatasource _animalLocal = AnimalLocalDatasource.instance;
  final DiseaseReportLocalDatasource _diseaseLocal = DiseaseReportLocalDatasource.instance;
  final AiScanLocalDatasource _aiLocal = AiScanLocalDatasource.instance;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  final ValueNotifier<bool> syncingNotifier = ValueNotifier<bool>(false);

  /// Configurable throttle delay between sequential operations during queue drains
  /// to avoid network congestion and battery drain on unstable rural connections.
  Duration interOperationDelay = const Duration(milliseconds: 300);

  /// Executes a full synchronization cycle.
  Future<void> runSync() async {
    if (_isSyncing) {
      debugPrint('[SyncEngine] Sync already in progress, skipping cycle.');
      return;
    }

    // Step 1: Verify real backend reachability before starting
    final isReachable = await _network.checkNow();
    if (!isReachable) {
      debugPrint('[SyncEngine] Backend not reachable — sync postponed.');
      return;
    }

    _isSyncing = true;
    syncingNotifier.value = true;
    debugPrint('[SyncEngine] Starting sync cycle...');

    try {
      // Step 2: Recover any processing operations left behind by previous crashes
      await _queue.resetAllProcessing();

      // Step 3: Sequential FIFO queue processing loop
      while (true) {
        final op = await _queue.peekNext();
        if (op == null) {
          debugPrint('[SyncEngine] Queue is empty — sync cycle complete.');
          break;
        }

        // Check if backend is still reachable before each operation
        if (!await _network.checkNow()) {
          debugPrint('[SyncEngine] Network lost during sync — pausing queue.');
          break;
        }

        // Verify parent dependency if present
        if (op.dependsOn != null) {
          final parent = await _queue.getById(op.dependsOn!);
          if (parent != null && parent.status != OperationStatus.completed) {
            debugPrint('[SyncEngine] Operation ${op.operationId} depends on uncompleted ${op.dependsOn} (${parent.status}) — waiting.');
            break;
          }
        }

        await _processSingleOperation(op);

        // Throttle briefly between operations to pace network/CPU load
        if (interOperationDelay > Duration.zero) {
          await Future.delayed(interOperationDelay);
        }
      }
    } catch (e, st) {
      debugPrint('[SyncEngine] Unhandled sync loop error: $e\n$st');
    } finally {
      _isSyncing = false;
      syncingNotifier.value = false;
    }
  }

  Future<void> _processSingleOperation(OfflineOperation op) async {
    debugPrint('[SyncEngine] Processing ${op.operationType} (id=${op.operationId})...');
    await _queue.markAsProcessing(op.operationId);

    try {
      switch (op.operationType) {
        case OfflineOperationType.createAnimal:
          await _syncCreateAnimal(op);
          break;
        case OfflineOperationType.updateAnimal:
          await _syncUpdateAnimal(op);
          break;
        case OfflineOperationType.deleteAnimal:
          await _syncDeleteAnimal(op);
          break;
        case OfflineOperationType.createDiseaseReport:
          await _syncCreateDiseaseReport(op);
          break;
        case OfflineOperationType.submitAiScan:
          await _syncSubmitAiScan(op);
          break;
        case OfflineOperationType.reportMortality:
          await _syncReportMortality(op);
          break;
        case OfflineOperationType.confirmMortality:
          await _syncConfirmMortality(op);
          break;
        case OfflineOperationType.rejectMortality:
          await _syncRejectMortality(op);
          break;
      }

      await _queue.markCompleted(op.operationId);
      debugPrint('[SyncEngine] Successfully synced ${op.operationType} (${op.operationId})');
    } on NetworkException catch (e) {
      debugPrint('[SyncEngine] Network exception on ${op.operationId}: ${e.message}');
      await _queue.markFailed(op.operationId, e.message);
    } on DioException catch (e) {
      debugPrint('[SyncEngine] Dio exception on ${op.operationId}: ${e.message}');
      await _queue.markFailed(op.operationId, e.message ?? 'Network error');
    } catch (e) {
      debugPrint('[SyncEngine] Unexpected error on ${op.operationId}: $e');
      await _queue.markFailed(op.operationId, e.toString());
    }
  }

  // ─── Operation Handlers ───────────────────────────────────────────────────

  Future<void> _syncCreateAnimal(OfflineOperation op) async {
    final payload = json.decode(op.payloadJson) as Map<String, dynamic>;
    final localPhotoPath = payload.remove('localPhotoPath') as String?;

    final response = await _animalApi.createAnimal(
      payload,
      idempotencyKey: op.idempotencyKey,
    );

    final serverData = response['data'] as Map<String, dynamic>;
    final serverId = serverData['id'].toString();

    // 1. Update local animal record with permanent server ID
    await _animalLocal.updateServerId(op.entityLocalId, serverId);
    await _animalLocal.updateSyncStatus(op.entityLocalId, 'synced');

    // 1b. If local photo exists, upload it and update local photoUrl
    if (localPhotoPath != null && localPhotoPath.isNotEmpty) {
      final file = File(localPhotoPath);
      if (await file.exists()) {
        try {
          final uploadRes = await _animalApi.uploadAnimalPhoto(serverId, localPhotoPath);
          final uploadedPhotoUrl = uploadRes['data']?['photoUrl']?.toString();
          if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
            await _animalLocal.updatePhotoUrl(op.entityLocalId, uploadedPhotoUrl);
          }
        } catch (e) {
          debugPrint('[SyncEngine] Failed to upload animal photo during sync: $e');
        }
      }
    }

    // 2. Cascade server ID to any local disease reports waiting for this animal
    await _diseaseLocal.updateAnimalServerId(op.entityLocalId, serverId);

    // 3. Cascade server ID to any local AI scans waiting for this animal
    await VetraDatabase.instance.aiScanDao.updateAnimalServerId(op.entityLocalId, serverId);
  }

  Future<void> _syncUpdateAnimal(OfflineOperation op) async {
    final payload = json.decode(op.payloadJson) as Map<String, dynamic>;
    var serverId = payload['serverId'] as String?;

    if (serverId == null || serverId.isEmpty) {
      final localRow = await VetraDatabase.instance.animalDao.getByLocalId(op.entityLocalId);
      serverId = localRow?.serverId;
    }

    if (serverId == null || serverId.isEmpty) {
      throw Exception('Cannot update animal without valid serverId');
    }

    payload.remove('serverId');
    final localPhotoPath = payload.remove('localPhotoPath') as String?;

    await _animalApi.updateAnimal(serverId, payload);
    await _animalLocal.updateSyncStatus(op.entityLocalId, 'synced');

    if (localPhotoPath != null && localPhotoPath.isNotEmpty) {
      final file = File(localPhotoPath);
      if (await file.exists()) {
        try {
          final uploadRes = await _animalApi.uploadAnimalPhoto(serverId, localPhotoPath);
          final uploadedPhotoUrl = uploadRes['data']?['photoUrl']?.toString();
          if (uploadedPhotoUrl != null && uploadedPhotoUrl.isNotEmpty) {
            await _animalLocal.updatePhotoUrl(op.entityLocalId, uploadedPhotoUrl);
          }
        } catch (e) {
          debugPrint('[SyncEngine] Failed to upload animal photo during sync update: $e');
        }
      }
    }
  }

  Future<void> _syncDeleteAnimal(OfflineOperation op) async {
    final localRow = await VetraDatabase.instance.animalDao.getByLocalId(op.entityLocalId);
    final serverId = localRow?.serverId;

    if (serverId != null && serverId.isNotEmpty) {
      await _animalApi.deleteAnimal(serverId);
    }
    await _animalLocal.deleteByLocalId(op.entityLocalId);
  }

  Future<void> _syncCreateDiseaseReport(OfflineOperation op) async {
    final payload = json.decode(op.payloadJson) as Map<String, dynamic>;
    final originalAnimalId = payload['animalId'] as String;

    // Resolve local animal UUID -> server UUID
    var targetAnimalId = originalAnimalId;
    final localRow = await VetraDatabase.instance.animalDao.getByLocalId(originalAnimalId);
    if (localRow != null) {
      if (localRow.serverId != null && localRow.serverId!.isNotEmpty) {
        targetAnimalId = localRow.serverId!;
      } else {
        throw Exception('Cannot sync disease report: linked animal $originalAnimalId has not yet been assigned a server UUID.');
      }
    }

    final dto = CreateDiseaseReportDto(
      animalId: targetAnimalId,
      diseaseName: payload['diseaseName'] ?? 'Suspected Condition',
      diagnosisStatus: payload['diagnosisStatus'] ?? 'SUSPECTED',
      reportSource: payload['reportSource'] ?? 'MANUAL',
      diagnosisConfidenceSource: payload['diagnosisConfidenceSource'],
      latitude: (payload['latitude'] as num).toDouble(),
      longitude: (payload['longitude'] as num).toDouble(),
      notes: payload['notes'],
      medicalRecordId: payload['medicalRecordId'],
      aiScanId: payload['aiScanId'],
    );

    final serverReport = await _diseaseApi.createDiseaseReport(
      dto,
      idempotencyKey: op.idempotencyKey,
    );

    await _diseaseLocal.updateServerId(op.entityLocalId, serverReport.id);
    await _diseaseLocal.updateSyncStatus(op.entityLocalId, 'synced');
  }

  Future<void> _syncSubmitAiScan(OfflineOperation op) async {
    final payload = json.decode(op.payloadJson) as Map<String, dynamic>;
    final localImagePath = payload['localImagePath'] as String;
    final originalAnimalId = payload['animalId'] as String;

    final file = File(localImagePath);
    if (!await file.exists()) {
      throw Exception('Local image file $localImagePath not found on device.');
    }

    // Resolve local animal UUID -> server UUID
    var targetAnimalId = originalAnimalId;
    final localRow = await VetraDatabase.instance.animalDao.getByLocalId(originalAnimalId);
    if (localRow != null) {
      if (localRow.serverId != null && localRow.serverId!.isNotEmpty) {
        targetAnimalId = localRow.serverId!;
      } else {
        throw Exception('Cannot sync AI scan: linked animal $originalAnimalId has not yet been assigned a server UUID.');
      }
    }

    final result = await _aiScanApi.createScan(
      animalId: targetAnimalId,
      imagePath: localImagePath,
      idempotencyKey: op.idempotencyKey,
    );

    await _aiLocal.updateWithResult(
      localId: op.entityLocalId,
      serverId: result.id,
      diagnosis: result.diagnosis ?? 'Preliminary AI Scan',
      confidenceScore: result.confidenceScore ?? 0.0,
      severity: result.severity,
      observationsJson: json.encode(result.observations),
      rawResultJson: json.encode(result.toJson()),
    );
  }

  Future<void> _syncReportMortality(OfflineOperation op) async {
    final payload = json.decode(op.payloadJson) as Map<String, dynamic>;
    final originalAnimalId = payload['animalId'] as String;

    // Resolve local animal UUID -> server UUID
    var targetAnimalId = originalAnimalId;
    final localRow = await VetraDatabase.instance.animalDao.getByLocalId(originalAnimalId);
    if (localRow != null) {
      if (localRow.serverId != null && localRow.serverId!.isNotEmpty) {
        targetAnimalId = localRow.serverId!;
      } else {
        throw Exception('Cannot sync mortality report: linked animal $originalAnimalId has not yet been assigned a server UUID.');
      }
    }

    final dto = CreateMortalityReportDto(
      animalId: targetAnimalId,
      causeCategory: payload['causeCategory'] ?? 'UNKNOWN',
      causeDescription: payload['causeDescription'],
      diseaseName: payload['diseaseName'],
      recentlyTreated: payload['recentlyTreated'] == true,
      treatmentNotes: payload['treatmentNotes'],
      notes: payload['notes'],
      deathDateTime: payload['deathDateTime'],
      latitude: payload['latitude'] != null ? (payload['latitude'] as num).toDouble() : null,
      longitude: payload['longitude'] != null ? (payload['longitude'] as num).toDouble() : null,
      locationAccuracy: payload['locationAccuracy'] != null ? (payload['locationAccuracy'] as num).toDouble() : null,
    );

    await _mortalityApi.reportMortality(
      dto,
      idempotencyKey: op.idempotencyKey,
    );
  }

  Future<void> _syncConfirmMortality(OfflineOperation op) async {
    final payload = json.decode(op.payloadJson) as Map<String, dynamic>;
    final dto = ConfirmMortalityDto.fromJson(payload);
    await _mortalityApi.confirmMortality(
      op.entityLocalId,
      dto,
      idempotencyKey: op.idempotencyKey,
    );
  }

  Future<void> _syncRejectMortality(OfflineOperation op) async {
    final payload = json.decode(op.payloadJson) as Map<String, dynamic>;
    final dto = RejectMortalityDto.fromJson(payload);
    await _mortalityApi.rejectMortality(
      op.entityLocalId,
      dto,
      idempotencyKey: op.idempotencyKey,
    );
  }
}
