import 'user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String emailOrPhone;
  final UserRole role;
  final VetAccountStatus vetStatus;
  final Map<String, dynamic> metadata;

  const UserModel({
    required this.id,
    required this.name,
    required this.emailOrPhone,
    required this.role,
    this.vetStatus = VetAccountStatus.active,
    this.metadata = const {},
  });
}
