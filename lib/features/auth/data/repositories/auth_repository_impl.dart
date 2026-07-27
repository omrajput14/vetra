import '../../../../core/models/user_model.dart';
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
    required String phone,
    required String password,
    String? farmName,
    String? village,
    String? district,
    String? state,
    int? animalCount,
  }) async {
    final response = await _apiService.registerFarmer({
      'email': email,
      'phone': phone,
      'password': password,
      'fullName': fullName,
      'farmName': farmName,
      'village': village,
      'district': district,
      'state': state,
      'animalCount': animalCount,
    });

    return await _processAuthResponse(response);
  }

  @override
  Future<UserModel> registerVet({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String regNo,
    required String qualification,
    required String specialization,
    String? clinicName,
    required String experience,
  }) async {
    final yearsExp = int.tryParse(experience.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    final response = await _apiService.registerVet({
      'email': email,
      'phone': phone,
      'password': password,
      'fullName': name,
      'registrationNumber': regNo,
      'qualification': qualification,
      'specialization': specialization,
      'clinicName': clinicName,
      'yearsExperience': yearsExp,
    });

    return await _processAuthResponse(response);
  }

  @override
  Future<UserModel> loginFarmer({
    required String identifier,
    required String password,
  }) async {
    final response = await _apiService.loginFarmer(identifier, password);
    return await _processAuthResponse(response);
  }

  @override
  Future<UserModel> loginVet({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.loginVet(email, password);
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
      final roleStr = (userData['role'] ?? 'FARMER').toString().toUpperCase();
      final role = roleStr == 'VETERINARIAN' ? UserRole.veterinarian : UserRole.farmer;

      return UserModel(
        id: userData['id'].toString(),
        name: userData['fullName']?.toString() ?? 'User',
        emailOrPhone: userData['email']?.toString() ?? userData['phone']?.toString() ?? '',
        role: role,
        vetStatus: VetAccountStatus.active,
      );
    } catch (e) {
      await _storage.clearAll();
      return null;
    }
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

    return UserModel(
      id: userId,
      name: userData['fullName']?.toString() ?? 'User',
      emailOrPhone: userData['email']?.toString() ?? userData['phone']?.toString() ?? '',
      role: role,
      vetStatus: VetAccountStatus.active,
    );
  }
}
