class AnimalHealthRecordModel {
  final String id;
  final String animalId;
  final String recordType;
  final String source;
  final String title;
  final String? description;
  final String? symptoms;
  final String? diagnosis;
  final String? treatment;
  final String? veterinarianId;
  final String? veterinarianName;
  final String? documentUrl;
  final String? vaccineName;
  final String? nextDueDate;
  final String? batchNumber;
  final String recordedAt;
  final String? createdAt;

  AnimalHealthRecordModel({
    required this.id,
    required this.animalId,
    required this.recordType,
    required this.source,
    required this.title,
    this.description,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    this.veterinarianId,
    this.veterinarianName,
    this.documentUrl,
    this.vaccineName,
    this.nextDueDate,
    this.batchNumber,
    required this.recordedAt,
    this.createdAt,
  });

  factory AnimalHealthRecordModel.fromJson(Map<String, dynamic> json) {
    return AnimalHealthRecordModel(
      id: json['id']?.toString() ?? '',
      animalId: json['animalId']?.toString() ?? '',
      recordType: json['recordType']?.toString() ?? 'OBSERVATION',
      source: json['source']?.toString() ?? 'SYSTEM',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      symptoms: json['symptoms']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      treatment: json['treatment']?.toString(),
      veterinarianId: json['veterinarianId']?.toString(),
      veterinarianName: json['veterinarianName']?.toString(),
      documentUrl: json['documentUrl']?.toString(),
      vaccineName: json['vaccineName']?.toString(),
      nextDueDate: json['nextDueDate']?.toString(),
      batchNumber: json['batchNumber']?.toString(),
      recordedAt: json['recordedAt']?.toString() ?? DateTime.now().toIso8601String(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalId': animalId,
      'recordType': recordType,
      'source': source,
      'title': title,
      'description': description,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'veterinarianId': veterinarianId,
      'veterinarianName': veterinarianName,
      'documentUrl': documentUrl,
      'vaccineName': vaccineName,
      'nextDueDate': nextDueDate,
      'batchNumber': batchNumber,
      'recordedAt': recordedAt,
      'createdAt': createdAt,
    };
  }
}

class AnimalHealthStatusModel {
  final String animalId;
  final String status;
  final String statusSummary;
  final String? latestEventType;
  final String? latestEventSource;
  final String? latestEventTime;
  final String? latestDiagnosis;
  final String? latestTreatment;

  AnimalHealthStatusModel({
    required this.animalId,
    required this.status,
    required this.statusSummary,
    this.latestEventType,
    this.latestEventSource,
    this.latestEventTime,
    this.latestDiagnosis,
    this.latestTreatment,
  });

  factory AnimalHealthStatusModel.fromJson(Map<String, dynamic> json) {
    return AnimalHealthStatusModel(
      animalId: json['animalId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'HEALTHY',
      statusSummary: json['statusSummary']?.toString() ?? 'Healthy',
      latestEventType: json['latestEventType']?.toString(),
      latestEventSource: json['latestEventSource']?.toString(),
      latestEventTime: json['latestEventTime']?.toString(),
      latestDiagnosis: json['latestDiagnosis']?.toString(),
      latestTreatment: json['latestTreatment']?.toString(),
    );
  }
}
