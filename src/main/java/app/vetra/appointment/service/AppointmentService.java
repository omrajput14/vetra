package app.vetra.appointment.service;

import app.vetra.animal.repository.AnimalRepository;
import app.vetra.appointment.dto.AppointmentResponse;
import app.vetra.appointment.dto.CreateAppointmentRequest;
import app.vetra.appointment.dto.UpdateAppointmentStatusRequest;
import app.vetra.appointment.repository.AppointmentRepository;
import app.vetra.auth.repository.FarmerProfileRepository;
import app.vetra.auth.repository.UserRepository;
import app.vetra.auth.repository.VetProfileRepository;
import app.vetra.infrastructure.persistence.entity.Animal;
import app.vetra.infrastructure.persistence.entity.Appointment;
import app.vetra.infrastructure.persistence.entity.FarmerProfile;
import app.vetra.infrastructure.persistence.entity.User;
import app.vetra.infrastructure.persistence.entity.VetProfile;
import app.vetra.infrastructure.persistence.enums.AppointmentStatus;
import app.vetra.infrastructure.persistence.enums.UserRole;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service managing appointment lifecycle and business state machine.
 */
@Service
public class AppointmentService {

  private final AppointmentRepository appointmentRepository;
  private final UserRepository userRepository;
  private final FarmerProfileRepository farmerProfileRepository;
  private final VetProfileRepository vetProfileRepository;
  private final AnimalRepository animalRepository;

  /** Constructor injection. */
  public AppointmentService(
      AppointmentRepository appointmentRepository,
      UserRepository userRepository,
      FarmerProfileRepository farmerProfileRepository,
      VetProfileRepository vetProfileRepository,
      AnimalRepository animalRepository) {
    this.appointmentRepository = appointmentRepository;
    this.userRepository = userRepository;
    this.farmerProfileRepository = farmerProfileRepository;
    this.vetProfileRepository = vetProfileRepository;
    this.animalRepository = animalRepository;
  }

  /** Creates a new appointment for the authenticated farmer. */
  @Transactional
  public AppointmentResponse createAppointment(
      String currentUserIdentifier, CreateAppointmentRequest request) {
    User user = getUserByEmail(currentUserIdentifier);
    if (user.getRole() != UserRole.FARMER) {
      throw new IllegalArgumentException("Only registered farmers can request appointments");
    }

    FarmerProfile farmer = farmerProfileRepository.findByUser(user)
        .orElseThrow(() -> new IllegalArgumentException("Farmer profile not found"));

    if (request.appointmentDate().isBefore(LocalDate.now())) {
      throw new IllegalArgumentException("Appointment date cannot be in the past");
    }

    Animal animal = animalRepository.findById(request.animalId())
        .orElseThrow(() -> new IllegalArgumentException("Animal not found"));

    if (!animal.getFarmer().getId().equals(farmer.getId())) {
      throw new IllegalArgumentException("Animal does not belong to the requesting farmer");
    }

    VetProfile vet = vetProfileRepository.findById(request.veterinarianId())
        .orElseThrow(() -> new IllegalArgumentException("Veterinarian not found"));

    Appointment appointment = Appointment.builder()
        .farmer(farmer)
        .veterinarian(vet)
        .animal(animal)
        .appointmentDate(request.appointmentDate())
        .appointmentTime(request.appointmentTime())
        .visitType(request.visitType())
        .reason(request.reason())
        .status(AppointmentStatus.PENDING)
        .build();

    Appointment saved = appointmentRepository.save(appointment);
    return AppointmentResponse.fromEntity(saved);
  }

  /** Retrieves all appointments relevant to the current user. */
  @Transactional(readOnly = true)
  public List<AppointmentResponse> listAppointments(String currentUserIdentifier) {
    User user = getUserByEmail(currentUserIdentifier);

    List<Appointment> appointments;
    if (user.getRole() == UserRole.FARMER) {
      FarmerProfile farmer = farmerProfileRepository.findByUser(user)
          .orElseThrow(() -> new IllegalArgumentException("Farmer profile not found"));
      appointments = appointmentRepository.findByFarmerOrderByAppointmentDateDescAppointmentTimeDesc(farmer);
    } else if (user.getRole() == UserRole.VETERINARIAN) {
      VetProfile vet = vetProfileRepository.findByUser(user)
          .orElseThrow(() -> new IllegalArgumentException("Vet profile not found"));
      appointments = appointmentRepository.findByVeterinarianOrderByAppointmentDateDescAppointmentTimeDesc(vet);
    } else {
      appointments = appointmentRepository.findAll();
    }

    return appointments.stream().map(AppointmentResponse::fromEntity).toList();
  }

  /** Retrieves a specific appointment by ID. */
  @Transactional(readOnly = true)
  public AppointmentResponse getAppointmentById(String currentUserIdentifier, UUID id) {
    User user = getUserByEmail(currentUserIdentifier);
    Appointment appointment = appointmentRepository.findById(id)
        .orElseThrow(() -> new IllegalArgumentException("Appointment not found"));

    validateUserAccess(user, appointment);
    return AppointmentResponse.fromEntity(appointment);
  }

  /** Updates appointment status according to centralized state machine rules. */
  @Transactional
  public AppointmentResponse updateStatus(
      String currentUserIdentifier, UUID id, UpdateAppointmentStatusRequest request) {
    User user = getUserByEmail(currentUserIdentifier);
    Appointment appointment = appointmentRepository.findById(id)
        .orElseThrow(() -> new IllegalArgumentException("Appointment not found"));

    validateUserAccess(user, appointment);
    applyStateTransition(user, appointment, request.status(), request.notes(), request.cancellationReason());

    Appointment updated = appointmentRepository.save(appointment);
    return AppointmentResponse.fromEntity(updated);
  }

  /** Delegate helper for confirming an appointment (Vet only). */
  @Transactional
  public AppointmentResponse confirmAppointment(String currentUserIdentifier, UUID id) {
    return updateStatus(currentUserIdentifier, id,
        new UpdateAppointmentStatusRequest(AppointmentStatus.CONFIRMED, null, null));
  }

  /** Delegate helper for rejecting an appointment (Vet only). */
  @Transactional
  public AppointmentResponse rejectAppointment(String currentUserIdentifier, UUID id, String reason) {
    return updateStatus(currentUserIdentifier, id,
        new UpdateAppointmentStatusRequest(AppointmentStatus.REJECTED, null, reason));
  }

  /** Delegate helper for completing an appointment (Vet only). */
  @Transactional
  public AppointmentResponse completeAppointment(String currentUserIdentifier, UUID id, String notes) {
    return updateStatus(currentUserIdentifier, id,
        new UpdateAppointmentStatusRequest(AppointmentStatus.COMPLETED, notes, null));
  }

  /** Delegate helper for cancelling an appointment (Farmer). */
  @Transactional
  public AppointmentResponse cancelAppointment(String currentUserIdentifier, UUID id, String reason) {
    return updateStatus(currentUserIdentifier, id,
        new UpdateAppointmentStatusRequest(AppointmentStatus.CANCELLED, null, reason));
  }

  /** Centralized state machine transition logic. */
  private void applyStateTransition(
      User user, Appointment appointment, AppointmentStatus targetStatus, String notes, String cancellationReason) {
    AppointmentStatus currentStatus = appointment.getStatus();

    if (currentStatus.isTerminal()) {
      throw new IllegalStateException("Terminal appointments (COMPLETED, CANCELLED, REJECTED) cannot be edited");
    }

    validateAllowedTransition(currentStatus, targetStatus);
    validateRolePermissions(user, targetStatus);

    appointment.setStatus(targetStatus);
    if (notes != null && !notes.isBlank()) {
      appointment.setVeterinarianNotes(notes);
    }
    if (cancellationReason != null && !cancellationReason.isBlank()) {
      appointment.setCancellationReason(cancellationReason);
    }
  }

  private void validateAllowedTransition(AppointmentStatus current, AppointmentStatus target) {
    if (current == AppointmentStatus.PENDING) {
      if (target != AppointmentStatus.CONFIRMED && target != AppointmentStatus.REJECTED && target != AppointmentStatus.CANCELLED) {
        throw new IllegalArgumentException("Invalid state transition from PENDING to " + target);
      }
    } else if (current == AppointmentStatus.CONFIRMED) {
      if (target != AppointmentStatus.COMPLETED && target != AppointmentStatus.CANCELLED) {
        throw new IllegalArgumentException("Invalid state transition from CONFIRMED to " + target);
      }
    }
  }

  private void validateRolePermissions(User user, AppointmentStatus targetStatus) {
    boolean isVetAction = targetStatus == AppointmentStatus.CONFIRMED
        || targetStatus == AppointmentStatus.REJECTED
        || targetStatus == AppointmentStatus.COMPLETED;

    if (isVetAction && user.getRole() != UserRole.VETERINARIAN) {
      throw new IllegalArgumentException("Only veterinarians can " + targetStatus.name().toLowerCase() + " appointments");
    }

    if (targetStatus == AppointmentStatus.CANCELLED && user.getRole() != UserRole.FARMER) {
      throw new IllegalArgumentException("Only requesting farmers can cancel appointments");
    }
  }

  private void validateUserAccess(User user, Appointment appointment) {
    if (user.getRole() == UserRole.FARMER) {
      FarmerProfile farmer = farmerProfileRepository.findByUser(user)
          .orElseThrow(() -> new IllegalArgumentException("Farmer profile not found"));
      if (!appointment.getFarmer().getId().equals(farmer.getId())) {
        throw new IllegalArgumentException("Unauthorized access to farmer appointment");
      }
    } else if (user.getRole() == UserRole.VETERINARIAN) {
      VetProfile vet = vetProfileRepository.findByUser(user)
          .orElseThrow(() -> new IllegalArgumentException("Vet profile not found"));
      if (!appointment.getVeterinarian().getId().equals(vet.getId())) {
        throw new IllegalArgumentException("Unauthorized access to veterinarian appointment");
      }
    }
  }

  private User getUserByEmail(String email) {
    return userRepository.findByIdentifier(email)
        .orElseThrow(() -> new IllegalArgumentException("User not found: " + email));
  }
}
