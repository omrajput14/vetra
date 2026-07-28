class MedicalRecordModel {
  final String id;
  final String appointmentId;
  final String animalId;
  final String? animalName;
  final String? tagNumber;
  final String? species;
  final String farmerId;
  final String? farmerName;
  final String veterinarianId;
  final String? veterinarianName;
  final String? clinicName;
  final String diagnosis;
  final String? symptoms;
  final String treatment;
  final String? prescription;
  final double? weight;
  final double? temperature;
  final String? followUpDate;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final int version;

  MedicalRecordModel({
    required this.id,
    required this.appointmentId,
    required this.animalId,
    this.animalName,
    this.tagNumber,
    this.species,
    required this.farmerId,
    this.farmerName,
    required this.veterinarianId,
    this.veterinarianName,
    this.clinicName,
    required this.diagnosis,
    this.symptoms,
    required this.treatment,
    this.prescription,
    this.weight,
    this.temperature,
    this.followUpDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: map['id']?.toString() ?? '',
      appointmentId: map['appointmentId']?.toString() ?? '',
      animalId: map['animalId']?.toString() ?? '',
      animalName: map['animalName']?.toString(),
      tagNumber: map['tagNumber']?.toString(),
      species: map['species']?.toString(),
      farmerId: map['farmerId']?.toString() ?? '',
      farmerName: map['farmerName']?.toString(),
      veterinarianId: map['veterinarianId']?.toString() ?? '',
      veterinarianName: map['veterinarianName']?.toString(),
      clinicName: map['clinicName']?.toString(),
      diagnosis: map['diagnosis']?.toString() ?? '',
      symptoms: map['symptoms']?.toString(),
      treatment: map['treatment']?.toString() ?? '',
      prescription: map['prescription']?.toString(),
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      temperature: map['temperature'] != null ? (map['temperature'] as num).toDouble() : null,
      followUpDate: map['followUpDate']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['createdAt']?.toString() ?? '',
      updatedAt: map['updatedAt']?.toString() ?? '',
      version: map['version'] != null ? (map['version'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'animalId': animalId,
      'animalName': animalName,
      'tagNumber': tagNumber,
      'species': species,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'veterinarianId': veterinarianId,
      'veterinarianName': veterinarianName,
      'clinicName': clinicName,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'treatment': treatment,
      'prescription': prescription,
      'weight': weight,
      'temperature': temperature,
      'followUpDate': followUpDate,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'version': version,
    };
  }
}
