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

  String? get village => metadata['village']?.toString();
  String? get taluka => metadata['taluka']?.toString();
  String? get district => metadata['district']?.toString();
  String? get state => metadata['state']?.toString();
  String? get farmName => metadata['farmName']?.toString();
  String? get clinicName => metadata['clinicName']?.toString();
  double? get latitude => (metadata['latitude'] as num?)?.toDouble();
  double? get longitude => (metadata['longitude'] as num?)?.toDouble();
  String? get profilePhotoUrl => metadata['profilePhotoUrl']?.toString();
  String? get certificateUrl => metadata['certificateUrl']?.toString();
  String? get clinicAddress => metadata['clinicAddress']?.toString();
  String? get certificateStatus => metadata['certificateStatus']?.toString() ?? 'PENDING_VERIFICATION';
  String? get qualification => metadata['qualification']?.toString();
  String? get specialization => metadata['specialization']?.toString();
  String? get registrationNumber => metadata['registrationNumber']?.toString();
  bool get isAvailable {
    final val = metadata['isAvailable'] ?? metadata['available'] ?? metadata['is_available'];
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    if (val is num) return val != 0;
    return true;
  }

  bool get emergencyAvailable {
    final val = metadata['emergencyAvailable'] ?? metadata['isEmergencyAvailable'] ?? metadata['emergency_available'];
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    if (val is num) return val != 0;
    return true;
  }

  String? get shiftSchedule => metadata['shiftSchedule']?.toString();

  UserModel copyWith({
    String? id,
    String? name,
    String? emailOrPhone,
    UserRole? role,
    VetAccountStatus? vetStatus,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      role: role ?? this.role,
      vetStatus: vetStatus ?? this.vetStatus,
      metadata: metadata ?? this.metadata,
    );
  }
}
