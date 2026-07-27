package app.vetra.infrastructure.config;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/**
 * CORS configuration properties.
 *
 * <p>Bound from {@code vetra.cors.*} in application.yml.
 */
@Validated
@ConfigurationProperties(prefix = "vetra.cors")
public record CorsProperties(
    @NotEmpty List<String> allowedOrigins,
    @NotBlank String allowedMethods,
    @NotBlank String allowedHeaders,
    boolean allowCredentials,
    long maxAge) {}
