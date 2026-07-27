import '../models/user_role.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  UserModel? _currentUser;
  String? _token;

  bool get isLoggedIn => _currentUser != null && _token != null;
  UserModel? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.farmer;

  void restoreSession() {
    // Session persistence restoration logic
    // For active session mock: defaults to null if unauthenticated
  }

  void loginFarmer({required String identifier, required String password}) {
    _token = 'jwt_farmer_mock_token_8392';
    _currentUser = UserModel(
      id: 'usr_farmer_101',
      name: 'John Miller',
      emailOrPhone: identifier,
      role: UserRole.farmer,
    );
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
    _token = 'jwt_farmer_mock_token_8392';
    _currentUser = UserModel(
      id: 'usr_farmer_101',
      name: name,
      emailOrPhone: phone,
      role: UserRole.farmer,
      metadata: {
        'farmName': farmName,
        'village': village,
        'district': district,
        'state': state,
        'animalCount': animalCount,
      },
    );
  }

  void loginVet({
    required String email,
    required String password,
    required String regNo,
  }) {
    _token = 'jwt_vet_mock_token_4812';
    _currentUser = UserModel(
      id: 'usr_vet_202',
      name: 'Dr. Sarah Jenkins',
      emailOrPhone: email,
      role: UserRole.veterinarian,
      vetStatus: VetAccountStatus.active,
      metadata: {'regNo': regNo},
    );
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
    _token = 'jwt_vet_mock_token_4812';
    _currentUser = UserModel(
      id: 'usr_vet_202',
      name: name,
      emailOrPhone: email,
      role: UserRole.veterinarian,
      vetStatus: VetAccountStatus.active, // Auto-marked ACTIVE for V1
      metadata: {
        'phone': phone,
        'regNo': regNo,
        'qualification': qualification,
        'specialization': specialization,
        'clinicName': clinicName,
        'experience': experience,
      },
    );
  }

  void logout() {
    _token = null;
    _currentUser = null;
  }
}
