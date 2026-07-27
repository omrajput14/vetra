import 'package:flutter/foundation.dart';
import '../../data/models/animal_dto.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../domain/repositories/animal_repository.dart';

class AnimalNotifier extends ChangeNotifier {
  final AnimalRepository _repository = AnimalRepositoryImpl();

  List<AnimalModel> _animals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AnimalModel> get animals => _animals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAnimals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _animals = await _repository.listAnimals();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchAnimals({
    String? tagNumber,
    String? species,
    String? breed,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _animals = await _repository.searchAnimals(
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
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final animal = await _repository.createAnimal(
        tagNumber: tagNumber,
        qrCodeId: qrCodeId,
        species: species,
        breed: breed,
        gender: gender,
        birthDate: birthDate,
        photoUrl: photoUrl,
      );
      _animals.insert(0, animal);
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
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateAnimal(
        id: id,
        tagNumber: tagNumber,
        qrCodeId: qrCodeId,
        species: species,
        breed: breed,
        gender: gender,
        birthDate: birthDate,
        photoUrl: photoUrl,
      );

      final index = _animals.indexWhere((a) => a.id == id);
      if (index != -1) {
        _animals[index] = updated;
      }
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
}

final animalNotifier = AnimalNotifier();
