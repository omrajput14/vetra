class Appointment {
  final String id;
  final String vetName;
  final String serviceType;
  final DateTime dateTime;
  final String status;

  const Appointment({
    required this.id,
    required this.vetName,
    required this.serviceType,
    required this.dateTime,
    required this.status,
  });
}