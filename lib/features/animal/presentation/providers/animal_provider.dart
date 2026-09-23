import 'package:flutter/foundation.dart';
import '../../data/models/animal_dto.dart';
import '../../data/models/animal_health_record_dto.dart';
import '../../data/repositories/offline_first_animal_repository.dart';
import '../../domain/repositories/animal_repository.dart';

class AnimalNotifier extends ChangeNotifier {
  AnimalRepository _repository;

  AnimalNotifier({AnimalRepository? repository}) : _repository = repository ?? OfflineFirstAnimalRepository();

  void setRepository(AnimalRepository repository) {
    _repository = repository;
  }

  List<AnimalModel> _animals = [];
  String? _selectedAnimalId;
  bool _isLoading = false;
  String? _errorMessage;

  // BUG 3 FIX: tracks whether the background server refresh has completed
  // at least once. My Animals page uses this to distinguish "still syncing"
  // from "confirmed empty" so it shows the right empty state.
  bool _hasFetchedFromServer = false;

  /// The last create/edit was saved on this device only (server unreachable).
  bool _lastSaveQueued = false;
  bool get lastSaveQueued => _lastSaveQueued;

  final Map<String, List<AnimalHealthRecordModel>> _healthTimelines = {};
  final Map<String, AnimalHealthStatusModel> _healthStatuses = {};
  bool _isTimelineLoading = false;

  List<AnimalModel> get animals => _animals;
  String? get selectedAnimalId => _selectedAnimalId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasFetchedFromServer => _hasFetchedFromServer;

  void setSelectedAnimalId(String? id) {
    _selectedAnimalId = id;
    notifyListeners();
  }

  Map<String, List<AnimalHealthRecordModel>> get healthTimelines => _healthTimelines;
  Map<String, AnimalHealthStatusModel> get healthStatuses => _healthStatuses;
  bool get isTimelineLoading => _isTimelineLoading;

  List<AnimalHealthRecordModel> getTimeline(String animalId) => _healthTimelines[animalId] ?? [];
  AnimalHealthStatusModel? getStatus(String animalId) => _healthStatuses[animalId];

  Future<void> loadTimeline(String animalId) async {
    _isTimelineLoading = true;
    notifyListeners();
    try {
      final records = await _repository.getAnimalHealthRecords(animalId);
      _healthTimelines[animalId] = records;
    } catch (e) {
      _healthTimelines[animalId] = _healthTimelines[animalId] ?? [];
    } finally {
      _isTimelineLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHealthStatus(String animalId) async {
    try {
      final status = await _repository.getLatestHealthStatus(animalId);
      _healthStatuses[animalId] = status;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addHealthRecord(String animalId, Map<String, dynamic> body) async {
    try {
      final record = await _repository.createHealthRecord(animalId, body);
      final currentList = _healthTimelines[animalId] ?? [];
      _healthTimelines[animalId] = [record, ...currentList];
      await loadHealthStatus(animalId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAnimals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Pass a callback so that after the background server refresh completes,
      // the notifier automatically reloads from local cache and notifies UI.
      // This fixes the "animals not visible after creation" bug caused by the
      // stale-while-revalidate background refresh not updating the UI.
      _animals = await (_repository as dynamic).listAnimals(
        onCacheRefreshed: _onBackgroundRefreshComplete,
      );
    } catch (_) {
      // If the repository does not support the optional callback (e.g. mocks),
      // fall back to the base interface call.
      try {
        _animals = await _repository.listAnimals();
        _hasFetchedFromServer = true;
      } catch (e) {
        _errorMessage = e.toString();
      }
    }
    if (_selectedAnimalId == null && _animals.isNotEmpty) {
      _selectedAnimalId = _animals.first.id;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Called by OfflineFirstAnimalRepository after the background cache refresh.
  /// BUG 3 FIX: sets hasFetchedFromServer = true so the Animals page can
  /// distinguish "still loading from server" vs "truly no animals registered".
  Future<void> _onBackgroundRefreshComplete() async {
    try {
      _animals = await _repository.listAnimals();
      if (_selectedAnimalId == null && _animals.isNotEmpty) {
        _selectedAnimalId = _animals.first.id;
      }
      _hasFetchedFromServer = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> searchAnimals({
    String? animalName,
    String? tagNumber,
    String? species,
    String? breed,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _animals = await _repository.searchAnimals(
        animalName: animalName,
        tagNumber: tagNumber,
        species: species,
        breed: breed,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAnimal({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final animal = await _repository.createAnimal(
        animalName: animalName,
        tagNumber: tagNumber,
        qrCodeId: qrCodeId,
        species: species,
        breed: breed,
        gender: gender,
        birthDate: birthDate,
        photoUrl: photoUrl,
        localPhotoPath: localPhotoPath,
      );
      _lastSaveQueued = animal.isPendingSync;
      _animals.insert(0, animal);
      _selectedAnimalId = animal.id;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAnimal({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.updateAnimal(
        id: id,
        animalName: animalName,
        tagNumber: tagNumber,
        qrCodeId: qrCodeId,
        species: species,
        breed: breed,
        gender: gender,
        birthDate: birthDate,
        photoUrl: photoUrl,
        localPhotoPath: localPhotoPath,
      );
      _lastSaveQueued = updated.isPendingSync;
      final index = _animals.indexWhere((a) => a.id == id);
      if (index != -1) _animals[index] = updated;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAnimal(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteAnimal(id);
      _animals.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markAnimalDeceased(String animalId) {
    final idx = _animals.indexWhere((a) => a.id == animalId);
    if (idx != -1) {
      _animals[idx] = _animals[idx].copyWith(status: 'DECEASED');
      notifyListeners();
    }
  }

  Future<AnimalModel?> fetchAnimalById(String id) async {
    final existingIndex = _animals.indexWhere((a) => a.id == id);
    if (existingIndex != -1) {
      _selectedAnimalId = id;
      return _animals[existingIndex];
    }
    try {
      final animal = await _repository.getAnimalById(id);
      _animals.insert(0, animal);
      _selectedAnimalId = animal.id;
      notifyListeners();
      return animal;
    } catch (_) {
      return null;
    }
  }

  Future<AnimalModel?> lookupAnimalByQr(String rawScannedCode) async {
    final query = rawScannedCode.trim();
    if (query.isEmpty) return null;
    final lowerQuery = query.toLowerCase();

    // 1. Check in-memory list first
    for (final a in _animals) {
      if ((a.qrCodeId != null && a.qrCodeId!.toLowerCase() == lowerQuery) ||
          a.tagNumber.toLowerCase() == lowerQuery ||
          a.id.toLowerCase() == lowerQuery) {
        _selectedAnimalId = a.id;
        notifyListeners();
        return a;
      }
    }

    // 2. Search backend by QR Code ID
    try {
      final resultsByQr = await _repository.searchAnimals(qrCodeId: query);
      if (resultsByQr.isNotEmpty) {
        final match = resultsByQr.first;
        final idx = _animals.indexWhere((a) => a.id == match.id);
        if (idx == -1) { _animals.insert(0, match); } else { _animals[idx] = match; }
        _selectedAnimalId = match.id;
        notifyListeners();
        return match;
      }
    } catch (_) {}

    // 3. Search backend by Tag Number
    try {
      final resultsByTag = await _repository.searchAnimals(tagNumber: query);
      if (resultsByTag.isNotEmpty) {
        final match = resultsByTag.first;
        final idx = _animals.indexWhere((a) => a.id == match.id);
        if (idx == -1) { _animals.insert(0, match); } else { _animals[idx] = match; }
        _selectedAnimalId = match.id;
        notifyListeners();
        return match;
      }
    } catch (_) {}

    // 4. Try direct UUID lookup
    final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(query);
    if (isUuid) {
      try {
        final animal = await _repository.getAnimalById(query);
        final idx = _animals.indexWhere((a) => a.id == animal.id);
        if (idx == -1) { _animals.insert(0, animal); } else { _animals[idx] = animal; }
        _selectedAnimalId = animal.id;
        notifyListeners();
        return animal;
      } catch (_) {}
    }

    return null;
  }
}

final animalNotifier = AnimalNotifier();
