package app.vetra.infrastructure.security;

import app.vetra.infrastructure.config.JwtProperties;
import java.util.Date;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * JWT utility — configuration placeholder.
 *
 * <p>This class holds the JWT configuration binding and exposes stub methods for token operations.
 * All method bodies will be implemented in the {@code auth} feature stage.
 *
 * <p><strong>Do not implement token logic here.</strong>
 */
@Component
public class JwtUtil {

  private static final Logger log = LoggerFactory.getLogger(JwtUtil.class);

  private final JwtProperties jwtProperties;

  /** Constructor injection. */
  public JwtUtil(JwtProperties jwtProperties) {
    this.jwtProperties = jwtProperties;
  }

  /**
   * Generates an access token for the given subject.
   *
   * @param subject user identifier (to be implemented in auth stage)
   * @param role user role string
   * @return signed JWT string
   * @throws UnsupportedOperationException until auth stage is implemented
   */
  public String generateAccessToken(String subject, String role) {
    log.debug("generateAccessToken called for subject={}", subject);
    throw new UnsupportedOperationException(
        "JWT generation not implemented in infrastructure stage");
  }

  /**
   * Generates a refresh token.
   *
   * @param subject user identifier
   * @return signed refresh JWT
   * @throws UnsupportedOperationException until auth stage is implemented
   */
  public String generateRefreshToken(String subject) {
    log.debug("generateRefreshToken called for subject={}", subject);
    throw new UnsupportedOperationException(
        "JWT refresh generation not implemented in infrastructure stage");
  }

  /**
   * Validates a JWT token.
   *
   * @param token the JWT string to validate
   * @return {@code true} if valid, {@code false} otherwise
   * @throws UnsupportedOperationException until auth stage is implemented
   */
  public boolean isTokenValid(String token) {
    throw new UnsupportedOperationException(
        "JWT validation not implemented in infrastructure stage");
  }

  /**
   * Extracts the subject (user ID or email) from a token.
   *
   * @param token the JWT string
   * @return subject claim value
   * @throws UnsupportedOperationException until auth stage is implemented
   */
  public String extractSubject(String token) {
    throw new UnsupportedOperationException(
        "JWT subject extraction not implemented in infrastructure stage");
  }

  /**
   * Extracts the expiration date from a token.
   *
   * @param token the JWT string
   * @return expiration {@link Date}
   * @throws UnsupportedOperationException until auth stage is implemented
   */
  public Date extractExpiration(String token) {
    throw new UnsupportedOperationException(
        "JWT expiration extraction not implemented in infrastructure stage");
  }

  /**
   * Returns configured access token validity in milliseconds.
   *
   * @return expiration duration in ms
   */
  public long getExpirationMs() {
    return jwtProperties.expirationMs();
  }
}
