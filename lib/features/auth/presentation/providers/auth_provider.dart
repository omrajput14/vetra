import 'package:flutter/foundation.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _service = AuthService.instance;

  bool get isLoggedIn => _service.isLoggedIn;
  UserModel? get currentUser => _service.currentUser;
  UserRole get currentRole => _service.currentRole;
  bool get isLoading => _service.isLoading;
  String? get errorMessage => _service.errorMessage;

  void setRepository(AuthRepository repo) {
    _service.setRepository(repo);
    notifyListeners();
  }

  void setCurrentUser(UserModel? user) {
    _service.setCurrentUser(user);
    notifyListeners();
  }

  void clearError() {
    _service.clearError();
    notifyListeners();
  }

  Future<bool> restoreSession() async {
    final result = await _service.restoreSession();
    if (result) {
      PushNotificationService.instance.syncDeviceTokenWithBackend();
    }
    notifyListeners();
    return result;
  }

  Future<bool> restoreCachedSession() async {
    final result = await _service.restoreCachedSession();
    notifyListeners();
    return result;
  }

  Future<bool> loginFarmer(String identifier, String password) async {
    final success = await _service.loginFarmer(identifier: identifier, password: password);
    if (success) {
      PushNotificationService.instance.syncDeviceTokenWithBackend();
    }
    notifyListeners();
    return success;
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
    final success = await _service.registerFarmer(
      email: email,
      name: name,
      farmName: farmName,
      phone: phone,
      password: password,
      village: village,
      taluka: taluka,
      district: district,
      state: state,
      latitude: latitude,
      longitude: longitude,
      animalCount: animalCount,
      preferredLanguage: preferredLanguage,
    );
    if (success) {
      PushNotificationService.instance.syncDeviceTokenWithBackend();
    }
    notifyListeners();
    return success;
  }

  Future<bool> loginVet({
    required String email,
    required String password,
  }) async {
    final success = await _service.loginVet(email: email, password: password);
    if (success) {
      PushNotificationService.instance.syncDeviceTokenWithBackend();
    }
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
    final success = await _service.registerVet(
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
    if (success) {
      PushNotificationService.instance.syncDeviceTokenWithBackend();
    }
    notifyListeners();
    return success;
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
    final success = await _service.updateProfile(
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
    notifyListeners();
    return success;
  }

  Future<bool> updateDutyStatus(bool isAvailable) async {
    final success = await _service.updateProfile(isAvailable: isAvailable);
    notifyListeners();
    return success;
  }


  Future<String?> uploadProfilePhoto(String filePath) async {
    final url = await _service.uploadProfilePhoto(filePath);
    notifyListeners();
    return url;
  }

  Future<bool> deleteProfilePhoto() async {
    final ok = await _service.deleteProfilePhoto();
    notifyListeners();
    return ok;
  }

  List<Map<String, dynamic>> _vetsList = [];
  bool _vetsFetching = false;
  List<Map<String, dynamic>> get vetsList => _vetsList;

  void setVetsList(List<Map<String, dynamic>> list) {
    _vetsList = deduplicateVets(list);
    notifyListeners();
  }

  /// Deduplicates a vet list by server ID to prevent the same vet appearing
  /// multiple times when the API response contains duplicates or when a
  /// Deduplicates the incoming veterinarian directory entries by ID,
  /// registration number, and clinical practitioner identity, filtering
  /// out retired/test accounts so that each veterinarian appears at most once.
  @visibleForTesting
  List<Map<String, dynamic>> deduplicateVets(List<Map<String, dynamic>> list) {
    final seenIds = <String>{};
    final seenKeys = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final vet in list) {
      final id = vet['id']?.toString() ?? vet['userId']?.toString() ?? '';
      final name = (vet['fullName'] ?? vet['name'])?.toString().trim() ?? '';
      final regNo = vet['registrationNumber']?.toString().trim() ?? '';
      final clinic = (vet['clinicName'] ?? vet['clinic'])?.toString().trim() ?? '';

      // Skip retired/test staging markers if any
      if (name.startsWith('[RETIRED') || name.startsWith('[TEST')) {
        continue;
      }

      // Deduplicate by practitioner name and clinic first so test accounts with different reg numbers don't duplicate
      final identityKey = name.isNotEmpty
          ? 'name:${name.toLowerCase()}|${clinic.toLowerCase()}'
          : (regNo.isNotEmpty ? 'reg:${regNo.toLowerCase()}' : id);

      if (id.isNotEmpty && !seenIds.add(id)) continue;
      if (identityKey.isNotEmpty && !seenKeys.add(identityKey)) continue;

      result.add(vet);
    }
    return result;
  }

  Future<void> fetchNearbyVets({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? village,
    String? taluka,
    String? district,
  }) async {
    // Guard: prevent concurrent refresh calls from stacking duplicate results
    if (_vetsFetching) return;
    _vetsFetching = true;

    try {
      final freshList = await _service.listVets(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        village: village,
        taluka: taluka,
        district: district,
      );
      // Replace (not append) the list and deduplicate by server ID
      _vetsList = deduplicateVets(freshList);
    } catch (e) {
      // API failure: keep existing cached vets rather than clearing the list
      debugPrint('[AuthNotifier] fetchNearbyVets failed: $e — keeping cached list');
    } finally {
      _vetsFetching = false;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await PushNotificationService.instance.deactivateTokenOnLogout();
    await _service.logout();
    notifyListeners();
  }
}

final authNotifier = AuthNotifier();
