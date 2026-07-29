# Product Requirements Document (PRD)
**Document ID:** PRD-01  
**Status:** Active  
**Last Updated:** 2026-07-29  
**Applies To:** Vetra Platform (`omrajput14/vetra` & `omrajput14/vetra-backend`)  
**References:** [Engineering Principles](../engineering/00-principles.md), [Domain Model](../domain/03-domain-model.md)

---

## 1. Executive Summary

### 1.1 Product Overview
**Vetra** is an end-to-end, AI-powered livestock healthcare management and disease surveillance ecosystem tailored for rural agricultural markets. It bridges the gap between rural livestock farmers and registered veterinary doctors by providing digital animal identity (Animal Passport), appointment scheduling, Electronic Veterinary Medical Records (EVMR), and AI-assisted preliminary disease diagnostics.

### 1.2 Vision
To eliminate preventable livestock mortality and disease outbreaks in rural farming communities worldwide through accessible, offline-capable digital healthcare tools.

### 1.3 Mission
Empower smallholder farmers with digital identity for their livestock and instant access to qualified veterinary care, while providing veterinarians with modern clinical record-keeping tools and authorities with real-time disease surveillance.

### 1.4 Core Value Proposition
- **For Farmers:** Single source of truth for herd health, instant vet appointment booking, permanent digital animal passports, and AI-assisted preliminary disease scanning.
- **For Veterinarians:** Streamlined appointment management, digital EVMR creation, patient history at a glance, and reduced administrative overhead.
- **For Livestock Authorities (Future):** Real-time outbreak mapping and biosecurity alert dispatch.

---

## 2. Problem Statement

1. **Lack of Digital Animal Identity:** Rural farmers keep paper records or no records at all for animal medical histories, leading to repeated misdiagnoses and unverified animal sales.
2. **Veterinary Care Access Bottlenecks:** Farmers in remote villages struggle to locate, contact, and schedule qualified veterinary doctors for emergency or routine care.
3. **Delayed Outbreak Identification:** Infectious livestock diseases (e.g., Foot-and-Mouth Disease, Lumpy Skin Disease) spread rapidly due to absent real-time surveillance.
4. **Paper-Based Clinical History:** Veterinarians lack access to past treatment history when examining an animal in the field, increasing adverse drug reaction risks.

---

## 3. User Personas & Target Audience

### Persona A: Ramesh Kumar (Smallholder Dairy Farmer)
- **Age:** 42 | **Location:** Karnal District, Haryana | **Herd:** 8 Cattle & Buffaloes
- **Tech Literacy:** Low-to-Medium (uses WhatsApp, local banking apps; low bandwidth 3G/4G).
- **Needs:** Quick way to call a vet when a cow is sick, keep track of vaccination dates, show digital proof of health when selling an animal.

### Persona B: Dr. Suresh Sharma (Field Veterinary Surgeon)
- **Age:** 38 | **Location:** District Veterinary Hospital & Private Practice
- **Tech Literacy:** High (Android smartphone, laptop).
- **Needs:** Manage daily farm visits efficiently, record prescriptions digitally without carrying paper registers, access past animal history instantly via QR scan.

---

## 4. Feature Inventory & Current Implementation Status

| Feature Module | Description | Target User | Implementation Status |
|---|---|---|---|
| **Auth & Profiles** | Role selection (Farmer vs Vet), JWT authentication, profile management, vet directory | Both | **Stage 1–3 Completed** |
| **Livestock Passport** | Add animals, generate QR code, view herd list, animal details | Farmer | **Stage 4 Completed** |
| **Appointment Booking** | Schedule visits, select vet, state machine (`PENDING` → `CONFIRMED` → `COMPLETED`/`CANCELLED`) | Both | **Stage 5–6 Completed** |
| **EVMR Module** | Create & view immutable clinical records, treatment, diagnosis, prescription, follow-up | Both | **Stage 7 Completed** |
| **AI Disease Scanner** | Camera-based disease scan, preliminary AI suggestions | Farmer | Stage 8 (Planned) |
| **Outbreak Mapping** | PostGIS disease outbreak map & risk zones | Both | Stage 9 (Planned) |
| **Push Notifications** | Appointment alerts, disease biosecurity warnings | Both | Stage 10 (Planned) |

---

## 5. System Constraints & Non-Functional Requirements

1. **Offline Capability (Mobile):** Essential features (viewing cached animal passports, past medical records) must function offline.
2. **Network Resilience:** Low-bandwidth optimization (payload size < 50 KB for routine APIs).
3. **Immutability:** Medical records are legally binding clinical documents and cannot be edited or deleted once issued.
4. **Security & Privacy:** Strictly enforced role-based access control (RBAC). Farmers cannot view other farmers' animals or records.
5. **Localization:** Multi-language support (English, Hindi, regional languages) planned for production release.

---

## 6. Success Metrics (KPIs)

- **Appointment Completion Rate:** ≥ 85% of booked appointments completed with an EVMR record.
- **EVMR Adoption:** 100% of completed appointments generate a digital medical record.
- **API Latency:** p95 < 200 ms for core API operations.
- **App Crash-Free Rate:** ≥ 99.5% crash-free sessions on Android devices.
