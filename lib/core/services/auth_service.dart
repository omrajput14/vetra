import '../models/user_role.dart';

class AuthService {
  UserRole _currentRole = UserRole.farmer;
  String? _jwtToken;
  DateTime? _tokenExpiry;

  UserRole get currentRole => _currentRole;
  String? get jwtToken => _jwtToken;
  bool get isAuthenticated => _jwtToken != null && (_tokenExpiry == null || _tokenExpiry!.isAfter(DateTime.now()));

  void setRole(UserRole role) {
    _currentRole = role;
  }

  void login(String token, UserRole role) {
    _jwtToken = token;
    _currentRole = role;
    _tokenExpiry = DateTime.now().add(const Duration(days: 7));
  }

  void logout() {
    _jwtToken = null;
    _tokenExpiry = null;
  }
}
