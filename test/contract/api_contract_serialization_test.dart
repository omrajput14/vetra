import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/medical_record/data/models/medical_record_dto.dart';
import 'package:vetra/features/dashboard/data/models/dashboard_dto.dart';

void main() {
  group('API Contract Serialization & Deserialization Tests', () {
    test('AnimalModel correctly deserializes and serializes backend AnimalResponse JSON', () {
      final json = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'farmerId': 'f1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'farmerName': 'Ramesh Kumar',
        'animalName': 'Gauri',
        'tagNumber': 'VETRA-TAG-001',
        'qrCodeId': 'QR-GAURI-001',
        'species': 'CATTLE',
        'breed': 'Gir',
        'gender': 'FEMALE',
        'birthDate': '2022-05-15',
        'photoUrl': 'https://s3.ap-south-1.amazonaws.com/vetra/gauri.jpg',
        'createdAt': '2026-08-16T10:00:00Z',
        'updatedAt': '2026-08-16T10:30:00Z',
      };

      final model = AnimalModel.fromJson(json);

      expect(model.id, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(model.farmerId, 'f1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(model.farmerName, 'Ramesh Kumar');
      expect(model.animalName, 'Gauri');
      expect(model.tagNumber, 'VETRA-TAG-001');
      expect(model.qrCodeId, 'QR-GAURI-001');
      expect(model.species, 'CATTLE');
      expect(model.breed, 'Gir');
      expect(model.gender, 'FEMALE');
      expect(model.birthDate, '2022-05-15');
      expect(model.displayName, 'Gauri');

      final serialized = model.toJson();
      expect(serialized['tagNumber'], 'VETRA-TAG-001');
      expect(serialized['species'], 'CATTLE');
    });

    test('AppointmentModel correctly deserializes backend AppointmentResponse JSON', () {
      final json = {
        'id': 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'farmerId': 'f1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'farmerName': 'Ramesh Kumar',
        'farmerPhone': '+919876543210',
        'veterinarianId': 'v1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'veterinarianName': 'Dr. Priya Sharma',
        'clinicName': 'City Veterinary Clinic',
        'animalId': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'animalName': 'Gauri',
        'tagNumber': 'VETRA-TAG-001',
        'species': 'CATTLE',
        'appointmentDate': '2026-08-20',
        'appointmentTime': '10:00:00',
        'visitType': 'GENERAL_CHECKUP',
        'reason': 'Annual health checkup and vaccination',
        'status': 'PENDING',
        'veterinarianNotes': null,
        'cancellationReason': null,
        'version': 1,
        'createdAt': '2026-08-16T10:00:00Z',
        'updatedAt': '2026-08-16T10:00:00Z',
      };

      final model = AppointmentModel.fromJson(json);

      expect(model.id, 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(model.farmerName, 'Ramesh Kumar');
      expect(model.veterinarianName, 'Dr. Priya Sharma');
      expect(model.animalName, 'Gauri');
      expect(model.visitType, VisitType.generalCheckup);
      expect(model.status, AppointmentStatus.pending);
      expect(model.version, 1);
    });

    test('AppointmentStatus and VisitType handle all backend enum variations', () {
      expect(AppointmentStatus.fromString('PENDING'), AppointmentStatus.pending);
      expect(AppointmentStatus.fromString('CONFIRMED'), AppointmentStatus.confirmed);
      expect(AppointmentStatus.fromString('COMPLETED'), AppointmentStatus.completed);
      expect(AppointmentStatus.fromString('CANCELLED'), AppointmentStatus.cancelled);
      expect(AppointmentStatus.fromString('REJECTED'), AppointmentStatus.rejected);

      expect(VisitType.fromString('GENERAL_CHECKUP'), VisitType.generalCheckup);
      expect(VisitType.fromString('VACCINATION'), VisitType.vaccination);
      expect(VisitType.fromString('EMERGENCY'), VisitType.emergency);
      expect(VisitType.fromString('PREGNANCY'), VisitType.pregnancy);
      expect(VisitType.fromString('SURGERY'), VisitType.surgery);
      expect(VisitType.fromString('FOLLOW_UP'), VisitType.followUp);

      expect(VisitType.vaccination.toServerString(), 'VACCINATION');
      expect(VisitType.emergency.toServerString(), 'EMERGENCY');
    });

    test('MedicalRecordModel correctly deserializes and serializes backend EVMR JSON', () {
      final json = {
        'id': 'm1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'appointmentId': 'b1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'animalId': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'animalName': 'Gauri',
        'tagNumber': 'VETRA-TAG-001',
        'species': 'CATTLE',
        'farmerId': 'f1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'farmerName': 'Ramesh Kumar',
        'veterinarianId': 'v1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'veterinarianName': 'Dr. Priya Sharma',
        'clinicName': 'City Veterinary Clinic',
        'diagnosis': 'Bovine Mastitis (Mild)',
        'symptoms': 'Swelling in left udder quarter, mild fever',
        'treatment': 'Intramammary antibiotic infusion and anti-inflammatory administration',
        'prescription': 'Amoxicillin 500mg intramammary, Meloxicam 15ml IM',
        'weight': 385.50,
        'temperature': 39.4,
        'followUpDate': '2026-08-25',
        'notes': 'Monitor milk yield and somatic cell count closely for 5 days.',
        'createdAt': '2026-08-16T11:00:00Z',
        'updatedAt': '2026-08-16T11:00:00Z',
        'version': 1,
      };

      final model = MedicalRecordModel.fromJson(json);

      expect(model.id, 'm1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(model.diagnosis, 'Bovine Mastitis (Mild)');
      expect(model.weight, 385.50);
      expect(model.temperature, 39.4);
      expect(model.followUpDate, '2026-08-25');
      expect(model.version, 1);

      final map = model.toMap();
      expect(map['diagnosis'], 'Bovine Mastitis (Mild)');
      expect(map['weight'], 385.50);
    });

    test('DashboardModel correctly deserializes backend DashboardResponse JSON', () {
      final json = {
        'registeredAnimalCount': 12,
        'pendingAppointmentsCount': 3,
        'activeAlertsCount': 1,
        'medicalRecordsCreatedCount': 8,
        'userName': 'Ramesh Kumar',
        'facilityName': 'Green Pastures Dairy Farm',
        'role': 'FARMER',
      };

      final model = DashboardModel.fromJson(json);

      expect(model.registeredAnimalCount, 12);
      expect(model.pendingAppointmentsCount, 3);
      expect(model.activeAlertsCount, 1);
      expect(model.medicalRecordsCreatedCount, 8);
      expect(model.userName, 'Ramesh Kumar');
      expect(model.facilityName, 'Green Pastures Dairy Farm');
      expect(model.role, 'FARMER');
    });
  });
}
