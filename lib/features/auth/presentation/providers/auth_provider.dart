import 'package:flutter/foundation.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _service = AuthService.instance;

  bool get isLoggedIn => _service.isLoggedIn;
  UserModel? get currentUser => _service.currentUser;
  UserRole get currentRole => _service.currentRole;

  void restoreSession() {
    _service.restoreSession();
    notifyListeners();
  }

  void loginFarmer(String identifier, String password) {
    _service.loginFarmer(identifier: identifier, password: password);
    notifyListeners();
  }

  void registerFarmer({
    required String name,
    required String farmName,
    required String phone,
    required String village,
    required String district,
    required String state,
    String? animalCount,
  }) {
    _service.registerFarmer(
      name: name,
      farmName: farmName,
      phone: phone,
      village: village,
      district: district,
      state: state,
      animalCount: animalCount,
    );
    notifyListeners();
  }

  void loginVet({
    required String email,
    required String password,
    required String regNo,
  }) {
    _service.loginVet(email: email, password: password, regNo: regNo);
    notifyListeners();
  }

  void registerVet({
    required String name,
    required String email,
    required String phone,
    required String regNo,
    required String qualification,
    required String specialization,
    String? clinicName,
    required String experience,
  }) {
    _service.registerVet(
      name: name,
      email: email,
      phone: phone,
      regNo: regNo,
      qualification: qualification,
      specialization: specialization,
      clinicName: clinicName,
      experience: experience,
    );
    notifyListeners();
  }

  void logout() {
    _service.logout();
    notifyListeners();
  }
}

final authNotifier = AuthNotifier();
