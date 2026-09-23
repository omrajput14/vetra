import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/network_exceptions.dart';
import '../../../../core/network/network_status_service.dart';
import '../../../../core/offline/models/offline_operation.dart';
import '../../../../core/offline/operation_queue.dart';
import '../../../animal/data/datasources/animal_local_datasource.dart';
import '../../../animal/presentation/providers/animal_provider.dart';
import '../../domain/repositories/mortality_repository.dart';
import '../api/mortality_api_service.dart';
import '../models/mortality_dto.dart';

class OfflineFirstMortalityRepository implements MortalityRepository {
  final MortalityApiService _api;
  final AnimalLocalDatasource _animalLocal;
  final OperationQueue _queue;
  final NetworkStatusService _network;

  static const _uuid = Uuid();

  OfflineFirstMortalityRepository({
    MortalityApiService? api,
    AnimalLocalDatasource? animalLocal,
    OperationQueue? queue,
    NetworkStatusService? network,
  })  : _api = api ?? MortalityApiService(),
        _animalLocal = animalLocal ?? AnimalLocalDatasource.instance,
        _queue = queue ?? OperationQueue.instance,
        _network = network ?? NetworkStatusService.instance;

  @override
  Future<MortalityReportModel> reportMortality(CreateMortalityReportDto dto) async {
    final localId = _uuid.v4();
    final isOnline = await _network.checkNow();

    // Check if target animal is local-only or already synced
    final bool animalNeedsSync = await _animalLocal.doesAnimalNeedSync(dto.animalId);

    // --- Online path: submit immediately if animal is already synced ---
    if (isOnline && !animalNeedsSync) {
      try {
        final serverReport = await _api.reportMortality(
          dto,
          idempotencyKey: localId,
        );
        animalNotifier.markAnimalDeceased(dto.animalId);
        debugPrint('[OfflineFirstMortalityRepo] Reported mortality online: ${serverReport.id}');
        return serverReport;
      } catch (e) {
        // The server answered and refused the report: show that to the user.
        if (isServerRejection(e)) rethrow;
        debugPrint('[OfflineFirstMortalityRepo] Server unreachable, falling back to queue: $e');
      }
    }

    // --- Offline path / Fallback ---
    final String? dependsOn = animalNeedsSync ? dto.animalId : null;

    await _queue.enqueue(
      operationId: localId,
      operationType: OfflineOperationType.reportMortality,
      entityType: 'mortality',
      entityLocalId: localId,
      payloadJson: json.encode(dto.toJson()),
      dependsOn: dependsOn,
    );

    // Optimistically mark deceased locally so farmer immediately sees state change
    animalNotifier.markAnimalDeceased(dto.animalId);
    debugPrint('[OfflineFirstMortalityRepo] Queued mortality report $localId (dependsOn=$dependsOn)');

    return MortalityReportModel(
      id: localId,
      animalId: dto.animalId,
      tagNumber: 'OFFLINE',
      causeCategory: dto.causeCategory,
      causeDescription: dto.causeDescription,
      diseaseName: dto.diseaseName,
      recentlyTreated: dto.recentlyTreated,
      treatmentNotes: dto.treatmentNotes,
      notes: dto.notes,
      source: 'FARMER_REPORTED',
      status: 'PENDING_SYNC',
      deathDateTime: dto.deathDateTime,
      reportedAt: DateTime.now().toUtc().toIso8601String(),
      latitude: dto.latitude,
      longitude: dto.longitude,
      locationAccuracy: dto.locationAccuracy,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<MortalityReportModel> getMortalityById(String id) async {
    return await _api.getMortalityById(id);
  }

  @override
  Future<MortalityReportModel> getMortalityByAnimalId(String animalId) async {
    return await _api.getMortalityByAnimalId(animalId);
  }

  @override
  Future<List<MortalityReportModel>> listFarmerMortalities({int page = 0, int size = 20}) async {
    return await _api.listFarmerMortalities(page: page, size: size);
  }

  @override
  Future<List<String>> getDiseaseCatalog() async {
    return await _api.getDiseaseCatalog();
  }

  @override
  Future<List<MortalityReportModel>> getPendingMortalityCases({int page = 0, int size = 20}) async {
    return await _api.getPendingMortalityCases(page: page, size: size);
  }

  @override
  Future<MortalityReportModel> confirmMortality(String id, ConfirmMortalityDto dto) async {
    final localId = _uuid.v4();
    final isOnline = await _network.checkNow();

    if (isOnline) {
      try {
        final res = await _api.confirmMortality(id, dto, idempotencyKey: localId);
        return res;
      } catch (e) {
        if (isServerRejection(e)) rethrow;
        debugPrint("[OfflineFirstMortalityRepo] Server unreachable, queuing confirm: $e");
      }
    }

    await _queue.enqueue(
      operationId: localId,
      operationType: OfflineOperationType.confirmMortality,
      entityType: "mortality",
      entityLocalId: id,
      payloadJson: json.encode(dto.toJson()),
    );

    return MortalityReportModel(
      id: id,
      animalId: "",
      tagNumber: "",
      causeCategory: dto.causeCategory,
      diseaseName: dto.diseaseName,
      status: "PENDING_SYNC",
      source: "VETERINARIAN",
      vetCauseCategory: dto.causeCategory,
      vetDiseaseName: dto.diseaseName,
      vetClinicalNotes: dto.clinicalNotes,
      postMortemConducted: dto.postMortemConducted,
      reportedAt: DateTime.now().toUtc().toIso8601String(),
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<MortalityReportModel> rejectMortality(String id, RejectMortalityDto dto) async {
    final localId = _uuid.v4();
    final isOnline = await _network.checkNow();

    if (isOnline) {
      try {
        final res = await _api.rejectMortality(id, dto, idempotencyKey: localId);
        return res;
      } catch (e) {
        if (isServerRejection(e)) rethrow;
        debugPrint("[OfflineFirstMortalityRepo] Server unreachable, queuing reject: $e");
      }
    }

    await _queue.enqueue(
      operationId: localId,
      operationType: OfflineOperationType.rejectMortality,
      entityType: "mortality",
      entityLocalId: id,
      payloadJson: json.encode(dto.toJson()),
    );

    return MortalityReportModel(
      id: id,
      animalId: "",
      tagNumber: "",
      causeCategory: "UNKNOWN",
      status: "PENDING_SYNC",
      source: "VETERINARIAN",
      vetRejectionReason: dto.rejectionReason,
      vetClinicalNotes: dto.clinicalNotes,
      reportedAt: DateTime.now().toUtc().toIso8601String(),
      createdAt: DateTime.now().toUtc().toIso8601String(),
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<List<MortalityAuditDto>> getMortalityAudits(String id) async {
    return await _api.getMortalityAudits(id);
  }
}
