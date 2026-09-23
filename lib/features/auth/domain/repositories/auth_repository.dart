import '../../../../core/models/user_model.dart';

abstract class AuthRepository {
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
  });

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
  });

  Future<UserModel> loginFarmer({
    required String identifier,
    required String password,
  });

  Future<UserModel> loginVet({
    required String email,
    required String password,
  });

  /// Validates the stored session with the server. Returns null only when the
  /// session is gone (no token, or the server rejected it with 401); a network
  /// failure keeps the user signed in with their cached profile.
  Future<UserModel?> restoreSession();

  /// The signed-in user as last known on this device, without any network call.
  Future<UserModel?> getCachedUser();

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
  });

  Future<void> logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<List<Map<String, dynamic>>> listVets({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? village,
    String? taluka,
    String? district,
  });

  Future<String> uploadProfilePhoto(String filePath);
  Future<void> deleteProfilePhoto();
}
