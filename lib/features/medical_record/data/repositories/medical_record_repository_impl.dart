import '../models/medical_record_dto.dart';
import '../../data/api/medical_record_api_service.dart';
import '../../domain/repositories/medical_record_repository.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordApiService _apiService;

  MedicalRecordRepositoryImpl(this._apiService);

  @override
  Future<MedicalRecordModel> createMedicalRecord(Map<String, dynamic> body) async {
    final response = await _apiService.createMedicalRecord(body);
    final data = response['data'] as Map<String, dynamic>;
    return MedicalRecordModel.fromMap(data);
  }

  @override
  Future<List<MedicalRecordModel>> listMedicalRecords() async {
    final response = await _apiService.listMedicalRecords();
    final data = response['data'] as List<dynamic>;
    return data.map((e) => MedicalRecordModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<MedicalRecordModel> getMedicalRecordById(String id) async {
    final response = await _apiService.getMedicalRecordById(id);
    final data = response['data'] as Map<String, dynamic>;
    return MedicalRecordModel.fromMap(data);
  }

  @override
  Future<List<MedicalRecordModel>> getAnimalMedicalHistory(String animalId) async {
    final response = await _apiService.getAnimalMedicalHistory(animalId);
    final data = response['data'] as List<dynamic>;
    return data.map((e) => MedicalRecordModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<MedicalRecordModel?> getMedicalRecordByAppointmentId(String appointmentId) async {
    try {
      final response = await _apiService.getMedicalRecordByAppointmentId(appointmentId);
      if (response['data'] != null) {
        return MedicalRecordModel.fromMap(response['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
