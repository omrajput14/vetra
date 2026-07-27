package app.vetra.auth.repository;

import app.vetra.infrastructure.persistence.entity.RefreshToken;
import app.vetra.infrastructure.persistence.entity.User;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;

/**
 * Data access repository for RefreshToken entity.
 */
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

  /** Finds refresh token by token string. */
  Optional<RefreshToken> findByToken(String token);

  /** Deletes refresh tokens for user. */
  @Modifying
  void deleteByUser(User user);
}
