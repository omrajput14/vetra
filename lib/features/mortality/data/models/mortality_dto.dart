enum MortalityCauseCategory {
  knownDisease('KNOWN_DISEASE', 'Known disease'),
  suspectedDisease('SUSPECTED_DISEASE', 'Suspected disease'),
  accidentInjury('ACCIDENT_INJURY', 'Accident / Injury'),
  unknown('UNKNOWN', 'Unknown ("I do not know")'),
  other('OTHER', 'Other');

  final String apiValue;
  final String label;
  const MortalityCauseCategory(this.apiValue, this.label);

  static MortalityCauseCategory fromString(String? val) {
    if (val == null) return MortalityCauseCategory.unknown;
    final upper = val.toUpperCase().trim();
    for (final c in MortalityCauseCategory.values) {
      if (c.apiValue == upper || c.name.toUpperCase() == upper) return c;
    }
    return MortalityCauseCategory.unknown;
  }
}

class CreateMortalityReportDto {
  final String animalId;
  final String causeCategory;
  final String? causeDescription;
  final String? diseaseName;
  final bool recentlyTreated;
  final String? treatmentNotes;
  final String? notes;
  final String? deathDateTime;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;

  const CreateMortalityReportDto({
    required this.animalId,
    required this.causeCategory,
    this.causeDescription,
    this.diseaseName,
    this.recentlyTreated = false,
    this.treatmentNotes,
    this.notes,
    this.deathDateTime,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'causeCategory': causeCategory,
      if (causeDescription != null && causeDescription!.isNotEmpty) 'causeDescription': causeDescription,
      if (diseaseName != null && diseaseName!.isNotEmpty) 'diseaseName': diseaseName,
      'recentlyTreated': recentlyTreated,
      if (treatmentNotes != null && treatmentNotes!.isNotEmpty) 'treatmentNotes': treatmentNotes,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (deathDateTime != null && deathDateTime!.isNotEmpty) 'deathDateTime': deathDateTime,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAccuracy != null) 'locationAccuracy': locationAccuracy,
    };
  }

  factory CreateMortalityReportDto.fromJson(Map<String, dynamic> json) {
    return CreateMortalityReportDto(
      animalId: json['animalId']?.toString() ?? '',
      causeCategory: json['causeCategory']?.toString() ?? 'UNKNOWN',
      causeDescription: json['causeDescription']?.toString(),
      diseaseName: json['diseaseName']?.toString(),
      recentlyTreated: json['recentlyTreated'] == true,
      treatmentNotes: json['treatmentNotes']?.toString(),
      notes: json['notes']?.toString(),
      deathDateTime: json['deathDateTime']?.toString(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationAccuracy: json['locationAccuracy'] != null ? (json['locationAccuracy'] as num).toDouble() : null,
    );
  }
}

class MortalityReportModel {
  final String id;
  final String animalId;
  final String? animalName;
  final String tagNumber;
  final String? qrCodeId;
  final String? farmerId;
  final String? farmerName;
  final String causeCategory;
  final String? causeDescription;
  final String? diseaseName;
  final bool recentlyTreated;
  final String? treatmentNotes;
  final String? notes;
  final String source;
  final String status;
  final String? deathDateTime;
  final String reportedAt;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final String? vetReviewedById;
  final String? vetReviewedByName;
  final String? vetReviewedAt;
  final String? vetCauseCategory;
  final String? vetDiseaseName;
  final String? vetClinicalNotes;
  final String? vetRejectionReason;
  final bool postMortemConducted;
  final String createdAt;
  final String updatedAt;

  MortalityReportModel({
    required this.id,
    required this.animalId,
    this.animalName,
    required this.tagNumber,
    this.qrCodeId,
    this.farmerId,
    this.farmerName,
    required this.causeCategory,
    this.causeDescription,
    this.diseaseName,
    this.recentlyTreated = false,
    this.treatmentNotes,
    this.notes,
    required this.source,
    required this.status,
    this.deathDateTime,
    required this.reportedAt,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.vetReviewedById,
    this.vetReviewedByName,
    this.vetReviewedAt,
    this.vetCauseCategory,
    this.vetDiseaseName,
    this.vetClinicalNotes,
    this.vetRejectionReason,
    this.postMortemConducted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MortalityReportModel.fromJson(Map<String, dynamic> json) {
    return MortalityReportModel(
      id: json['id']?.toString() ?? '',
      animalId: json['animalId']?.toString() ?? '',
      animalName: json['animalName']?.toString(),
      tagNumber: json['tagNumber']?.toString() ?? '',
      qrCodeId: json['qrCodeId']?.toString(),
      farmerId: json['farmerId']?.toString(),
      farmerName: json['farmerName']?.toString(),
      causeCategory: json['causeCategory']?.toString() ?? 'UNKNOWN',
      causeDescription: json['causeDescription']?.toString(),
      diseaseName: json['diseaseName']?.toString(),
      recentlyTreated: json['recentlyTreated'] == true,
      treatmentNotes: json['treatmentNotes']?.toString(),
      notes: json['notes']?.toString(),
      source: json['source']?.toString() ?? 'FARMER_REPORTED',
      status: json['status']?.toString() ?? 'REPORTED',
      deathDateTime: json['deathDateTime']?.toString(),
      reportedAt: json['reportedAt']?.toString() ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      locationAccuracy: json['locationAccuracy'] != null ? (json['locationAccuracy'] as num).toDouble() : null,
      vetReviewedById: json['vetReviewedById']?.toString(),
      vetReviewedByName: json['vetReviewedByName']?.toString(),
      vetReviewedAt: json['vetReviewedAt']?.toString(),
      vetCauseCategory: json['vetCauseCategory']?.toString(),
      vetDiseaseName: json['vetDiseaseName']?.toString(),
      vetClinicalNotes: json['vetClinicalNotes']?.toString(),
      vetRejectionReason: json['vetRejectionReason']?.toString(),
      postMortemConducted: json['postMortemConducted'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}


class ConfirmMortalityDto {
  final String causeCategory;
  final String? diseaseName;
  final String? clinicalNotes;
  final bool postMortemConducted;

  const ConfirmMortalityDto({
    required this.causeCategory,
    this.diseaseName,
    this.clinicalNotes,
    this.postMortemConducted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'causeCategory': causeCategory,
      if (diseaseName != null && diseaseName!.isNotEmpty) 'diseaseName': diseaseName,
      if (clinicalNotes != null && clinicalNotes!.isNotEmpty) 'clinicalNotes': clinicalNotes,
      'postMortemConducted': postMortemConducted,
    };
  }

  factory ConfirmMortalityDto.fromJson(Map<String, dynamic> json) {
    return ConfirmMortalityDto(
      causeCategory: json['causeCategory']?.toString() ?? 'KNOWN_DISEASE',
      diseaseName: json['diseaseName']?.toString(),
      clinicalNotes: json['clinicalNotes']?.toString(),
      postMortemConducted: json['postMortemConducted'] == true,
    );
  }
}

class RejectMortalityDto {
  final String rejectionReason;
  final String? clinicalNotes;

  const RejectMortalityDto({
    required this.rejectionReason,
    this.clinicalNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'rejectionReason': rejectionReason,
      if (clinicalNotes != null && clinicalNotes!.isNotEmpty) 'clinicalNotes': clinicalNotes,
    };
  }

  factory RejectMortalityDto.fromJson(Map<String, dynamic> json) {
    return RejectMortalityDto(
      rejectionReason: json['rejectionReason']?.toString() ?? '',
      clinicalNotes: json['clinicalNotes']?.toString(),
    );
  }
}

class MortalityAuditDto {
  final String id;
  final String mortalityEventId;
  final String veterinarianId;
  final String? veterinarianName;
  final String action;
  final String oldStatus;
  final String newStatus;
  final String? clinicalNotes;
  final String? confirmedCauseCategory;
  final String? confirmedDiseaseName;
  final String createdAt;

  const MortalityAuditDto({
    required this.id,
    required this.mortalityEventId,
    required this.veterinarianId,
    this.veterinarianName,
    required this.action,
    required this.oldStatus,
    required this.newStatus,
    this.clinicalNotes,
    this.confirmedCauseCategory,
    this.confirmedDiseaseName,
    required this.createdAt,
  });

  factory MortalityAuditDto.fromJson(Map<String, dynamic> json) {
    return MortalityAuditDto(
      id: json['id']?.toString() ?? '',
      mortalityEventId: json['mortalityEventId']?.toString() ?? '',
      veterinarianId: json['veterinarianId']?.toString() ?? '',
      veterinarianName: json['veterinarianName']?.toString(),
      action: json['action']?.toString() ?? '',
      oldStatus: json['oldStatus']?.toString() ?? '',
      newStatus: json['newStatus']?.toString() ?? '',
      clinicalNotes: json['clinicalNotes']?.toString(),
      confirmedCauseCategory: json['confirmedCauseCategory']?.toString(),
      confirmedDiseaseName: json['confirmedDiseaseName']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
