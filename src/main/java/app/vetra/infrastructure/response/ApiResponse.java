package app.vetra.infrastructure.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.Instant;
import java.util.List;
import org.springframework.http.HttpStatus;

/**
 * Standard API response envelope.
 *
 * <p>All Vetra REST endpoints return this wrapper to ensure a consistent response contract across
 * every route, regardless of the feature module.
 *
 * <p>Example success:
 *
 * <pre>{@code
 * ApiResponse.ok("Login successful", tokenDto)
 * }</pre>
 *
 * Example error:
 *
 * <pre>{@code
 * ApiResponse.error(HttpStatus.BAD_REQUEST, "Validation failed", fieldErrors)
 * }</pre>
 *
 * @param <T> payload data type
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
    boolean success,
    int status,
    String message,
    T data,
    List<FieldError> errors,
    Instant timestamp) {

  /** Represents a single field-level validation error. */
  public record FieldError(String field, String message) {}

  // ─── Factories ───────────────────────────────────────────────────────

  /**
   * Creates a 200 OK success response with data payload.
   *
   * @param message human-readable success message
   * @param data response payload
   * @return success {@link ApiResponse}
   */
  public static <T> ApiResponse<T> ok(String message, T data) {
    return new ApiResponse<>(true, HttpStatus.OK.value(), message, data, null, Instant.now());
  }

  /**
   * Creates a 201 Created success response with data payload.
   *
   * @param message human-readable success message
   * @param data created resource
   * @return created {@link ApiResponse}
   */
  public static <T> ApiResponse<T> created(String message, T data) {
    return new ApiResponse<>(true, HttpStatus.CREATED.value(), message, data, null, Instant.now());
  }

  /**
   * Creates an error response with no data.
   *
   * @param status HTTP status
   * @param message error description
   * @param errors list of field-level errors (may be null)
   * @return error {@link ApiResponse}
   */
  public static <T> ApiResponse<T> error(
      HttpStatus status, String message, List<FieldError> errors) {
    return new ApiResponse<>(false, status.value(), message, null, errors, Instant.now());
  }

  /**
   * Creates a simple error response without field errors.
   *
   * @param status HTTP status
   * @param message error description
   * @return error {@link ApiResponse}
   */
  public static <T> ApiResponse<T> error(HttpStatus status, String message) {
    return error(status, message, null);
  }
}
