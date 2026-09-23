import '../../../../core/models/user_model.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService = AuthApiService();
  final SecureStorageService _storage = SecureStorageService.instance;

  @override
  Future<UserModel> registerFarmer({
    required String email,
    required String fullName,
    String? phone,
    required String password,
    String? farmName,
    String? village,
    String? taluka,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    int? animalCount,
    String? preferredLanguage,
  }) async {
    final lang = preferredLanguage ?? await _storage.getPreferredLanguage() ?? 'en';
    final cleanPhone = (phone != null && phone.trim().isNotEmpty)
        ? phone.trim().replaceAll(RegExp(r'\s+'), '')
        : null;

    final body = <String, dynamic>{
      'email': email.trim().replaceAll(' ', ''),
      if (cleanPhone != null) 'phone': cleanPhone,
      'password': password,
      'fullName': fullName.trim(),
      if (farmName != null && farmName.trim().isNotEmpty) 'farmName': farmName.trim(),
      if (village != null && village.trim().isNotEmpty) 'village': village.trim(),
      if (taluka != null && taluka.trim().isNotEmpty) 'taluka': taluka.trim(),
      if (district != null && district.trim().isNotEmpty) 'district': district.trim(),
      if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (animalCount != null) 'animalCount': animalCount,
      'preferredLanguage': lang,
    };

    final response = await _apiService.registerFarmer(body);
    return await _processAuthResponse(response);
  }

  @override
  Future<UserModel> registerVet({
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
    final yearsExp = int.tryParse(experience.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final cleanPhone = (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null;
    final lang = preferredLanguage ?? await _storage.getPreferredLanguage() ?? 'en';

    final response = await _apiService.registerVet({
      'email': email.trim().replaceAll(' ', ''),
      'phone': cleanPhone,
      'password': password,
      'fullName': name.trim(),
      'registrationNumber': regNo.trim(),
      'qualification': qualification.trim(),
      'specialization': specialization.trim(),
      'clinicName': clinicName?.trim(),
      'clinicAddress': clinicAddress?.trim(),
      'village': village?.trim(),
      'taluka': taluka?.trim(),
      'district': district?.trim(),
      'state': state?.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'yearsExperience': yearsExp,
      'preferredLanguage': lang,
    });

    return await _processAuthResponse(response);
  }

  @override
  Future<UserModel> loginFarmer({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiService.loginFarmer(identifier.trim().replaceAll(' ', ''), password);
    return await _processAuthResponse(response);
  }

  @override
  Future<UserModel> loginVet({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.loginVet(email.trim().replaceAll(' ', ''), password);
    return await _processAuthResponse(response);
  }

  @override
  Future<UserModel?> restoreSession() async {
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiService.getCurrentUser();
      final userData = response['data'] as Map<String, dynamic>;
      await _storage.saveUserProfile(userData);
      return _userFromData(userData);
    } on NetworkException catch (e) {
      if (e.statusCode == 401) {
        // The server rejected the token (AuthInterceptor already tried a refresh).
        await _storage.clearAll();
        return null;
      }
      // Offline, timed out or server trouble: the session is still valid.
      return getCachedUser();
    } catch (_) {
      return getCachedUser();
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    final profile = await _storage.getUserProfile();
    if (profile != null) return _userFromData(profile);

    // Signed in before profiles were cached: rebuild what the tokens record.
    final userId = await _storage.getUserId();
    if (userId == null || userId.isEmpty) return null;
    final role = await _storage.getUserRole() == UserRole.veterinarian.name
        ? UserRole.veterinarian
        : UserRole.farmer;
    return UserModel(id: userId, name: 'User', emailOrPhone: '', role: role);
  }

  UserModel _userFromData(Map<String, dynamic> userData) {
    final roleStr = (userData['role'] ?? 'FARMER').toString().toUpperCase();
    final role = roleStr == 'VETERINARIAN' ? UserRole.veterinarian : UserRole.farmer;

    return UserModel(
      id: userData['id'].toString(),
      name: userData['fullName']?.toString() ?? 'User',
      emailOrPhone: userData['email']?.toString() ?? userData['phone']?.toString() ?? '',
      role: role,
      vetStatus: VetAccountStatus.active,
      metadata: userData,
    );
  }

  @override
  Future<UserModel> updateProfile({
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
    final response = await _apiService.updateProfile({
      'fullName': fullName,
      'phone': phone,
      'farmName': farmName,
      'village': village,
      'taluka': taluka,
      'district': district,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'specialization': specialization,
      'qualification': qualification,
      'yearsExperience': yearsExperience,
      'isAvailable': isAvailable,
      'available': isAvailable,
      'emergencyAvailable': emergencyAvailable,
      'isEmergencyAvailable': emergencyAvailable,
      'shiftSchedule': shiftSchedule,
      'profilePhotoUrl': profilePhotoUrl,
      'certificateUrl': certificateUrl,
    });

    final userData = response['data'] as Map<String, dynamic>;
    await _storage.saveUserProfile(userData);
    return _userFromData(userData);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _apiService.logout(refreshToken);
      } catch (_) {}
    }
    await _storage.clearAll();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiService.changePassword(currentPassword, newPassword);
  }

  Future<UserModel> _processAuthResponse(Map<String, dynamic> response) async {
    final data = response['data'] as Map<String, dynamic>;
    final accessToken = data['accessToken'].toString();
    final refreshToken = data['refreshToken'].toString();
    final userData = data['user'] as Map<String, dynamic>;

    final roleStr = (userData['role'] ?? 'FARMER').toString().toUpperCase();
    final role = roleStr == 'VETERINARIAN' ? UserRole.veterinarian : UserRole.farmer;
    final userId = userData['id'].toString();

    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userRole: role.name,
      userId: userId,
    );

    if (userData['preferredLanguage'] != null) {
      final lang = userData['preferredLanguage'].toString();
      if (lang.isNotEmpty) {
        await _storage.savePreferredLanguage(lang);
      }
    }

    await _storage.saveUserProfile(userData);
    return _userFromData(userData);
  }

  @override
  Future<List<Map<String, dynamic>>> listVets({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? village,
    String? taluka,
    String? district,
  }) async {
    return await _apiService.listVets(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      village: village,
      taluka: taluka,
      district: district,
    );
  }

  @override
  Future<String> uploadProfilePhoto(String filePath) async {
    final response = await _apiService.uploadProfilePhoto(filePath);
    final data = response['data'] as Map<String, dynamic>?;
    return data?['photoUrl']?.toString() ?? '';
  }

  @override
  Future<void> deleteProfilePhoto() async {
    await _apiService.deleteProfilePhoto();
  }
}
