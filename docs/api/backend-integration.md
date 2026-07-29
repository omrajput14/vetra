# Vetra Application — Completed Work & Backend Integration Specification

## 1. Executive Summary & Technology Stack

Vetra is a dual-role agricultural & veterinary healthcare platform. Every screen of the HTML prototypes has been converted into native, production-grade Flutter Material 3 UI adhering to Clean Architecture principles.

### Tech Stack Overview:
- **Mobile Frontend**: Flutter 3.x (Material 3, Riverpod 2.x, GoRouter 13.x, Google Fonts, Null Safety)
- **Target Backend Framework**: Spring Boot 3.x (Java 21) + PostgreSQL / PostGIS
- **State Management & Routing**: `AuthNotifier` + `GoRouter` with Strict Role-Based Navigation Guards
- **Active Branch**: `feature/flutter-native-ui`

---

## 2. Authentication & Dual-Role Session Architecture

The application enforces complete separation between **Farmer** and **Veterinarian** user experiences post-login.

```
                             Splash Screen (/splash)
                                       │
                         Session Restoration Check
                                       │
                  ┌────────────────────┴────────────────────┐
                  ▼                                         ▼
         No Session Active                           Session Active
                  │                                         │
                  ▼                                         ▼
            Welcome Screen                           Check User Role
              (/welcome)                                    │
       ┌──────────┴──────────┐               ┌──────────────┴──────────────┐
       ▼                     ▼               ▼                             ▼
Continue as Farmer    Continue as Vet     FARMER                      VETERINARIAN
       │                     │               │                             │
       ▼                     ▼               ▼                             ▼
 Farmer Login           Vet Login     Farmer Dashboard               Vet Dashboard
(/farmer-login)       (/vet-login)   (/farmer-dashboard)            (/vet-dashboard)
```

---

## 3. Backend API Contract Mapping (Spring Boot Integration)

Every completed Flutter screen is prepared to connect directly to REST endpoints.

### A. Authentication & User Profile Management

| Endpoint | HTTP Method | Auth Required | Request DTO | Response DTO | Mobile Screen |
|---|---|---|---|---|---|
| `/api/v1/auth/farmer/login` | `POST` | None | `FarmerLoginRequestDto` | `AuthTokenResponseDto` | `FarmerLoginPage` |
| `/api/v1/auth/farmer/register` | `POST` | None | `FarmerRegisterRequestDto` | `AuthTokenResponseDto` | `FarmerRegisterPage` |
| `/api/v1/auth/vet/login` | `POST` | None | `VetLoginRequestDto` | `AuthTokenResponseDto` | `VetLoginPage` |
| `/api/v1/auth/vet/register` | `POST` | None | `VetRegisterRequestDto` | `AuthTokenResponseDto` | `VetRegisterPage` |
| `/api/v1/auth/me` | `GET` | `Bearer JWT` | None | `UserProfileResponseDto` | `ProfilePage` / `VetProfilePage` |
| `/api/v1/auth/verify-email` | `POST` | `Bearer JWT` | `EmailVerificationDto` | `ApiResponseDto` | `EmailVerificationPage` |
| `/api/v1/vet/profile/availability` | `PUT` | `Bearer VET` | `UpdateAvailabilityDto` | `VetProfileDto` | `VetProfilePage` |

### B. Herd & Animal Management (Farmer Role)

| Endpoint | HTTP Method | Auth Required | Request DTO | Response DTO | Mobile Screen |
|---|---|---|---|---|---|
| `/api/v1/animals` | `GET` | `Bearer FARMER` | Query Params (page, filter) | `List<AnimalSummaryDto>` | `MyAnimalsPage` |
| `/api/v1/animals` | `POST` | `Bearer FARMER` | `CreateAnimalRequestDto` | `AnimalDetailsDto` | `AddAnimalPage` |
| `/api/v1/animals/{id}` | `GET` | `Bearer FARMER/VET` | None | `AnimalDetailsDto` | `AnimalPassportPage` |
| `/api/v1/animals/{id}` | `PUT` | `Bearer FARMER` | `UpdateAnimalRequestDto` | `AnimalDetailsDto` | `EditAnimalPage` |
| `/api/v1/animals/{id}/timeline` | `GET` | `Bearer FARMER/VET` | None | `List<TimelineEventDto>` | `AnimalTimelinePage` |
| `/api/v1/animals/transfer` | `POST` | `Bearer FARMER` | `TransferOwnershipDto` | `ApiResponseDto` | `TransferAnimalOwnershipPage` |

### C. AI Disease Detection & Outbreak Workflow

> **Safety Rule Enforced**: AI predictions never trigger public outbreak alerts directly. AI scans require explicit Farmer submission, followed by official Veterinarian confirmation before spatial outbreak alerts are broadcast.

```
Farmer AI Scan ──> AI Prediction Result ──> Farmer Submits Report ──> Vet Reviews Case ──> Vet Confirms ──> Spatial Outbreak Alert Broadcast
```

| Endpoint | HTTP Method | Auth Required | Request DTO | Response DTO | Mobile Screen |
|---|---|---|---|---|---|
| `/api/v1/ai/scan` | `POST` | `Bearer FARMER` | Multipart Image Upload | `AiScanPredictionDto` | `DiseaseScannerPage` / `AnalyzingScanPage` |
| `/api/v1/disease/reports` | `POST` | `Bearer FARMER` | `SubmitDiseaseReportDto` | `DiseaseReportStatusDto` | `ReportDiseasePage` |
| `/api/v1/vet/reports/pending` | `GET` | `Bearer VET` | Query Params (radiusKm) | `List<PendingReportDto>` | `VetDashboardPage` / `VetRequestsPage` |
| `/api/v1/vet/reports/{id}/verify` | `POST` | `Bearer VET` | `VerifyDiseaseReportDto` | `OutbreakAlertStatusDto` | `DiagnosisEntryPage` |
| `/api/v1/gis/outbreaks` | `GET` | `Bearer FARMER/VET` | `lat, lng, radiusKm` | `GeoJsonOutbreakCollection` | `OutbreakMapPage` / `VetOutbreakMapPage` |

### D. Veterinarian Consultations & Clinical Operations

| Endpoint | HTTP Method | Auth Required | Request DTO | Response DTO | Mobile Screen |
|---|---|---|---|---|---|
| `/api/v1/vet/dashboard` | `GET` | `Bearer VET` | None | `VetDashboardSummaryDto` | `VetDashboardPage` |
| `/api/v1/vet/requests` | `GET` | `Bearer VET` | Query Params (status) | `List<ConsultationRequestDto>` | `VetRequestsPage` |
| `/api/v1/vet/prescriptions` | `POST` | `Bearer VET` | `CreatePrescriptionDto` | `PrescriptionDetailsDto` | `AddPrescriptionPage` |
| `/api/v1/vet/history` | `GET` | `Bearer VET` | Query Params (dateRange) | `List<ConsultationCaseDto>` | `ConsultationHistoryPage` |

---

## 4. Required Database Entities (Spring Boot JPA Schema)

To implement the backend services, the database should include the following core entities:

1. **`users`**: `id`, `email_or_phone`, `password_hash`, `role` (`FARMER`, `VETERINARIAN`, `ADMINISTRATOR`), `created_at`.
2. **`farmer_profiles`**: `id`, `user_id`, `full_name`, `farm_name`, `village`, `district`, `state`, `animal_count`.
3. **`vet_profiles`**: `id`, `user_id`, `full_name`, `reg_no`, `qualification`, `specialization`, `clinic_name`, `experience_years`, `is_available`.
4. **`animals`**: `id`, `farmer_id`, `tag_number`, `species`, `breed`, `dob`, `gender`, `photo_url`, `qr_code_id`.
5. **`medical_records`**: `id`, `animal_id`, `vet_id`, `record_type`, `diagnosis`, `treatment`, `prescription_text`, `date`.
6. **`ai_scans`**: `id`, `farmer_id`, `image_url`, `ai_prediction`, `confidence_score`, `status`, `created_at`.
7. **`disease_reports`**: `id`, `scan_id`, `farmer_id`, `vet_id`, `status` (`PENDING_REVIEW`, `VERIFIED`, `REJECTED`), `location` (`Geometry Point`), `created_at`.
8. **`outbreaks`**: `id`, `disease_name`, `center_location` (`Geometry Point`), `radius_km`, `status`, `declared_by_vet_id`, `created_at`.

---

## 5. Summary of Completed Native Flutter Work

- **Total Screens Implemented**: **64 Native Screens**
- **Authentication**: Fully separated Farmer & Vet sign-in/registration with session persistence and role guards.
- **Farmer Module**: 100% complete (Dashboard, Herd, Animal Passport, AI Scan, Nearby Vets, Outbreak Alerts, Profiles, Settings).
- **Veterinarian Module**: 100% complete (Vet Dashboard, Incoming Triage Requests, Case History, Dedicated Vet Outbreak Map with GIS Layer, Vet Profile with Duty Status Switch).
- **Design System**: Standardized on Material 3 (`AppColors`, `AppTypography`, reusable cards, tiles, and navigation bars).
- **Quality Verification**:
  - `flutter analyze`: **0 issues found**
  - `flutter test`: **All unit/widget tests passing**
  - `git push`: Remote origin updated on `origin/feature/flutter-native-ui`.
