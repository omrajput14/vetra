package app.vetra.dashboard.service;

import app.vetra.animal.repository.AnimalRepository;
import app.vetra.auth.repository.FarmerProfileRepository;
import app.vetra.auth.repository.UserRepository;
import app.vetra.auth.repository.VetProfileRepository;
import app.vetra.dashboard.dto.DashboardResponse;
import app.vetra.infrastructure.persistence.entity.FarmerProfile;
import app.vetra.infrastructure.persistence.entity.User;
import app.vetra.infrastructure.persistence.entity.VetProfile;
import app.vetra.infrastructure.persistence.enums.UserRole;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Business service providing unified dashboard metrics.
 */
@Service
public class DashboardService {

  private final UserRepository userRepository;
  private final FarmerProfileRepository farmerProfileRepository;
  private final VetProfileRepository vetProfileRepository;
  private final AnimalRepository animalRepository;

  /** Constructor injection. */
  public DashboardService(
      UserRepository userRepository,
      FarmerProfileRepository farmerProfileRepository,
      VetProfileRepository vetProfileRepository,
      AnimalRepository animalRepository) {
    this.userRepository = userRepository;
    this.farmerProfileRepository = farmerProfileRepository;
    this.vetProfileRepository = vetProfileRepository;
    this.animalRepository = animalRepository;
  }

  /** Aggregates dashboard stats in a single backend call. */
  @Transactional(readOnly = true)
  public DashboardResponse getDashboardMetrics(String currentUserIdentifier) {
    User user = userRepository.findByIdentifier(currentUserIdentifier)
        .orElseThrow(() -> new IllegalArgumentException("User not found"));

    long animalCount = 0;
    String userName = user.getEmail();
    String facilityName = "Vetra System";

    if (user.getRole() == UserRole.FARMER) {
      Optional<FarmerProfile> farmerOpt = farmerProfileRepository.findByUser(user);
      if (farmerOpt.isPresent()) {
        FarmerProfile farmer = farmerOpt.get();
        userName = farmer.getFullName() != null ? farmer.getFullName() : user.getEmail();
        facilityName = farmer.getFarmName() != null ? farmer.getFarmName() : "My Livestock Farm";
        animalCount = animalRepository.countByFarmer(farmer);
      }
    } else if (user.getRole() == UserRole.VETERINARIAN) {
      Optional<VetProfile> vetOpt = vetProfileRepository.findByUser(user);
      if (vetOpt.isPresent()) {
        VetProfile vet = vetOpt.get();
        userName = vet.getFullName() != null ? vet.getFullName() : user.getEmail();
        facilityName = vet.getClinicName() != null ? vet.getClinicName() : "Clinical Practice";
      }
      animalCount = animalRepository.count();
    }

    return new DashboardResponse(
        animalCount,
        0L, // Pending appointments placeholder
        0L, // Active alerts placeholder
        userName,
        facilityName,
        user.getRole().name()
    );
  }
}
