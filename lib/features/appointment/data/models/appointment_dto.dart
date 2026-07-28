enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  rejected;

  static AppointmentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return AppointmentStatus.confirmed;
      case 'COMPLETED':
        return AppointmentStatus.completed;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      case 'REJECTED':
        return AppointmentStatus.rejected;
      case 'PENDING':
      default:
        return AppointmentStatus.pending;
    }
  }

  String toDisplayString() {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rejected:
        return 'Rejected';
    }
  }
}

enum VisitType {
  generalCheckup,
  vaccination,
  emergency,
  pregnancy,
  surgery,
  followUp,
  other;

  static VisitType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'VACCINATION':
        return VisitType.vaccination;
      case 'EMERGENCY':
        return VisitType.emergency;
      case 'PREGNANCY':
        return VisitType.pregnancy;
      case 'SURGERY':
        return VisitType.surgery;
      case 'FOLLOW_UP':
        return VisitType.followUp;
      case 'OTHER':
        return VisitType.other;
      case 'GENERAL_CHECKUP':
      default:
        return VisitType.generalCheckup;
    }
  }

  String toServerString() {
    switch (this) {
      case VisitType.generalCheckup:
        return 'GENERAL_CHECKUP';
      case VisitType.vaccination:
        return 'VACCINATION';
      case VisitType.emergency:
        return 'EMERGENCY';
      case VisitType.pregnancy:
        return 'PREGNANCY';
      case VisitType.surgery:
        return 'SURGERY';
      case VisitType.followUp:
        return 'FOLLOW_UP';
      case VisitType.other:
        return 'OTHER';
    }
  }

  String toDisplayString() {
    switch (this) {
      case VisitType.generalCheckup:
        return 'General Checkup';
      case VisitType.vaccination:
        return 'Vaccination';
      case VisitType.emergency:
        return 'Emergency Care';
      case VisitType.pregnancy:
        return 'Pregnancy Check';
      case VisitType.surgery:
        return 'Surgical Procedure';
      case VisitType.followUp:
        return 'Follow-up Visit';
      case VisitType.other:
        return 'Other';
    }
  }
}

class AppointmentModel {
  final String id;
  final String farmerId;
  final String? farmerName;
  final String? farmerPhone;
  final String veterinarianId;
  final String? veterinarianName;
  final String? clinicName;
  final String animalId;
  final String? animalName;
  final String? tagNumber;
  final String? species;
  final String appointmentDate;
  final String appointmentTime;
  final VisitType visitType;
  final String reason;
  final AppointmentStatus status;
  final String? veterinarianNotes;
  final String? cancellationReason;
  final int? version;
  final String? createdAt;
  final String? updatedAt;

  AppointmentModel({
    required this.id,
    required this.farmerId,
    this.farmerName,
    this.farmerPhone,
    required this.veterinarianId,
    this.veterinarianName,
    this.clinicName,
    required this.animalId,
    this.animalName,
    this.tagNumber,
    this.species,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.visitType,
    required this.reason,
    required this.status,
    this.veterinarianNotes,
    this.cancellationReason,
    this.version,
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      farmerId: json['farmerId'] as String? ?? '',
      farmerName: json['farmerName'] as String?,
      farmerPhone: json['farmerPhone'] as String?,
      veterinarianId: json['veterinarianId'] as String? ?? '',
      veterinarianName: json['veterinarianName'] as String?,
      clinicName: json['clinicName'] as String?,
      animalId: json['animalId'] as String? ?? '',
      animalName: json['animalName'] as String?,
      tagNumber: json['tagNumber'] as String?,
      species: json['species'] as String?,
      appointmentDate: json['appointmentDate'] as String? ?? '',
      appointmentTime: json['appointmentTime'] as String? ?? '',
      visitType: VisitType.fromString(json['visitType'] as String? ?? 'GENERAL_CHECKUP'),
      reason: json['reason'] as String? ?? '',
      status: AppointmentStatus.fromString(json['status'] as String? ?? 'PENDING'),
      veterinarianNotes: json['veterinarianNotes'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      version: (json['version'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'veterinarianId': veterinarianId,
      'veterinarianName': veterinarianName,
      'clinicName': clinicName,
      'animalId': animalId,
      'animalName': animalName,
      'tagNumber': tagNumber,
      'species': species,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'visitType': visitType.toServerString(),
      'reason': reason,
      'status': status.name.toUpperCase(),
      'veterinarianNotes': veterinarianNotes,
      'cancellationReason': cancellationReason,
      'version': version,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
