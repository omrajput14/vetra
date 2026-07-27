# ─────────────────────────────────────────────────────────────────────
# Vetra Backend — Multi-stage Dockerfile
# Stage 1: Build using Maven Wrapper
# Stage 2: Runtime using OpenJDK 21 slim
# ─────────────────────────────────────────────────────────────────────

# ── Stage 1: Build ──────────────────────────────────────────────────
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /workspace

# Cache Maven dependencies layer separately for faster rebuilds
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline -q

# Copy source and build
COPY src/ src/
RUN ./mvnw clean package -DskipTests -q

# Extract Spring Boot layered jar
RUN java -Djarmode=layertools -jar target/*.jar extract --destination extracted

# ── Stage 2: Runtime ────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime

# Non-root security: create dedicated user
RUN addgroup -S vetra && adduser -S vetra -G vetra

WORKDIR /app

# Copy layered jar slices (ordered for optimal layer caching)
COPY --from=builder /workspace/extracted/dependencies/ ./
COPY --from=builder /workspace/extracted/spring-boot-loader/ ./
COPY --from=builder /workspace/extracted/snapshot-dependencies/ ./
COPY --from=builder /workspace/extracted/application/ ./

# Create log directory with correct permissions
RUN mkdir -p logs && chown -R vetra:vetra /app

USER vetra

# Expose application port
EXPOSE 8080

# JVM tuning for containerised environments
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:+UseG1GC \
               -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
