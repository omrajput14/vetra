package app.vetra.animal.service;

import app.vetra.animal.dto.AnimalResponse;
import app.vetra.animal.dto.CreateAnimalRequest;
import app.vetra.animal.dto.UpdateAnimalRequest;
import app.vetra.animal.repository.AnimalRepository;
import app.vetra.auth.repository.FarmerProfileRepository;
import app.vetra.auth.repository.UserRepository;
import app.vetra.infrastructure.persistence.entity.Animal;
import app.vetra.infrastructure.persistence.entity.FarmerProfile;
import app.vetra.infrastructure.persistence.entity.User;
import app.vetra.infrastructure.persistence.enums.AnimalGender;
import app.vetra.infrastructure.persistence.enums.Species;
import app.vetra.infrastructure.persistence.enums.UserRole;
import java.util.List;
import java.util.UUID;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Business service for managing livestock animals with strict role authorization.
 */
@Service
public class AnimalService {

  private final AnimalRepository animalRepository;
  private final UserRepository userRepository;
  private final FarmerProfileRepository farmerProfileRepository;

  /** Constructor injection. */
  public AnimalService(
      AnimalRepository animalRepository,
      UserRepository userRepository,
      FarmerProfileRepository farmerProfileRepository) {
    this.animalRepository = animalRepository;
    this.userRepository = userRepository;
    this.farmerProfileRepository = farmerProfileRepository;
  }

  /** Creates a new animal record for the authenticated farmer. */
  @Transactional
  public AnimalResponse createAnimal(String currentUserIdentifier, CreateAnimalRequest request) {
    User user = getUserByHeader(currentUserIdentifier);
    if (user.getRole() != UserRole.FARMER) {
      throw new AccessDeniedException("Only farmers can register animals");
    }

    FarmerProfile farmer = farmerProfileRepository.findByUser(user)
        .orElseThrow(() -> new IllegalStateException("Farmer profile not found"));

    if (animalRepository.existsByTagNumber(request.tagNumber())) {
      throw new IllegalArgumentException("Tag number is already registered: " + request.tagNumber());
    }
    if (request.qrCodeId() != null && !request.qrCodeId().isBlank()
        && animalRepository.existsByQrCodeId(request.qrCodeId())) {
      throw new IllegalArgumentException("QR Code ID is already registered: " + request.qrCodeId());
    }

    Animal animal = Animal.builder()
        .farmer(farmer)
        .tagNumber(request.tagNumber())
        .qrCodeId(request.qrCodeId())
        .species(request.species())
        .breed(request.breed())
        .gender(request.gender())
        .birthDate(request.birthDate())
        .photoUrl(request.photoUrl())
        .build();

    animal = animalRepository.save(animal);
    return mapToResponse(animal);
  }

  /** Retrieves an animal by ID with ownership verification. */
  @Transactional(readOnly = true)
  public AnimalResponse getAnimalById(String currentUserIdentifier, UUID animalId) {
    User user = getUserByHeader(currentUserIdentifier);
    Animal animal = animalRepository.findById(animalId)
        .orElseThrow(() -> new IllegalArgumentException("Animal not found with ID: " + animalId));

    if (user.getRole() == UserRole.FARMER) {
      verifyFarmerOwnership(user, animal);
    }

    return mapToResponse(animal);
  }

  /** Lists animals based on user role (Farmers see their own animals, Vets/Admins see all). */
  @Transactional(readOnly = true)
  public List<AnimalResponse> listAnimals(String currentUserIdentifier) {
    User user = getUserByHeader(currentUserIdentifier);

    if (user.getRole() == UserRole.FARMER) {
      FarmerProfile farmer = farmerProfileRepository.findByUser(user)
          .orElseThrow(() -> new IllegalStateException("Farmer profile not found"));
      return animalRepository.findByFarmer(farmer).stream().map(this::mapToResponse).toList();
    }

    return animalRepository.findAll().stream().map(this::mapToResponse).toList();
  }

  /** Searches animals with optional filters. */
  @Transactional(readOnly = true)
  public List<AnimalResponse> searchAnimals(
      String currentUserIdentifier,
      String tagNumber,
      String qrCodeId,
      Species species,
      String breed,
      AnimalGender gender) {

    User user = getUserByHeader(currentUserIdentifier);
    UUID farmerId = null;

    if (user.getRole() == UserRole.FARMER) {
      FarmerProfile farmer = farmerProfileRepository.findByUser(user)
          .orElseThrow(() -> new IllegalStateException("Farmer profile not found"));
      farmerId = farmer.getId();
    }

    return animalRepository.searchAnimals(farmerId, tagNumber, qrCodeId, species, breed, gender)
        .stream()
        .map(this::mapToResponse)
        .toList();
  }

  /** Updates an existing animal record. */
  @Transactional
  public AnimalResponse updateAnimal(String currentUserIdentifier, UUID animalId, UpdateAnimalRequest request) {
    User user = getUserByHeader(currentUserIdentifier);
    Animal animal = animalRepository.findById(animalId)
        .orElseThrow(() -> new IllegalArgumentException("Animal not found with ID: " + animalId));

    if (user.getRole() == UserRole.FARMER) {
      verifyFarmerOwnership(user, animal);
    }

    if (!animal.getTagNumber().equalsIgnoreCase(request.tagNumber())
        && animalRepository.existsByTagNumber(request.tagNumber())) {
      throw new IllegalArgumentException("Tag number is already registered: " + request.tagNumber());
    }

    if (request.qrCodeId() != null && !request.qrCodeId().equalsIgnoreCase(animal.getQrCodeId())
        && animalRepository.existsByQrCodeId(request.qrCodeId())) {
      throw new IllegalArgumentException("QR Code ID is already registered: " + request.qrCodeId());
    }

    animal.setTagNumber(request.tagNumber());
    animal.setQrCodeId(request.qrCodeId());
    animal.setSpecies(request.species());
    animal.setBreed(request.breed());
    animal.setGender(request.gender());
    animal.setBirthDate(request.birthDate());
    animal.setPhotoUrl(request.photoUrl());

    animal = animalRepository.save(animal);
    return mapToResponse(animal);
  }

  /** Deletes an animal by ID. */
  @Transactional
  public void deleteAnimal(String currentUserIdentifier, UUID animalId) {
    User user = getUserByHeader(currentUserIdentifier);
    Animal animal = animalRepository.findById(animalId)
        .orElseThrow(() -> new IllegalArgumentException("Animal not found with ID: " + animalId));

    if (user.getRole() == UserRole.FARMER) {
      verifyFarmerOwnership(user, animal);
    }

    animalRepository.delete(animal);
  }

  private User getUserByHeader(String identifier) {
    return userRepository.findByIdentifier(identifier)
        .orElseThrow(() -> new IllegalArgumentException("User not found"));
  }

  private void verifyFarmerOwnership(User user, Animal animal) {
    FarmerProfile farmer = farmerProfileRepository.findByUser(user)
        .orElseThrow(() -> new IllegalStateException("Farmer profile not found"));
    if (!animal.getFarmer().getId().equals(farmer.getId())) {
      throw new AccessDeniedException("Access denied: You do not own this animal record");
    }
  }

  private AnimalResponse mapToResponse(Animal a) {
    return new AnimalResponse(
        a.getId(),
        a.getFarmer().getId(),
        a.getFarmer().getFullName(),
        a.getTagNumber(),
        a.getQrCodeId(),
        a.getSpecies(),
        a.getBreed(),
        a.getGender(),
        a.getBirthDate(),
        a.getPhotoUrl(),
        a.getCreatedAt(),
        a.getUpdatedAt()
    );
  }
}
