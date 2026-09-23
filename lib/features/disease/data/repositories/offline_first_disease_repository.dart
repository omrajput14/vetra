import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/network/network_status_service.dart';
import '../../../../core/offline/models/offline_operation.dart';
import '../../../../core/offline/operation_queue.dart';
import '../../../../core/services/auth_service.dart';
import '../../../animal/data/datasources/animal_local_datasource.dart';
import '../../domain/repositories/disease_repository.dart';
import '../datasources/disease_report_local_datasource.dart';
import '../models/disease_report_dto.dart';
import '../models/outbreak_dto.dart';
import 'disease_repository_impl.dart';

/// Offline-first implementation of [DiseaseRepository].
///
/// Surveillance reports are saved locally to SQLite immediately.
/// If online, the report is submitted to the backend right away.
/// If offline or if submission fails, it is enqueued in [OperationQueue]
/// for sequential synchronization when connectivity returns.
///
/// Invariants:
/// • Outbreak detection & spatial aggregation remain 100% server-side.
/// • If the report targets an animal created offline that is not yet synced,
///   its operation depends on the animal's creation operation.
class OfflineFirstDiseaseRepository implements DiseaseRepository {
  final DiseaseRepositoryImpl _remote;
  final DiseaseReportLocalDatasource _local;
  final AnimalLocalDatasource _animalLocal;
  final OperationQueue _queue;
  final NetworkStatusService _network;

  static const _uuid = Uuid();

  OfflineFirstDiseaseRepository({
    DiseaseRepositoryImpl? remote,
    DiseaseReportLocalDatasource? local,
    AnimalLocalDatasource? animalLocal,
    OperationQueue? queue,
    NetworkStatusService? network,
  })  : _remote = remote ?? DiseaseRepositoryImpl(),
        _local = local ?? DiseaseReportLocalDatasource.instance,
        _animalLocal = animalLocal ?? AnimalLocalDatasource.instance,
        _queue = queue ?? OperationQueue.instance,
        _network = network ?? NetworkStatusService.instance;

  @override
  Future<DiseaseReportModel> createDiseaseReport(CreateDiseaseReportDto dto) async {
    final localId = _uuid.v4();
    final isOnline = await _network.checkNow();

    // Check if the target animal is local-only or already synced
    final bool animalNeedsSync = await _animalLocal.doesAnimalNeedSync(dto.animalId);
    final String? animalServerId = animalNeedsSync ? null : dto.animalId;

    // --- Online path: submit immediately IF animal is already synced ---
    if (isOnline && !animalNeedsSync) {
      try {
        // Same key the queued copy would use, so a timed-out request that did
        // reach the server is not created twice when the queue replays it.
        final serverReport = await _remote.createDiseaseReport(dto, idempotencyKey: localId);
        await _local.insert(
          dto,
          localId: localId,
          animalServerId: dto.animalId,
          syncStatus: 'synced',
        );
        await _local.updateServerId(localId, serverReport.id);
        debugPrint('[OfflineFirstDiseaseRepo] Created disease report online: ${serverReport.id}');
        return serverReport;
      } catch (e) {
        // The server answered and refused the report: show that to the user.
        if (isServerRejection(e)) rethrow;
        debugPrint('[OfflineFirstDiseaseRepo] Server unreachable, queuing offline: $e');
      }
    }

    // --- Offline path / Fallback ---
    await _local.insert(
      dto,
      localId: localId,
      animalServerId: animalServerId,
      syncStatus: 'pendingSync',
    );

    // If animal needs sync, depend on the animal's operationId (which matches animal localId)
    final String? dependsOn = animalNeedsSync ? dto.animalId : null;

    await _queue.enqueue(
      operationId: localId,
      operationType: OfflineOperationType.createDiseaseReport,
      entityType: 'diseaseReport',
      entityLocalId: localId,
      payloadJson: json.encode(dto.toJson()),
      dependsOn: dependsOn,
    );

    debugPrint('[OfflineFirstDiseaseRepo] Queued disease report $localId (dependsOn=$dependsOn)');

    return DiseaseReportModel(
      id: localId,
      animalId: dto.animalId,
      reportedById: AuthService.instance.currentUser?.id ?? '',
      reportedByName: AuthService.instance.currentUser?.name ?? 'You',
      reportSource: dto.reportSource,
      diagnosisConfidenceSource: dto.diagnosisConfidenceSource,
      diseaseName: dto.diseaseName,
      diagnosisStatus: dto.diagnosisStatus,
      latitude: dto.latitude,
      longitude: dto.longitude,
      notes: dto.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPendingSync: true,
    );
  }

  @override
  Future<DiseaseReportModel> getDiseaseReport(String id) async {
    final local = await _local.getByLocalId(id);
    if (local != null) return local;

    if (await _network.checkNow()) {
      return await _remote.getDiseaseReport(id);
    }
    throw Exception('Disease report not found locally and device is offline');
  }

  @override
  Future<List<DiseaseReportModel>> listMyDiseaseReports({int page = 0, int size = 20}) async {
    final localReports = await _local.getAll();
    if (await _network.checkNow()) {
      try {
        final remoteReports = await _remote.listMyDiseaseReports(page: page, size: size);
        return remoteReports;
      } catch (_) {
        return localReports;
      }
    }
    return localReports;
  }

  @override
  Future<List<OutbreakModel>> listOutbreaks({String? status}) async {
    if (await _network.checkNow()) {
      try {
        return await _remote.listOutbreaks(status: status);
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<List<OutbreakModel>> getHighRiskOutbreaks() async {
    if (await _network.checkNow()) {
      try {
        return await _remote.getHighRiskOutbreaks();
      } catch (_) {}
    }
    return [];
  }

  @override
  Future<OutbreakStatisticsModel> getOutbreakStatistics() async {
    if (await _network.checkNow()) {
      return await _remote.getOutbreakStatistics();
    }
    return const OutbreakStatisticsModel(
      totalOutbreaks: 0,
      activeOutbreaks: 0,
      criticalOutbreaks: 0,
      highRiskOutbreaks: 0,
      totalAnimalsAffected: 0,
    );
  }

  @override
  Future<OutbreakModel> getOutbreakById(String id) async {
    if (await _network.checkNow()) {
      return await _remote.getOutbreakById(id);
    }
    throw Exception('Outbreak details require an active internet connection');
  }

  @override
  Future<List<DiseaseReportModel>> getReportsForOutbreak(String id) async {
    if (await _network.checkNow()) {
      return await _remote.getReportsForOutbreak(id);
    }
    return [];
  }

  @override
  Future<List<NearbyReportModel>> searchNearbyReports({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  }) async {
    if (await _network.checkNow()) {
      try {
        return await _remote.searchNearbyReports(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );
      } catch (_) {}
    }
    return [];
  }
}
