import 'package:flutter/foundation.dart';
import '../../data/models/appointment_dto.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/repositories/appointment_repository.dart';
import 'package:vetra/features/dashboard/presentation/providers/dashboard_provider.dart';

class AppointmentNotifier extends ChangeNotifier {
  final AppointmentRepository _repository = AppointmentRepositoryImpl();

  List<AppointmentModel> _appointments = [];
  AppointmentModel? _selectedAppointment;
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  AppointmentModel? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<AppointmentModel> get pendingAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.pending).toList();

  List<AppointmentModel> get upcomingAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.confirmed).toList();

  List<AppointmentModel> get completedAppointments =>
      _appointments.where((a) => a.status == AppointmentStatus.completed).toList();

  Future<void> loadAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _repository.listAppointments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel?> getAppointmentById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedAppointment = await _repository.getAppointmentById(id);
      return _selectedAppointment;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment({
    required String animalId,
    required String veterinarianId,
    required String appointmentDate,
    required String appointmentTime,
    required VisitType visitType,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final app = await _repository.createAppointment(
        animalId: animalId,
        veterinarianId: veterinarianId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        visitType: visitType,
        reason: reason,
      );
      _appointments.insert(0, app);
      dashboardNotifier.loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmAppointment(String id) async {
    return _updateAppointmentState(() => _repository.confirmAppointment(id));
  }

  Future<bool> rejectAppointment(String id, {String? reason}) async {
    return _updateAppointmentState(() => _repository.rejectAppointment(id, reason: reason));
  }

  Future<bool> completeAppointment(String id, {String? notes}) async {
    return _updateAppointmentState(() => _repository.completeAppointment(id, notes: notes));
  }

  Future<bool> cancelAppointment(String id, {String? reason}) async {
    return _updateAppointmentState(() => _repository.cancelAppointment(id, reason: reason));
  }

  Future<bool> _updateAppointmentState(Future<AppointmentModel> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await action();
      final index = _appointments.indexWhere((a) => a.id == updated.id);
      if (index != -1) {
        _appointments[index] = updated;
      }
      if (_selectedAppointment?.id == updated.id) {
        _selectedAppointment = updated;
      }
      dashboardNotifier.loadDashboard();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

final appointmentNotifier = AppointmentNotifier();
