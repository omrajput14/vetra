class DashboardModel {
  final int registeredAnimalCount;
  final int pendingAppointmentsCount;
  final int activeAlertsCount;
  final int medicalRecordsCreatedCount;
  final String userName;
  final String facilityName;
  final String role;

  DashboardModel({
    required this.registeredAnimalCount,
    required this.pendingAppointmentsCount,
    required this.activeAlertsCount,
    this.medicalRecordsCreatedCount = 0,
    required this.userName,
    required this.facilityName,
    required this.role,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      registeredAnimalCount: (json['registeredAnimalCount'] as num?)?.toInt() ?? 0,
      pendingAppointmentsCount: (json['pendingAppointmentsCount'] as num?)?.toInt() ?? 0,
      activeAlertsCount: (json['activeAlertsCount'] as num?)?.toInt() ?? 0,
      medicalRecordsCreatedCount: (json['medicalRecordsCreatedCount'] as num?)?.toInt() ?? 0,
      userName: json['userName']?.toString() ?? 'User',
      facilityName: json['facilityName']?.toString() ?? 'Vetra Platform',
      role: json['role']?.toString() ?? 'FARMER',
    );
  }
}
