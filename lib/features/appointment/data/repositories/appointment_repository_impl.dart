import '../../data/api/appointment_api_service.dart';
import '../../data/models/appointment_dto.dart';
import '../../domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentApiService _apiService = AppointmentApiService();

  @override
  Future<AppointmentModel> createAppointment({
    required String animalId,
    required String veterinarianId,
    required String appointmentDate,
    required String appointmentTime,
    required VisitType visitType,
    required String reason,
  }) async {
    final body = {
      'animalId': animalId,
      'veterinarianId': veterinarianId,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'visitType': visitType.toServerString(),
      'reason': reason,
    };
    final res = await _apiService.createAppointment(body);
    final data = res['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  @override
  Future<List<AppointmentModel>> listAppointments() async {
    final res = await _apiService.listAppointments();
    final dataList = res['data'] as List<dynamic>? ?? [];
    return dataList
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    final res = await _apiService.getAppointmentById(id);
    final data = res['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  @override
  Future<AppointmentModel> confirmAppointment(String id) async {
    final res = await _apiService.confirmAppointment(id);
    final data = res['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  @override
  Future<AppointmentModel> rejectAppointment(String id, {String? reason}) async {
    final res = await _apiService.rejectAppointment(id, reason: reason);
    final data = res['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  @override
  Future<AppointmentModel> completeAppointment(String id, {String? notes}) async {
    final res = await _apiService.completeAppointment(id, notes: notes);
    final data = res['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id, {String? reason}) async {
    final res = await _apiService.cancelAppointment(id, reason: reason);
    final data = res['data'] as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }
}
