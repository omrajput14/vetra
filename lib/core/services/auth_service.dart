import '../models/user_role.dart';
import '../models/user_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final AuthRepository _repository = AuthRepositoryImpl();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.farmer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
  }

  Future<bool> restoreSession() async {
    _isLoading = true;
    _errorMessage = null;
    try {
      _currentUser = await _repository.restoreSession();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> loginFarmer({required String identifier, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    try {
      _currentUser = await _repository.loginFarmer(
        identifier: identifier,
        password: password,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
    }
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
    _isLoading = true;
    _errorMessage = null;
    try {
      final count = animalCount != null ? int.tryParse(animalCount) : null;
      _currentUser = await _repository.registerFarmer(
        email: email,
        fullName: name,
        phone: phone,
        password: password,
        farmName: farmName,
        village: village,
        district: district,
        state: state,
        animalCount: count,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> loginVet({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    try {
      _currentUser = await _repository.loginVet(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
    }
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
    _isLoading = true;
    _errorMessage = null;
    try {
      _currentUser = await _repository.registerVet(
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
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
    }
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
    _isLoading = true;
    _errorMessage = null;
    try {
      _currentUser = await _repository.updateProfile(
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
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    try {
      await _repository.logout();
    } catch (_) {
    } finally {
      _currentUser = null;
      _isLoading = false;
    }
  }
}
