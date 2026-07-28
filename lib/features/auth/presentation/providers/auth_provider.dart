import 'package:flutter/foundation.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _service = AuthService.instance;

  bool get isLoggedIn => _service.isLoggedIn;
  UserModel? get currentUser => _service.currentUser;
  UserRole get currentRole => _service.currentRole;
  bool get isLoading => _service.isLoading;
  String? get errorMessage => _service.errorMessage;

  void clearError() {
    _service.clearError();
    notifyListeners();
  }

  Future<bool> restoreSession() async {
    final result = await _service.restoreSession();
    notifyListeners();
    return result;
  }

  Future<bool> loginFarmer(String identifier, String password) async {
    final success = await _service.loginFarmer(identifier: identifier, password: password);
    notifyListeners();
    return success;
  }

  Future<bool> registerFarmer({
    required String email,
    required String name,
    required String farmName,
    required String phone,
    required String password,
    required String village,
    required String district,
    required String state,
    String? animalCount,
  }) async {
    final success = await _service.registerFarmer(
      email: email,
      name: name,
      farmName: farmName,
      phone: phone,
      password: password,
      village: village,
      district: district,
      state: state,
      animalCount: animalCount,
    );
    notifyListeners();
    return success;
  }

  Future<bool> loginVet({
    required String email,
    required String password,
  }) async {
    final success = await _service.loginVet(email: email, password: password);
    notifyListeners();
    return success;
  }

  Future<bool> registerVet({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String regNo,
    required String qualification,
    required String specialization,
    String? clinicName,
    required String experience,
  }) async {
    final success = await _service.registerVet(
      name: name,
      email: email,
      phone: phone,
      password: password,
      regNo: regNo,
      qualification: qualification,
      specialization: specialization,
      clinicName: clinicName,
      experience: experience,
    );
    notifyListeners();
    return success;
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? farmName,
    String? village,
    String? district,
    String? state,
    String? clinicName,
    String? specialization,
    String? qualification,
    int? yearsExperience,
  }) async {
    final success = await _service.updateProfile(
      fullName: fullName,
      phone: phone,
      farmName: farmName,
      village: village,
      district: district,
      state: state,
      clinicName: clinicName,
      specialization: specialization,
      qualification: qualification,
      yearsExperience: yearsExperience,
    );
    notifyListeners();
    return success;
  }

  List<Map<String, dynamic>> _vetsList = [];
  List<Map<String, dynamic>> get vetsList => _vetsList;

  Future<void> fetchNearbyVets() async {
    _vetsList = await _service.listVets();
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    notifyListeners();
  }
}

final authNotifier = AuthNotifier();
