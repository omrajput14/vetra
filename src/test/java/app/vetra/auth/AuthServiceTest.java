package app.vetra.auth;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import app.vetra.auth.dto.AuthResponse;
import app.vetra.auth.dto.ChangePasswordRequest;
import app.vetra.auth.dto.FarmerRegisterRequest;
import app.vetra.auth.dto.LoginRequest;
import app.vetra.auth.dto.RefreshTokenRequest;

import app.vetra.auth.dto.VetRegisterRequest;
import app.vetra.auth.service.AuthService;
import app.vetra.infrastructure.persistence.enums.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

/**
 * Integration & unit tests for AuthService.
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:vetra_auth_test;DB_CLOSE_DELAY=-1;MODE=PostgreSQL",
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
class AuthServiceTest {

  @Autowired
  private AuthService authService;

  @Test
  void testFarmerRegistrationAndLoginFlow() {
    FarmerRegisterRequest registerRequest = new FarmerRegisterRequest(
        "farmer@vetra.app",
        "+1555019283",
        "secret123",
        "John Farmer",
        "Green Valley Farm",
        "Oak Village",
        "Central District",
        "State Region",
        12.34,
        56.78,
        25
    );

    AuthResponse regResponse = authService.registerFarmer(registerRequest);
    assertNotNull(regResponse.accessToken());
    assertNotNull(regResponse.refreshToken());
    assertEquals(UserRole.FARMER, regResponse.user().role());
    assertEquals("John Farmer", regResponse.user().fullName());

    LoginRequest loginRequest = new LoginRequest("farmer@vetra.app", "secret123");
    AuthResponse loginResponse = authService.loginFarmer(loginRequest);
    assertNotNull(loginResponse.accessToken());
    assertEquals(UserRole.FARMER, loginResponse.user().role());
  }

  @Test
  void testVetRegistrationAndLoginFlow() {
    VetRegisterRequest registerRequest = new VetRegisterRequest(
        "dr.jenkins@vetra.app",
        "+1555019883",
        "vetpass123",
        "Dr. Sarah Jenkins",
        "VET-REG-9941",
        "BVSc & AH",
        "Ruminant Surgery",
        "Valley Vet Hospital",
        12,
        12.35,
        56.79
    );

    AuthResponse regResponse = authService.registerVet(registerRequest);
    assertNotNull(regResponse.accessToken());
    assertNotNull(regResponse.refreshToken());
    assertEquals(UserRole.VETERINARIAN, regResponse.user().role());
    assertEquals("Dr. Sarah Jenkins", regResponse.user().fullName());
    assertEquals("VET-REG-9941", regResponse.user().registrationNumber());

    LoginRequest loginRequest = new LoginRequest("dr.jenkins@vetra.app", "vetpass123");
    AuthResponse loginResponse = authService.loginVet(loginRequest);
    assertNotNull(loginResponse.accessToken());
    assertEquals(UserRole.VETERINARIAN, loginResponse.user().role());
  }

  @Test
  void testRefreshTokenAndChangePassword() {
    FarmerRegisterRequest registerRequest = new FarmerRegisterRequest(
        "refresh@vetra.app",
        "+1555019999",
        "oldpass123",
        "Test User",
        "Test Farm",
        "Village",
        "District",
        "State",
        0.0,
        0.0,
        5
    );

    AuthResponse regResponse = authService.registerFarmer(registerRequest);

    AuthResponse refreshResponse = authService.refreshToken(new RefreshTokenRequest(regResponse.refreshToken()));
    assertNotNull(refreshResponse.accessToken());

    authService.changePassword("refresh@vetra.app", new ChangePasswordRequest("oldpass123", "newpass456"));

    AuthResponse newLogin = authService.loginFarmer(new LoginRequest("refresh@vetra.app", "newpass456"));
    assertNotNull(newLogin.accessToken());

    assertThrows(IllegalArgumentException.class, () ->
        authService.loginFarmer(new LoginRequest("refresh@vetra.app", "oldpass123")));
  }
}
