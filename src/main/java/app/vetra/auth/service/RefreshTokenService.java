package app.vetra.auth.service;

import app.vetra.auth.repository.RefreshTokenRepository;
import app.vetra.infrastructure.config.JwtProperties;
import app.vetra.infrastructure.persistence.entity.RefreshToken;
import app.vetra.infrastructure.persistence.entity.User;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service managing database-backed refresh tokens.
 */
@Service
public class RefreshTokenService {

  private final RefreshTokenRepository refreshTokenRepository;
  private final JwtProperties jwtProperties;

  /** Constructor injection. */
  public RefreshTokenService(
      RefreshTokenRepository refreshTokenRepository, JwtProperties jwtProperties) {
    this.refreshTokenRepository = refreshTokenRepository;
    this.jwtProperties = jwtProperties;
  }

  /** Creates and persists a new refresh token for user. */
  @Transactional
  public RefreshToken createRefreshToken(User user) {
    refreshTokenRepository.deleteByUser(user);

    RefreshToken refreshToken = RefreshToken.builder()
        .user(user)
        .token(UUID.randomUUID().toString())
        .expiryDate(Instant.now().plusMillis(jwtProperties.refreshExpirationMs()))
        .revoked(false)
        .build();

    return refreshTokenRepository.save(refreshToken);
  }

  /** Finds refresh token by string. */
  @Transactional(readOnly = true)
  public Optional<RefreshToken> findByToken(String token) {
    return refreshTokenRepository.findByToken(token);
  }

  /** Verifies token expiration and revocation. */
  @Transactional
  public RefreshToken verifyExpiration(RefreshToken token) {
    if (token.getExpiryDate().isBefore(Instant.now()) || token.isRevoked()) {
      refreshTokenRepository.delete(token);
      throw new IllegalArgumentException("Refresh token has expired or been revoked");
    }
    return token;
  }

  /** Revokes token string. */
  @Transactional
  public void revokeToken(String token) {
    refreshTokenRepository.findByToken(token).ifPresent(t -> {
      t.setRevoked(true);
      refreshTokenRepository.save(t);
    });
  }
}
