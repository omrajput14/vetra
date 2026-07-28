import '../../data/models/medical_record_dto.dart';

abstract class MedicalRecordRepository {
  Future<MedicalRecordModel> createMedicalRecord(Map<String, dynamic> body);
  Future<List<MedicalRecordModel>> listMedicalRecords();
  Future<MedicalRecordModel> getMedicalRecordById(String id);
  Future<List<MedicalRecordModel>> getAnimalMedicalHistory(String animalId);
  Future<MedicalRecordModel?> getMedicalRecordByAppointmentId(String appointmentId);
}
