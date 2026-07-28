# Changelog

All notable changes to the Vetra Flutter application will be documented here.

## [Unreleased]

## [0.7.0] — 2026-07-28 — Stage 7: Electronic Veterinary Medical Records (EVMR)
### Added
- `MedicalRecordModel`, `MedicalRecordApiService`, `MedicalRecordRepository`
- `CreateMedicalRecordPage` — Veterinarian clinical record creation form
- `MedicalRecordDetailsPage` — Full read-only EVMR document viewer
- `AnimalMedicalHistoryWidget` — Medical history timeline on Animal Passport
- `AppointmentDetailsPage` — Conditional "Create Medical Record" / "View Medical Record" action
- `medicalRecordProvider` Riverpod state provider
- `flutter analyze` — 0 warnings, 0 errors

## [0.6.0] — 2026-07-27 — Stage 6: Appointment Management
### Added
- `AppointmentApiService`, `AppointmentRepository`, `AppointmentProvider`
- `AppointmentBookingPage` — Farmer appointment booking flow
- `AppointmentDetailsPage` — Appointment status and actions
- `FarmerAppointmentsPage` — Appointment list view
- Booking entry points wired from Nearby Vets and Farmer Dashboard

## [0.5.0] — 2026-07-27 — Stage 5: Animal Management
### Added
- `AnimalApiService`, `AnimalRepository`, `AnimalProvider`
- Animal list, animal passport, animal creation pages
- `AnimalMedicalHistoryWidget`

## [0.4.0] — 2026-07-26 — Stage 4: Auth & Backend Integration
### Added
- `AuthApiService`, `AuthRepository`, JWT token management
- `SecureStorageService` — token persistence
- Live profile updates via `PUT /api/v1/auth/profile`
- Mock data fully removed — all data from live API

## [0.1.0–0.3.0] — Stages 1–3: Native Flutter UI
### Added
- 64 HTML prototypes migrated to native Flutter screens
- Dual-role authentication (Farmer / Veterinarian) with GoRouter guards
- Clean Architecture feature structure: `data/`, `domain/`, `presentation/`
- Material 3 design system with custom tokens, typography, colors
- `flutter analyze` — 0 issues
