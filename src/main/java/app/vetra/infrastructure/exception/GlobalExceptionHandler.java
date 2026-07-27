package app.vetra.infrastructure.exception;

import app.vetra.infrastructure.response.ApiResponse;
import app.vetra.infrastructure.response.ApiResponse.FieldError;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.NoHandlerFoundException;

/**
 * Global exception handler.
 *
 * <p>Intercepts all exceptions thrown from any {@code @RestController} in the application and
 * converts them to the standard {@link ApiResponse} envelope. This ensures the client always
 * receives a consistent error structure regardless of what went wrong internally.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

  private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

  // ─── Validation ──────────────────────────────────────────────────────

  /**
   * Handles {@link MethodArgumentNotValidException} raised by {@code @Valid} on request bodies.
   * Returns 400 Bad Request with per-field error details.
   */
  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ApiResponse<Void>> handleValidation(
      MethodArgumentNotValidException ex, HttpServletRequest request) {

    BindingResult binding = ex.getBindingResult();
    List<FieldError> fieldErrors =
        binding.getFieldErrors().stream()
            .map(fe -> new FieldError(fe.getField(), fe.getDefaultMessage()))
            .toList();

    log.warn("Validation failed on {} {}: {} error(s)",
        request.getMethod(), request.getRequestURI(), fieldErrors.size());

    return ResponseEntity.badRequest()
        .body(ApiResponse.error(HttpStatus.BAD_REQUEST, "Request validation failed", fieldErrors));
  }

  // ─── Message Not Readable ────────────────────────────────────────────

  /**
   * Handles malformed or unparseable JSON request bodies.
   * Returns 400 Bad Request.
   */
  @ExceptionHandler(HttpMessageNotReadableException.class)
  public ResponseEntity<ApiResponse<Void>> handleMessageNotReadable(
      HttpMessageNotReadableException ex, HttpServletRequest request) {

    log.warn("Unreadable request body on {} {}: {}", request.getMethod(),
        request.getRequestURI(), ex.getMessage());

    return ResponseEntity.badRequest()
        .body(ApiResponse.error(HttpStatus.BAD_REQUEST, "Request body is missing or malformed"));
  }

  // ─── 404 Not Found ───────────────────────────────────────────────────

  /**
   * Handles requests to routes that do not exist.
   * Returns 404 Not Found.
   */
  @ExceptionHandler(NoHandlerFoundException.class)
  public ResponseEntity<ApiResponse<Void>> handleNotFound(
      NoHandlerFoundException ex, HttpServletRequest request) {

    log.info("Route not found: {} {}", request.getMethod(), request.getRequestURI());

    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(ApiResponse.error(HttpStatus.NOT_FOUND,
            "Route " + request.getMethod() + " " + request.getRequestURI() + " not found"));
  }

  // ─── Security ────────────────────────────────────────────────────────

  /**
   * Handles Spring Security authentication failures (missing or invalid token).
   * Returns 401 Unauthorized.
   */
  @ExceptionHandler(AuthenticationException.class)
  public ResponseEntity<ApiResponse<Void>> handleAuthenticationException(
      AuthenticationException ex, HttpServletRequest request) {

    log.warn("Authentication failure on {} {}: {}", request.getMethod(),
        request.getRequestURI(), ex.getMessage());

    return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
        .body(ApiResponse.error(HttpStatus.UNAUTHORIZED, "Authentication required"));
  }

  /**
   * Handles Spring Security authorization failures (authenticated but insufficient role).
   * Returns 403 Forbidden.
   */
  @ExceptionHandler(AccessDeniedException.class)
  public ResponseEntity<ApiResponse<Void>> handleAccessDenied(
      AccessDeniedException ex, HttpServletRequest request) {

    log.warn("Access denied on {} {} for principal: {}", request.getMethod(),
        request.getRequestURI(), ex.getMessage());

    return ResponseEntity.status(HttpStatus.FORBIDDEN)
        .body(ApiResponse.error(HttpStatus.FORBIDDEN, "Access denied"));
  }

  // ─── Catch-All ───────────────────────────────────────────────────────

  /**
   * Final catch-all for any unhandled {@link RuntimeException}.
   * Returns 500 Internal Server Error. The actual error is logged but NOT exposed to the client.
   */
  @ExceptionHandler(RuntimeException.class)
  public ResponseEntity<ApiResponse<Void>> handleRuntimeException(
      RuntimeException ex, HttpServletRequest request) {

    log.error("Unhandled RuntimeException on {} {}", request.getMethod(),
        request.getRequestURI(), ex);

    return ResponseEntity.internalServerError()
        .body(ApiResponse.error(HttpStatus.INTERNAL_SERVER_ERROR,
            "An unexpected error occurred. Please try again."));
  }

  /**
   * Final catch-all for any {@link Exception} not caught above.
   * Returns 500 Internal Server Error.
   */
  @ExceptionHandler(Exception.class)
  public ResponseEntity<ApiResponse<Void>> handleException(
      Exception ex, HttpServletRequest request) {

    log.error("Unhandled Exception on {} {}", request.getMethod(),
        request.getRequestURI(), ex);

    return ResponseEntity.internalServerError()
        .body(ApiResponse.error(HttpStatus.INTERNAL_SERVER_ERROR,
            "An unexpected error occurred. Please try again."));
  }
}
