import '../../../../core/models/user_model.dart';

abstract class AuthRepository {
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
  });

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
  });

  Future<UserModel> loginFarmer({
    required String identifier,
    required String password,
  });

  Future<UserModel> loginVet({
    required String email,
    required String password,
  });

  Future<UserModel?> restoreSession();

  Future<UserModel> updateProfile({
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
  });

  Future<void> logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
