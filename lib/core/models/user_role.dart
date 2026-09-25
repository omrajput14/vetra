enum UserRole {
  farmer,
  veterinarian,
  administrator,

  /// Field para-vet: checks farmers' AI scans and escalates them to a vet (cannot confirm).
  paraVet;

  /// Maps the backend role name (FARMER, VETERINARIAN, PARA_VET, ...) to the app role.
  static UserRole fromApi(Object? role) => switch (role?.toString().toUpperCase()) {
        'VETERINARIAN' => UserRole.veterinarian,
        'PARA_VET' => UserRole.paraVet,
        _ => UserRole.farmer,
      };
}

enum VetAccountStatus {
  pendingVerification,
  active,
  rejected,
}
