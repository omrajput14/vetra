import '../../data/models/appointment_dto.dart';

abstract class AppointmentRepository {
  Future<AppointmentModel> createAppointment({
    required String animalId,
    required String veterinarianId,
    required String appointmentDate,
    required String appointmentTime,
    required VisitType visitType,
    required String reason,
  });

  Future<List<AppointmentModel>> listAppointments();

  Future<AppointmentModel> getAppointmentById(String id);

  Future<AppointmentModel> confirmAppointment(String id);

  Future<AppointmentModel> rejectAppointment(String id, {String? reason});

  Future<AppointmentModel> completeAppointment(String id, {String? notes});

  Future<AppointmentModel> cancelAppointment(String id, {String? reason});
}
