import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/medical_record_api_service.dart';
import '../../data/models/medical_record_dto.dart';
import '../../data/repositories/medical_record_repository_impl.dart';
import '../../domain/repositories/medical_record_repository.dart';

final medicalRecordApiServiceProvider = Provider<MedicalRecordApiService>((ref) {
  return MedicalRecordApiService();
});

final medicalRecordRepositoryProvider = Provider<MedicalRecordRepository>((ref) {
  return MedicalRecordRepositoryImpl(ref.watch(medicalRecordApiServiceProvider));
});

class MedicalRecordState {
  final bool isLoading;
  final String? errorMessage;
  final List<MedicalRecordModel> records;
  final Map<String, List<MedicalRecordModel>> animalHistories;
  final Map<String, MedicalRecordModel?> appointmentRecords;

  MedicalRecordState({
    this.isLoading = false,
    this.errorMessage,
    this.records = const [],
    this.animalHistories = const {},
    this.appointmentRecords = const {},
  });

  MedicalRecordState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<MedicalRecordModel>? records,
    Map<String, List<MedicalRecordModel>>? animalHistories,
    Map<String, MedicalRecordModel?>? appointmentRecords,
  }) {
    return MedicalRecordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      records: records ?? this.records,
      animalHistories: animalHistories ?? this.animalHistories,
      appointmentRecords: appointmentRecords ?? this.appointmentRecords,
    );
  }
}

class MedicalRecordNotifier extends StateNotifier<MedicalRecordState> {
  final MedicalRecordRepository _repository;

  MedicalRecordNotifier(this._repository) : super(MedicalRecordState());

  Future<void> fetchUserRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final records = await _repository.listMedicalRecords();
      state = state.copyWith(isLoading: false, records: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchAnimalHistory(String animalId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final history = await _repository.getAnimalMedicalHistory(animalId);
      final updatedHistories = Map<String, List<MedicalRecordModel>>.from(state.animalHistories);
      updatedHistories[animalId] = history;
      state = state.copyWith(isLoading: false, animalHistories: updatedHistories);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<MedicalRecordModel?> fetchRecordForAppointment(String appointmentId) async {
    try {
      final record = await _repository.getMedicalRecordByAppointmentId(appointmentId);
      final updatedApptRecords = Map<String, MedicalRecordModel?>.from(state.appointmentRecords);
      updatedApptRecords[appointmentId] = record;
      state = state.copyWith(appointmentRecords: updatedApptRecords);
      return record;
    } catch (_) {
      return null;
    }
  }

  Future<bool> createRecord(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final record = await _repository.createMedicalRecord(body);
      final updatedRecords = [record, ...state.records];
      
      final updatedApptRecords = Map<String, MedicalRecordModel?>.from(state.appointmentRecords);
      updatedApptRecords[record.appointmentId] = record;

      if (state.animalHistories.containsKey(record.animalId)) {
        final updatedHistories = Map<String, List<MedicalRecordModel>>.from(state.animalHistories);
        updatedHistories[record.animalId] = [record, ...(updatedHistories[record.animalId] ?? [])];
        state = state.copyWith(
          isLoading: false,
          records: updatedRecords,
          appointmentRecords: updatedApptRecords,
          animalHistories: updatedHistories,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          records: updatedRecords,
          appointmentRecords: updatedApptRecords,
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final medicalRecordProvider = StateNotifierProvider<MedicalRecordNotifier, MedicalRecordState>((ref) {
  return MedicalRecordNotifier(ref.watch(medicalRecordRepositoryProvider));
});
