# Project Roadmap
**Document ID:** ROADMAP-19  
**Status:** Active  
**Last Updated:** 2026-07-29  
**Applies To:** Vetra Ecosystem (`omrajput14/vetra` & `omrajput14/vetra-backend`)  
**References:** [PRD](../product/01-PRD.md), [Decision Log](../../vetra-backend/docs/domain/21-decision-log.md)

---

## Stage Progression Overview

```
Stages 1–3: Core Foundation & Auth (COMPLETED)
       │
       ▼
Stage 4: Animal Management & Digital Passport (COMPLETED)
       │
       ▼
Stage 5–6: Appointment Management & State Machine (COMPLETED)
       │
       ▼
Stage 7: Electronic Veterinary Medical Records - EVMR (COMPLETED)
       │
       ▼
Stage 8: Repository Cleanup & Professional Documentation (CURRENT - IN PROGRESS)
       │
       ▼
Stage 9: AI Disease Scanner & Image Inference (PLANNED)
       │
       ▼
Stage 10: Spatial Outbreak Mapping & PostGIS Alert System (PLANNED)
       │
       ▼
Stage 11: Production Infrastructure & CI/CD Deployment (PLANNED)
```

---

## Detailed Stage Breakdown

### Completed Stages

#### Stage 1–3: Core Architecture, Auth & User Profiles
- **Backend:** Spring Boot 3 setup, Flyway migrations V1–V3, `users`, `farmer_profiles`, `vet_profiles`, JWT + refresh token security filter.
- **Flutter:** Clean architecture setup, Riverpod state management, GoRouter route guards, login & dual-role registration screens.

#### Stage 4: Animal Management & QR Animal Passport
- **Backend:** Flyway migration V4, `animals` schema, animal CRUD endpoints, unique `qr_code_id`.
- **Flutter:** My Animals screen, Add Animal wizard, QR code generator & camera scanner UI, Animal Passport detail view.

#### Stage 5–6: Appointment Booking & Clinical State Machine
- **Backend:** Flyway migration V5, `appointments` schema with optimistic locking (`version`), state machine transition API (`PENDING` → `CONFIRMED` → `COMPLETED` / `CANCELLED`).
- **Flutter:** Nearby Vets directory, Book Appointment form, Appointment status cards, Vet dashboard request confirmation flow.

#### Stage 7: Electronic Veterinary Medical Record (EVMR) Module
- **Backend:** Flyway migration V6, `medical_records` schema, immutable record creation constraint, animal clinical history endpoint.
- **Flutter:** EVMR creation form for veterinarians, EVMR details view, chronological clinical timeline on Animal Passport.

---

### In-Progress & Planned Stages

#### Stage 8: Repository Standardization & Engineering Documentation (Current Stage)
- **Repo Organization:** Separated into two independent GitHub repositories (`omrajput14/vetra` and `omrajput14/vetra-backend`). Performed `git-filter-repo` history cleanup on Flutter repo to reduce `.git` from 472 MB to 26 MB.
- **Documentation:** Created 25 comprehensive engineering documents covering architecture, principles, ERD, API specs, security, error catalogue, and onboarding.

#### Stage 9: AI Disease Scanner Integration (Planned)
- **Objective:** Camera hardware integration for preliminary visual disease screening using TensorFlow Lite / Firebase AI Logic.
- **Deliverables:**
  - On-device TFLite inference or Gemini API multimodal inference for skin lesion / eye discharge analysis.
  - Scan history and accuracy comparison UI.

#### Stage 10: Spatial Disease Surveillance & PostGIS Mapping (Planned)
- **Objective:** Geographical outbreak tracking for livestock authorities and biosecurity alerts for farmers.
- **Deliverables:**
  - PostGIS spatial radius queries for disease report clustering.
  - Interactive outbreak map screen in Flutter using OpenStreetMap / Mapbox.
  - Biosecurity recommendation engine.

#### Stage 11: Push Notifications & Messaging (Planned)
- **Objective:** Automated real-time alerts for appointment confirmations, vaccination reminders, and outbreak warnings.
- **Deliverables:** Firebase Cloud Messaging (FCM) integration for Flutter client; Spring Boot FCM background worker.

#### Stage 12: Production Infrastructure & CI/CD Deployment (Planned)
- **Objective:** Production launch on cloud infrastructure.
- **Deliverables:**
  - GitHub Actions CI/CD workflows for both repos.
  - AWS ECS / RDS deployment setup with automated backups and monitoring (Prometheus + Grafana).
