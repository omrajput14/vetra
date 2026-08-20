import 'package:flutter/foundation.dart';
import '../../data/models/ai_scan_model.dart';
import '../../data/repositories/ai_scan_repository_impl.dart';
import '../../domain/repositories/ai_scan_repository.dart';
import '../../../animal/data/api/animal_api_service.dart';

class AIScanNotifier extends ChangeNotifier {
  final AIScanRepository _repository;
  final AnimalApiService _animalApiService;

  AIScanNotifier({
    AIScanRepository? repository,
    AnimalApiService? animalApiService,
  })  : _repository = repository ?? AIScanRepositoryImpl(),
        _animalApiService = animalApiService ?? AnimalApiService();

  String? _selectedImagePath;
  AIScanModel? _lastScanResult;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _farmerAnimals = [];
  String? _selectedAnimalId;

  String? get selectedImagePath => _selectedImagePath;
  AIScanModel? get lastScanResult => _lastScanResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get farmerAnimals => _farmerAnimals;
  String? get selectedAnimalId => _selectedAnimalId;

  void setSelectedImage(String? path) {
    _selectedImagePath = path;
    _errorMessage = null;
    notifyListeners();
  }

  void setLastScanResult(AIScanModel? result) {
    _lastScanResult = result;
    notifyListeners();
  }

  void setSelectedAnimalId(String animalId) {
    _selectedAnimalId = animalId;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchFarmerAnimals() async {
    try {
      final res = await _animalApiService.listAnimals();
      if (res['data'] is List) {
        _farmerAnimals = (res['data'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        if (_farmerAnimals.isNotEmpty && _selectedAnimalId == null) {
          _selectedAnimalId = _farmerAnimals.first['id']?.toString();
        }
      }
    } catch (_) {
      // Ignore list error, fallback handled in caller
    }
    notifyListeners();
  }

  Future<bool> submitScan({required String animalId, required String imagePath}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastScanResult = await _repository.createScan(
        animalId: animalId,
        imagePath: imagePath,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

final aiScanNotifier = AIScanNotifier();
