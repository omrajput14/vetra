class Vaccination {
  final String id;
  final String vaccineName;
  final DateTime dueDate;
  final String status;

  const Vaccination({
    required this.id,
    required this.vaccineName,
    required this.dueDate,
    required this.status,
  });
}