package app.vetra.infrastructure.persistence.entity;

import app.vetra.infrastructure.persistence.enums.AnimalGender;
import app.vetra.infrastructure.persistence.enums.Species;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Livestock animal entity owned by a farmer.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "animals")
public class Animal extends BaseEntity {

  @NotNull
  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "farmer_id", nullable = false)
  private FarmerProfile farmer;

  @NotNull
  @Column(name = "tag_number", nullable = false)
  private String tagNumber;

  @Column(name = "qr_code_id", unique = true)
  private String qrCodeId;

  @NotNull
  @Enumerated(EnumType.STRING)
  @Column(name = "species", nullable = false, length = 30)
  private Species species;

  @Column(name = "breed")
  private String breed;

  @NotNull
  @Enumerated(EnumType.STRING)
  @Column(name = "gender", nullable = false, length = 20)
  private AnimalGender gender;

  @Column(name = "birth_date")
  private LocalDate birthDate;

  @Column(name = "photo_url")
  private String photoUrl;
}
