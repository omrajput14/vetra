package app.vetra.infrastructure.logging;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Request ID filter.
 *
 * <p>Generates a unique {@code requestId} for every inbound HTTP request and stores it in the SLF4J
 * MDC (Mapped Diagnostic Context). This enables correlation of all log statements within a single
 * request across classes.
 *
 * <p>The {@code requestId} is also written to the response header {@code X-Request-Id} so clients
 * can correlate their own logs with server logs.
 */
@Component
@Order(1)
public class RequestIdFilter extends OncePerRequestFilter {

  /** MDC key used in the logging pattern. */
  public static final String MDC_REQUEST_ID = "requestId";

  /** HTTP response header exposing the request ID to the client. */
  public static final String HEADER_REQUEST_ID = "X-Request-Id";

  @Override
  protected void doFilterInternal(
      @NonNull HttpServletRequest request,
      @NonNull HttpServletResponse response,
      @NonNull FilterChain filterChain)
      throws ServletException, IOException {

    // Honour forwarded requestId from upstream gateway, or generate one
    String requestId = request.getHeader(HEADER_REQUEST_ID);
    if (requestId == null || requestId.isBlank()) {
      requestId = UUID.randomUUID().toString();
    }

    MDC.put(MDC_REQUEST_ID, requestId);
    response.setHeader(HEADER_REQUEST_ID, requestId);

    try {
      filterChain.doFilter(request, response);
    } finally {
      MDC.remove(MDC_REQUEST_ID);
    }
  }
}
