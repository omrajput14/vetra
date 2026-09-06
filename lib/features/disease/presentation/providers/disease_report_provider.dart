import 'package:flutter/foundation.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/disease_report_dto.dart';
import '../../data/repositories/offline_first_disease_repository.dart';
import '../../domain/repositories/disease_repository.dart';

class DiseaseReportNotifier extends ChangeNotifier {
  DiseaseRepository _repository;

  DiseaseReportNotifier({DiseaseRepository? repository})
      : _repository = repository ?? OfflineFirstDiseaseRepository();

  void setRepository(DiseaseRepository repository) {
    _repository = repository;
  }

  bool _isSubmitting = false;
  bool _isFetchingLocation = false;
  String? _errorMessage;
  DiseaseReportModel? _lastCreatedReport;
  List<DiseaseReportModel> _myReports = [];
  UserLocationResult? _currentLocation;

  bool get isSubmitting => _isSubmitting;
  bool get isFetchingLocation => _isFetchingLocation;
  String? get errorMessage => _errorMessage;
  DiseaseReportModel? get lastCreatedReport => _lastCreatedReport;
  List<DiseaseReportModel> get myReports => _myReports;
  UserLocationResult? get currentLocation => _currentLocation;

  void clearLastReport() {
    _lastCreatedReport = null;
    _errorMessage = null;
    notifyListeners();
  }

  void setLocation(double latitude, double longitude) {
    _currentLocation = UserLocationResult(
      latitude: latitude,
      longitude: longitude,
    );
    notifyListeners();
  }

  /// Fetches real GPS coordinates via LocationService.
  Future<UserLocationResult?> fetchCurrentLocation() async {
    _isFetchingLocation = true;
    notifyListeners();

    try {
      final loc = await LocationService.instance.getCurrentLocation();
      _currentLocation = loc;
      return loc;
    } catch (e) {
      debugPrint('[DiseaseReportNotifier] Location fetch error: $e');
      return null;
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }

  /// Submits a new disease surveillance report with live animal context, symptoms, and GPS coordinates.
  Future<bool> submitDiseaseReport({
    required String animalId,
    required String diseaseName,
    required double latitude,
    required double longitude,
    List<String> symptoms = const [],
    String? notes,
    String? aiScanId,
    String? medicalRecordId,
  }) async {
    if (_isSubmitting) return false; // Prevent duplicate in-flight submissions

    if (animalId.trim().isEmpty) {
      _errorMessage = 'Please select a registered animal';
      notifyListeners();
      return false;
    }

    if (symptoms.isEmpty && (notes == null || notes.trim().isEmpty)) {
      _errorMessage = 'Please select observed symptoms or provide clinical notes';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final combinedNotes = <String>[];
      if (symptoms.isNotEmpty) {
        combinedNotes.add('Reported Symptoms: ${symptoms.join(', ')}');
      }
      if (notes != null && notes.trim().isNotEmpty) {
        combinedNotes.add('Observations: ${notes.trim()}');
      }

      final dto = CreateDiseaseReportDto(
        animalId: animalId,
        diseaseName: diseaseName.trim(),
        diagnosisStatus: 'SUSPECTED',
        reportSource: 'MANUAL',
        latitude: latitude,
        longitude: longitude,
        notes: combinedNotes.join('\n'),
        aiScanId: aiScanId,
        medicalRecordId: medicalRecordId,
      );

      final report = await _repository.createDiseaseReport(dto);
      _lastCreatedReport = report;
      _myReports = [report, ..._myReports];
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Loads disease reports submitted by the active user.
  Future<void> loadMyReports() async {
    try {
      _myReports = await _repository.listMyDiseaseReports();
      notifyListeners();
    } catch (e) {
      debugPrint('[DiseaseReportNotifier] Load reports error: $e');
    }
  }
}

final diseaseReportNotifier = DiseaseReportNotifier();
