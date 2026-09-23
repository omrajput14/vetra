import '../models/user_role.dart';
import '../models/user_model.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  AuthRepository _repository = AuthRepositoryImpl();

  void setRepository(AuthRepository repo) {
    _repository = repo;
  }

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
  }

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

  /// Signs in from what this device already knows, without the network.
  /// Used when the server is too slow to answer at startup.
  Future<bool> restoreCachedSession() async {
    _currentUser ??= await _repository.getCachedUser();
    return _currentUser != null;
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
    String? phone,
    required String password,
    required String village,
    String? taluka,
    required String district,
    required String state,
    double? latitude,
    double? longitude,
    String? animalCount,
    String? preferredLanguage,
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
        taluka: taluka,
        district: district,
        state: state,
        latitude: latitude,
        longitude: longitude,
        animalCount: count,
        preferredLanguage: preferredLanguage,
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
    String? clinicAddress,
    String? village,
    String? taluka,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    required String experience,
    String? preferredLanguage,
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
        clinicAddress: clinicAddress,
        village: village,
        taluka: taluka,
        district: district,
        state: state,
        latitude: latitude,
        longitude: longitude,
        experience: experience,
        preferredLanguage: preferredLanguage,
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
    String? taluka,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    String? clinicName,
    String? clinicAddress,
    String? specialization,
    String? qualification,
    int? yearsExperience,
    bool? isAvailable,
    bool? emergencyAvailable,
    String? shiftSchedule,
    String? profilePhotoUrl,
    String? certificateUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    try {
      _currentUser = await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        farmName: farmName,
        village: village,
        taluka: taluka,
        district: district,
        state: state,
        latitude: latitude,
        longitude: longitude,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        specialization: specialization,
        qualification: qualification,
        yearsExperience: yearsExperience,
        isAvailable: isAvailable,
        emergencyAvailable: emergencyAvailable,
        shiftSchedule: shiftSchedule,
        profilePhotoUrl: profilePhotoUrl,
        certificateUrl: certificateUrl,
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

  Future<List<Map<String, dynamic>>> listVets({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? village,
    String? taluka,
    String? district,
  }) async {
    try {
      return await _repository.listVets(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        village: village,
        taluka: taluka,
        district: district,
      );
    } catch (e) {
      return [];
    }
  }

  Future<String?> uploadProfilePhoto(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    try {
      final url = await _repository.uploadProfilePhoto(filePath);
      if (_currentUser != null && url.isNotEmpty) {
        final updatedMeta = Map<String, dynamic>.from(_currentUser!.metadata);
        updatedMeta['profilePhotoUrl'] = url;
        _currentUser = _currentUser!.copyWith(
          metadata: updatedMeta,
        );
      }
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> deleteProfilePhoto() async {
    _isLoading = true;
    _errorMessage = null;
    try {
      await _repository.deleteProfilePhoto();
      if (_currentUser != null) {
        final updatedMeta = Map<String, dynamic>.from(_currentUser!.metadata);
        updatedMeta['profilePhotoUrl'] = null;
        _currentUser = _currentUser!.copyWith(
          metadata: updatedMeta,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }
}
