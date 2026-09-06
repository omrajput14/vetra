import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/disease_metadata_model.dart';

class DiseaseRegistryNotifier extends ChangeNotifier {
  final Dio _dio;

  DiseaseRegistryNotifier({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Map<String, DiseaseMetadataModel> _registry = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DiseaseMetadataModel> get allDiseases => _registry.values.toList();

  /// Checks whether a disease is marked zoonotic in the authoritative registry.
  bool isZoonotic(String? diseaseName) {
    if (diseaseName == null || diseaseName.trim().isEmpty) return false;
    final clean = diseaseName.trim().toLowerCase();
    for (final entry in _registry.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value.zoonotic;
      }
    }
    // Fallback based on canonical high-consequence zoonoses in Indian veterinary medicine
    if (clean.contains('rabies') ||
        clean.contains('anthrax') ||
        clean.contains('brucellosis') ||
        clean.contains('avian influenza') ||
        clean.contains('bird flu')) {
      return true;
    }
    return false;
  }

  /// Retrieves metadata record for a given disease name.
  DiseaseMetadataModel? getMetadata(String? diseaseName) {
    if (diseaseName == null || diseaseName.trim().isEmpty) return null;
    final clean = diseaseName.trim().toLowerCase();
    for (final entry in _registry.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Fetches disease taxonomy catalog from backend registry.
  Future<void> loadRegistry() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConfig.diseaseRegistry);
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      if (data is List) {
        _registry.clear();
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final model = DiseaseMetadataModel.fromJson(item);
            _registry[model.diseaseName.trim().toLowerCase()] = model;
          }
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      // Initialize known catalog if offline
      _initOfflineFallback();
      notifyListeners();
    }
  }

  void _initOfflineFallback() {
    if (_registry.isNotEmpty) return;
    final defaults = [
      const DiseaseMetadataModel(
        diseaseName: 'Foot and Mouth Disease',
        severity: 'HIGH',
        zoonotic: false,
        reportable: true,
        mortality: 'MEDIUM',
        defaultRadiusKm: 25.0,
        minimumCases: 3,
        evaluationWindowHours: 48,
      ),
      const DiseaseMetadataModel(
        diseaseName: 'Rabies',
        severity: 'CRITICAL',
        zoonotic: true,
        reportable: true,
        mortality: 'VERY_HIGH',
        defaultRadiusKm: 50.0,
        minimumCases: 1,
        evaluationWindowHours: 24,
      ),
      const DiseaseMetadataModel(
        diseaseName: 'Brucellosis',
        severity: 'HIGH',
        zoonotic: true,
        reportable: true,
        mortality: 'MEDIUM',
        defaultRadiusKm: 10.0,
        minimumCases: 5,
        evaluationWindowHours: 168,
      ),
      const DiseaseMetadataModel(
        diseaseName: 'Anthrax',
        severity: 'CRITICAL',
        zoonotic: true,
        reportable: true,
        mortality: 'VERY_HIGH',
        defaultRadiusKm: 30.0,
        minimumCases: 1,
        evaluationWindowHours: 24,
      ),
      const DiseaseMetadataModel(
        diseaseName: 'Avian Influenza',
        severity: 'CRITICAL',
        zoonotic: true,
        reportable: true,
        mortality: 'HIGH',
        defaultRadiusKm: 20.0,
        minimumCases: 2,
        evaluationWindowHours: 48,
      ),
      const DiseaseMetadataModel(
        diseaseName: 'African Swine Fever',
        severity: 'CRITICAL',
        zoonotic: false,
        reportable: true,
        mortality: 'VERY_HIGH',
        defaultRadiusKm: 30.0,
        minimumCases: 2,
        evaluationWindowHours: 48,
      ),
      const DiseaseMetadataModel(
        diseaseName: 'Lumpy Skin Disease',
        severity: 'HIGH',
        zoonotic: false,
        reportable: true,
        mortality: 'MEDIUM',
        defaultRadiusKm: 15.0,
        minimumCases: 3,
        evaluationWindowHours: 72,
      ),
      const DiseaseMetadataModel(
        diseaseName: 'Bovine Mastitis',
        severity: 'MEDIUM',
        zoonotic: false,
        reportable: false,
        mortality: 'LOW',
        defaultRadiusKm: 10.0,
        minimumCases: 5,
        evaluationWindowHours: 72,
      ),
    ];
    for (final d in defaults) {
      _registry[d.diseaseName.trim().toLowerCase()] = d;
    }
  }
}

final diseaseRegistryNotifier = DiseaseRegistryNotifier();
