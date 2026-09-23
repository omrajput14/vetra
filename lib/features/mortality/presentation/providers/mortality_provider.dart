import "package:flutter/foundation.dart";
import "../../../animal/data/models/animal_dto.dart";
import "../../../animal/presentation/providers/animal_provider.dart";
import "../../data/models/mortality_dto.dart";
import "../../data/repositories/offline_first_mortality_repository.dart";
import "../../domain/repositories/mortality_repository.dart";

class MortalityNotifier extends ChangeNotifier {
  MortalityRepository _repository;

  void setRepository(MortalityRepository repository) {
    _repository = repository;
  }

  MortalityNotifier({MortalityRepository? repository})
      : _repository = repository ?? OfflineFirstMortalityRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isOfflineSaved = false;
  bool _lastReviewQueued = false;
  AnimalModel? _selectedAnimal;
  List<String> _diseaseCatalog = [];
  List<MortalityReportModel> _pendingCases = [];
  List<MortalityAuditDto> _caseAudits = [];
  MortalityReportModel? _selectedCase;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isOfflineSaved => _isOfflineSaved;

  /// The last confirm/reject was saved on this device only (server unreachable).
  bool get lastReviewQueued => _lastReviewQueued;
  AnimalModel? get selectedAnimal => _selectedAnimal;
  List<String> get diseaseCatalog => _diseaseCatalog;
  List<MortalityReportModel> get pendingCases => _pendingCases;
  List<MortalityAuditDto> get caseAudits => _caseAudits;
  MortalityReportModel? get selectedCase => _selectedCase;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setSelectedCase(MortalityReportModel? model) {
    _selectedCase = model;
    notifyListeners();
  }

  Future<void> init({String? preselectedAnimalId}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _isOfflineSaved = false;
    notifyListeners();

    try {
      // 1. Ensure animals list is populated
      if (animalNotifier.animals.isEmpty) {
        await animalNotifier.loadAnimals();
      }

      // 2. Resolve preselected animal if passed
      if (preselectedAnimalId != null && preselectedAnimalId.isNotEmpty) {
        _selectedAnimal = animalNotifier.animals.firstWhere(
          (a) => a.id == preselectedAnimalId,
          orElse: () => animalNotifier.animals.first,
        );
      } else if (animalNotifier.animals.isNotEmpty) {
        _selectedAnimal = animalNotifier.animals.first;
      }

      // 3. Load disease catalog
      await loadDiseaseCatalog();
    } catch (e) {
      debugPrint("[MortalityNotifier] Error during init: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDiseaseCatalog() async {
    try {
      _diseaseCatalog = await _repository.getDiseaseCatalog();
      notifyListeners();
    } catch (e) {
      debugPrint("[MortalityNotifier] Failed to load disease catalog: $e");
    }
  }

  void selectAnimal(AnimalModel animal) {
    _selectedAnimal = animal;
    _errorMessage = null;
    notifyListeners();
  }

  void selectAnimalById(String animalId) {
    final match = animalNotifier.animals.where((a) => a.id == animalId).toList();
    if (match.isNotEmpty) {
      _selectedAnimal = match.first;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> submitMortalityReport(CreateMortalityReportDto dto) async {
    if (_selectedAnimal == null) {
      _errorMessage = "Please select an animal first.";
      notifyListeners();
      return false;
    }

    if (_selectedAnimal!.isDeceased) {
      _errorMessage = "This animal is already marked as deceased.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _isOfflineSaved = false;
    notifyListeners();

    try {
      final result = await _repository.reportMortality(dto);

      if (result.status == "PENDING_SYNC") {
        _isOfflineSaved = true;
        _successMessage = "Saved offline. Report will synchronize automatically when internet returns.";
      } else {
        _isOfflineSaved = false;
        _successMessage = "Animal death reported successfully to veterinary health system.";
      }

      // Refresh animal lists so status update is visible
      await animalNotifier.loadAnimals();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<void> loadPendingCases({int page = 0, int size = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingCases = await _repository.getPendingMortalityCases(page: page, size: size);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmCase(String id, ConfirmMortalityDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.confirmMortality(id, dto);
      _lastReviewQueued = updated.status == "PENDING_SYNC";
      if (_lastReviewQueued) {
        // Not reviewed on the server yet: keep the case as it really is.
        _successMessage = "Saved on this device. The confirmation will be sent when you are back online.";
      } else {
        _pendingCases.removeWhere((c) => c.id == id);
        _selectedCase = updated;
        _successMessage = "Mortality case successfully confirmed.";
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectCase(String id, RejectMortalityDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.rejectMortality(id, dto);
      _lastReviewQueued = updated.status == "PENDING_SYNC";
      if (_lastReviewQueued) {
        _successMessage = "Saved on this device. The rejection will be sent when you are back online.";
      } else {
        _pendingCases.removeWhere((c) => c.id == id);
        _selectedCase = updated;
        _successMessage = "Mortality case rejected.";
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAudits(String id) async {
    try {
      _caseAudits = await _repository.getMortalityAudits(id);
      notifyListeners();
    } catch (e) {
      debugPrint("[MortalityNotifier] Failed to load audits: $e");
      _caseAudits = [];
      notifyListeners();
    }
  }
}

final mortalityNotifier = MortalityNotifier();
