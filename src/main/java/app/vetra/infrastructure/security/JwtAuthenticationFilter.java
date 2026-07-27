package app.vetra.infrastructure.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * JWT authentication filter — placeholder.
 *
 * <p>This filter is registered in the Spring Security filter chain. In the current infrastructure
 * stage it passes all requests through without authentication validation.
 *
 * <p>Full implementation (token extraction, validation, SecurityContext population) will be added
 * in the {@code auth} feature stage.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  private static final Logger log = LoggerFactory.getLogger(JwtAuthenticationFilter.class);
  private static final String AUTHORIZATION_HEADER = "Authorization";
  private static final String BEARER_PREFIX = "Bearer ";

  /**
   * Extracts the Bearer token from the Authorization header and delegates to validation. Currently
   * a no-op placeholder.
   *
   * @param request incoming HTTP request
   * @param response HTTP response
   * @param filterChain remaining filter chain
   */
  @Override
  protected void doFilterInternal(
      @NonNull HttpServletRequest request,
      @NonNull HttpServletResponse response,
      @NonNull FilterChain filterChain)
      throws ServletException, IOException {

    String authHeader = request.getHeader(AUTHORIZATION_HEADER);

    if (authHeader != null && authHeader.startsWith(BEARER_PREFIX)) {
      // Token extracted — validation and SecurityContext population
      // will be implemented in the auth feature stage.
      String token = authHeader.substring(BEARER_PREFIX.length());
      log.trace("JWT token present on request to {}, length={}", request.getRequestURI(),
          token.length());
    }

    filterChain.doFilter(request, response);
  }
}
