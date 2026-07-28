package app.vetra.medicalrecord.service;

import app.vetra.auth.repository.FarmerProfileRepository;
import app.vetra.auth.repository.UserRepository;
import app.vetra.auth.repository.VetProfileRepository;
import app.vetra.appointment.repository.AppointmentRepository;
import app.vetra.infrastructure.persistence.entity.Animal;
import app.vetra.infrastructure.persistence.entity.Appointment;
import app.vetra.infrastructure.persistence.entity.FarmerProfile;
import app.vetra.infrastructure.persistence.entity.MedicalRecord;
import app.vetra.infrastructure.persistence.entity.User;
import app.vetra.infrastructure.persistence.entity.VetProfile;
import app.vetra.infrastructure.persistence.enums.AppointmentStatus;
import app.vetra.infrastructure.persistence.enums.UserRole;
import app.vetra.animal.repository.AnimalRepository;
import app.vetra.medicalrecord.dto.CreateMedicalRecordRequest;
import app.vetra.medicalrecord.dto.MedicalRecordResponse;
import app.vetra.medicalrecord.repository.MedicalRecordRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Business logic service for Electronic Veterinary Medical Records (EVMR).
 * Enforces strict immutability, state validation, and authorization boundaries.
 */
@Service
public class MedicalRecordService {

  private final MedicalRecordRepository medicalRecordRepository;
  private final AppointmentRepository appointmentRepository;
  private final AnimalRepository animalRepository;
  private final UserRepository userRepository;
  private final FarmerProfileRepository farmerProfileRepository;
  private final VetProfileRepository vetProfileRepository;

  /** Constructor injection. */
  public MedicalRecordService(
      MedicalRecordRepository medicalRecordRepository,
      AppointmentRepository appointmentRepository,
      AnimalRepository animalRepository,
      UserRepository userRepository,
      FarmerProfileRepository farmerProfileRepository,
      VetProfileRepository vetProfileRepository) {
    this.medicalRecordRepository = medicalRecordRepository;
    this.appointmentRepository = appointmentRepository;
    this.animalRepository = animalRepository;
    this.userRepository = userRepository;
    this.farmerProfileRepository = farmerProfileRepository;
    this.vetProfileRepository = vetProfileRepository;
  }

  /**
   * Creates an Electronic Veterinary Medical Record for a completed appointment.
   * Only assigned veterinarians can issue medical records.
   */
  @Transactional
  public MedicalRecordResponse createMedicalRecord(String userIdentifier, CreateMedicalRecordRequest request) {
    User user = getUserByEmailOrPhone(userIdentifier);
    if (user.getRole() != UserRole.VETERINARIAN) {
      throw new AccessDeniedException("Only veterinarians can create medical records");
    }

    VetProfile vetProfile = vetProfileRepository.findByUserId(user.getId())
        .orElseThrow(() -> new AccessDeniedException("Veterinarian profile not found"));

    Appointment appointment = appointmentRepository.findById(request.appointmentId())
        .orElseThrow(() -> new IllegalArgumentException("Appointment not found with ID: " + request.appointmentId()));

    if (appointment.getStatus() != AppointmentStatus.COMPLETED) {
      throw new IllegalArgumentException("Medical record can only be created for COMPLETED appointments");
    }

    if (!appointment.getVeterinarian().getId().equals(vetProfile.getId())) {
      throw new AccessDeniedException("Veterinarians can only create medical records for appointments assigned to them");
    }

    if (medicalRecordRepository.existsByAppointmentId(request.appointmentId())) {
      throw new DataIntegrityViolationException("A medical record already exists for this appointment");
    }

    if (request.followUpDate() != null && request.followUpDate().isBefore(LocalDate.now())) {
      throw new IllegalArgumentException("Follow-up date cannot be in the past");
    }

    MedicalRecord record = MedicalRecord.builder()
        .appointment(appointment)
        .animal(appointment.getAnimal())
        .farmer(appointment.getFarmer())
        .veterinarian(vetProfile)
        .diagnosis(request.diagnosis().trim())
        .symptoms(request.symptoms() != null ? request.symptoms().trim() : null)
        .treatment(request.treatment().trim())
        .prescription(request.prescription() != null ? request.prescription().trim() : null)
        .weight(request.weight())
        .temperature(request.temperature())
        .followUpDate(request.followUpDate())
        .notes(request.notes() != null ? request.notes().trim() : null)
        .build();

    MedicalRecord saved = medicalRecordRepository.save(record);
    return MedicalRecordResponse.fromEntity(saved);
  }

  /** Retrieves a medical record by ID with authorization checks. */
  @Transactional(readOnly = true)
  public MedicalRecordResponse getMedicalRecordById(String userIdentifier, UUID recordId) {
    User user = getUserByEmailOrPhone(userIdentifier);
    MedicalRecord record = medicalRecordRepository.findById(recordId)
        .orElseThrow(() -> new IllegalArgumentException("Medical record not found with ID: " + recordId));

    validateRecordAccess(user, record);
    return MedicalRecordResponse.fromEntity(record);
  }

  /** Retrieves a medical record associated with an appointment ID. */
  @Transactional(readOnly = true)
  public MedicalRecordResponse getMedicalRecordByAppointmentId(String userIdentifier, UUID appointmentId) {
    User user = getUserByEmailOrPhone(userIdentifier);
    MedicalRecord record = medicalRecordRepository.findByAppointmentId(appointmentId)
        .orElseThrow(() -> new IllegalArgumentException("Medical record not found for appointment: " + appointmentId));

    validateRecordAccess(user, record);
    return MedicalRecordResponse.fromEntity(record);
  }

  /** Retrieves full medical history for a specific animal. */
  @Transactional(readOnly = true)
  public List<MedicalRecordResponse> getAnimalMedicalHistory(String userIdentifier, UUID animalId) {
    User user = getUserByEmailOrPhone(userIdentifier);
    Animal animal = animalRepository.findById(animalId)
        .orElseThrow(() -> new IllegalArgumentException("Animal not found with ID: " + animalId));

    if (user.getRole() == UserRole.FARMER) {
      FarmerProfile farmer = farmerProfileRepository.findByUserId(user.getId())
          .orElseThrow(() -> new AccessDeniedException("Farmer profile not found"));
      if (!animal.getFarmer().getId().equals(farmer.getId())) {
        throw new AccessDeniedException("Farmers can only view medical records belonging to their own animals");
      }
    }

    return medicalRecordRepository.findByAnimalIdOrderByCreatedAtDesc(animalId).stream()
        .map(MedicalRecordResponse::fromEntity)
        .toList();
  }

  /** Lists medical records for current user (Farmer or Vet). */
  @Transactional(readOnly = true)
  public List<MedicalRecordResponse> listMedicalRecords(String userIdentifier) {
    User user = getUserByEmailOrPhone(userIdentifier);
    if (user.getRole() == UserRole.FARMER) {
      FarmerProfile farmer = farmerProfileRepository.findByUserId(user.getId())
          .orElseThrow(() -> new AccessDeniedException("Farmer profile not found"));
      return medicalRecordRepository.findByFarmerIdOrderByCreatedAtDesc(farmer.getId()).stream()
          .map(MedicalRecordResponse::fromEntity)
          .toList();
    } else {
      VetProfile vet = vetProfileRepository.findByUserId(user.getId())
          .orElseThrow(() -> new AccessDeniedException("Veterinarian profile not found"));
      return medicalRecordRepository.findByVeterinarianIdOrderByCreatedAtDesc(vet.getId()).stream()
          .map(MedicalRecordResponse::fromEntity)
          .toList();
    }
  }

  private void validateRecordAccess(User user, MedicalRecord record) {
    if (user.getRole() == UserRole.FARMER) {
      if (!record.getFarmer().getUser().getId().equals(user.getId())) {
        throw new AccessDeniedException("Farmers can only view medical records belonging to their own animals");
      }
    } else if (user.getRole() == UserRole.VETERINARIAN) {
      if (!record.getVeterinarian().getUser().getId().equals(user.getId())) {
        throw new AccessDeniedException("Veterinarians can only view medical records created by them");
      }
    }
  }

  private User getUserByEmailOrPhone(String identifier) {
    return userRepository.findByEmail(identifier)
        .or(() -> userRepository.findByPhone(identifier))
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + identifier));
  }
}
