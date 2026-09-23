/// Request payload for submitting a disease surveillance report to the backend.
class CreateDiseaseReportDto {
  final String animalId;
  final String? medicalRecordId;
  final String? aiScanId;
  final String reportSource;
  final String? diagnosisConfidenceSource;
  final String diseaseName;
  final String diagnosisStatus;
  final double latitude;
  final double longitude;
  final String? notes;

  const CreateDiseaseReportDto({
    required this.animalId,
    this.medicalRecordId,
    this.aiScanId,
    this.reportSource = 'MANUAL',
    this.diagnosisConfidenceSource,
    required this.diseaseName,
    this.diagnosisStatus = 'SUSPECTED',
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'animalId': animalId,
        if (medicalRecordId != null) 'medicalRecordId': medicalRecordId,
        if (aiScanId != null) 'aiScanId': aiScanId,
        'reportSource': reportSource,
        if (diagnosisConfidenceSource != null)
          'diagnosisConfidenceSource': diagnosisConfidenceSource,
        'diseaseName': diseaseName,
        'diagnosisStatus': diagnosisStatus,
        'latitude': latitude,
        'longitude': longitude,
        if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      };
}

/// Domain response model representing a persisted disease surveillance report.
class DiseaseReportModel {
  final String id;
  final String animalId;
  final String? tagNumber;
  final String? animalName;
  final String? medicalRecordId;
  final String? aiScanId;
  final String reportedById;
  final String? reportedByName;
  final String reportSource;
  final String? diagnosisConfidenceSource;
  final String diseaseName;
  final String diagnosisStatus;
  final double latitude;
  final double longitude;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Saved on this device only; the server has not received it yet.
  final bool isPendingSync;

  const DiseaseReportModel({
    required this.id,
    required this.animalId,
    this.tagNumber,
    this.animalName,
    this.medicalRecordId,
    this.aiScanId,
    required this.reportedById,
    this.reportedByName,
    required this.reportSource,
    this.diagnosisConfidenceSource,
    required this.diseaseName,
    required this.diagnosisStatus,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.isPendingSync = false,
  });

  factory DiseaseReportModel.fromJson(Map<String, dynamic> json) {
    return DiseaseReportModel(
      id: json['id']?.toString() ?? '',
      animalId: json['animalId']?.toString() ?? '',
      tagNumber: json['tagNumber']?.toString(),
      animalName: json['animalName']?.toString(),
      medicalRecordId: json['medicalRecordId']?.toString(),
      aiScanId: json['aiScanId']?.toString(),
      reportedById: json['reportedById']?.toString() ?? '',
      reportedByName: json['reportedByName']?.toString(),
      reportSource: json['reportSource']?.toString() ?? 'MANUAL',
      diagnosisConfidenceSource: json['diagnosisConfidenceSource']?.toString(),
      diseaseName: json['diseaseName']?.toString() ?? 'Suspected Condition',
      diagnosisStatus: json['diagnosisStatus']?.toString() ?? 'SUSPECTED',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
