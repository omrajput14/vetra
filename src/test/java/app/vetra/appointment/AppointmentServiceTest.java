package app.vetra.appointment;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import app.vetra.animal.dto.AnimalResponse;
import app.vetra.animal.dto.CreateAnimalRequest;
import app.vetra.animal.service.AnimalService;
import app.vetra.appointment.dto.AppointmentResponse;
import app.vetra.appointment.dto.CreateAppointmentRequest;
import app.vetra.appointment.dto.UpdateAppointmentStatusRequest;
import app.vetra.appointment.service.AppointmentService;
import app.vetra.auth.dto.FarmerRegisterRequest;
import app.vetra.auth.dto.VetRegisterRequest;

import app.vetra.auth.repository.VetProfileRepository;
import app.vetra.auth.service.AuthService;
import app.vetra.dashboard.dto.DashboardResponse;
import app.vetra.dashboard.service.DashboardService;
import app.vetra.infrastructure.persistence.entity.VetProfile;
import app.vetra.infrastructure.persistence.enums.AnimalGender;
import app.vetra.infrastructure.persistence.enums.AppointmentStatus;
import app.vetra.infrastructure.persistence.enums.Species;
import app.vetra.infrastructure.persistence.enums.VisitType;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

/**
 * Unit & Integration tests for AppointmentService state machine and business rules.
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:vetra_appointment_test;DB_CLOSE_DELAY=-1;MODE=PostgreSQL",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.datasource.username=sa",
    "spring.datasource.password=",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.jpa.database-platform=org.hibernate.dialect.H2Dialect",
    "spring.flyway.enabled=false",
    "vetra.jwt.secret=test-jwt-secret-value-minimum-32-characters-long",
    "vetra.jwt.expiration-ms=86400000",
    "vetra.jwt.refresh-expiration-ms=604800000",
    "vetra.cors.allowed-origins=http://localhost:3000",
    "vetra.cors.allowed-methods=GET,POST,PUT,DELETE,PATCH,OPTIONS",
    "vetra.cors.allowed-headers=*",
    "vetra.cors.allow-credentials=true",
    "vetra.cors.max-age=3600",
    "vetra.aws.region=ap-south-1",
    "vetra.aws.credentials.access-key=test-key",
    "vetra.aws.credentials.secret-key=test-secret",
    "vetra.aws.s3.bucket-name=vetra-test-bucket",
    "vetra.aws.s3.presigned-url-expiry-minutes=15",
})
class AppointmentServiceTest {

  @Autowired
  private AppointmentService appointmentService;

  @Autowired
  private AnimalService animalService;

  @Autowired
  private AuthService authService;

  @Autowired
  private VetProfileRepository vetProfileRepository;

  @Autowired
  private DashboardService dashboardService;

  @Test
  void testCompleteAppointmentLifecycleAndStateMachine() {
    // 1. Register Farmer
    FarmerRegisterRequest farmerReq = new FarmerRegisterRequest(
        "farmer_app@vetra.app", "+1555099111", "pass123", "Farmer John", "Sunrise Farm",
        "Village", "District", "State", 12.0, 56.0, 5);
    authService.registerFarmer(farmerReq);

    // 2. Register Veterinarian
    VetRegisterRequest vetReq = new VetRegisterRequest(
        "vet_app@vetra.app", "+1555099222", "pass123", "Dr. Sarah", "VET-REG-8899",
        "BVSc & AH", "Bovine Surgery", "City Vet Clinic", 8, 12.1, 56.1);
    authService.registerVet(vetReq);

    VetProfile vetProfile = vetProfileRepository.findAll().get(0);

    // 3. Register Animal for Farmer
    CreateAnimalRequest createAnimalReq = new CreateAnimalRequest(
        "Bella", "TAG-BELL-1", "QR-BELL-1", Species.CATTLE, "Jersey", AnimalGender.FEMALE,
        LocalDate.of(2023, 1, 15), null);
    AnimalResponse animal = animalService.createAnimal("farmer_app@vetra.app", createAnimalReq);

    // 4. Create Appointment (Farmer)
    CreateAppointmentRequest appReq = new CreateAppointmentRequest(
        animal.id(), vetProfile.getId(), LocalDate.now().plusDays(2), LocalTime.of(10, 30),
        VisitType.GENERAL_CHECKUP, "Routine health inspection");

    AppointmentResponse createdApp = appointmentService.createAppointment("farmer_app@vetra.app", appReq);
    assertNotNull(createdApp.id());
    assertEquals(AppointmentStatus.PENDING, createdApp.status());

    // 5. Verify Past Date rejection
    CreateAppointmentRequest pastAppReq = new CreateAppointmentRequest(
        animal.id(), vetProfile.getId(), LocalDate.now().minusDays(1), LocalTime.of(10, 30),
        VisitType.VACCINATION, "Past vaccination");
    assertThrows(IllegalArgumentException.class, () ->
        appointmentService.createAppointment("farmer_app@vetra.app", pastAppReq));

    // 6. Dashboard metrics reflect pending count
    DashboardResponse farmerDash = dashboardService.getDashboardMetrics("farmer_app@vetra.app");
    assertEquals(1, farmerDash.pendingAppointmentsCount());

    DashboardResponse vetDash = dashboardService.getDashboardMetrics("vet_app@vetra.app");
    assertEquals(1, vetDash.pendingAppointmentsCount());

    // 7. Vet lists appointments
    List<AppointmentResponse> vetList = appointmentService.listAppointments("vet_app@vetra.app");
    assertEquals(1, vetList.size());
    assertEquals(createdApp.id(), vetList.get(0).id());

    // 8. Vet Confirms Appointment
    AppointmentResponse confirmed = appointmentService.confirmAppointment("vet_app@vetra.app", createdApp.id());
    assertEquals(AppointmentStatus.CONFIRMED, confirmed.status());

    // 9. Vet Completes Appointment with Notes
    AppointmentResponse completed = appointmentService.completeAppointment(
        "vet_app@vetra.app", createdApp.id(), "Animal is healthy. Administered vitamin supplement.");
    assertEquals(AppointmentStatus.COMPLETED, completed.status());
    assertEquals("Animal is healthy. Administered vitamin supplement.", completed.veterinarianNotes());

    // 10. Attempting transition from Terminal state throws exception
    assertThrows(IllegalStateException.class, () ->
        appointmentService.updateStatus("farmer_app@vetra.app", createdApp.id(),
            new UpdateAppointmentStatusRequest(AppointmentStatus.CANCELLED, null, "Tried to cancel completed")));
  }
}
