import 'package:flutter/material.dart';
import '../../../../core/design_system/app_colors.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  enRoute,
  arrived,
  completed,
  cancelled,
  rejected;

  static AppointmentStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return AppointmentStatus.confirmed;
      case 'EN_ROUTE':
        return AppointmentStatus.enRoute;
      case 'ARRIVED':
        return AppointmentStatus.arrived;
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
      case AppointmentStatus.enRoute:
        return 'En Route';
      case AppointmentStatus.arrived:
        return 'Arrived';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return AppColors.cautionAmber;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.enRoute:
        return AppColors.vetAccent;
      case AppointmentStatus.arrived:
        return Colors.teal;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return AppColors.alertCritical;
      case AppointmentStatus.rejected:
        return const Color(0xFF8E24AA);
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.pending:
        return Icons.hourglass_top;
      case AppointmentStatus.confirmed:
        return Icons.event_available;
      case AppointmentStatus.enRoute:
        return Icons.directions_car;
      case AppointmentStatus.arrived:
        return Icons.location_on;
      case AppointmentStatus.completed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rejected:
        return Icons.block;
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
  final double? vetLatitude;
  final double? vetLongitude;
  final String? vetLocationUpdatedAt;
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
    this.vetLatitude,
    this.vetLongitude,
    this.vetLocationUpdatedAt,
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
      vetLatitude: json['vetLatitude'] != null ? (json['vetLatitude'] as num).toDouble() : null,
      vetLongitude: json['vetLongitude'] != null ? (json['vetLongitude'] as num).toDouble() : null,
      vetLocationUpdatedAt: json['vetLocationUpdatedAt'] as String?,
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
      'vetLatitude': vetLatitude,
      'vetLongitude': vetLongitude,
      'vetLocationUpdatedAt': vetLocationUpdatedAt,
      'version': version,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}


class AppointmentLiveLocationDto {
  final bool isLive;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final String? status;
  final String? message;
  final String? updatedAt;

  AppointmentLiveLocationDto({
    required this.isLive,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.status,
    this.message,
    this.updatedAt,
  });

  factory AppointmentLiveLocationDto.fromJson(Map<String, dynamic> json) {
    return AppointmentLiveLocationDto(
      isLive: json['isLive'] == true,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      distanceKm: json['distanceKm'] != null ? (json['distanceKm'] as num).toDouble() : null,
      status: json['status'] as String?,
      message: json['message'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
