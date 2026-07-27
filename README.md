# 🐄 Vetra — Native Livestock & Veterinary Healthcare Mobile Platform

**Vetra** is a production-grade, dual-role livestock management and veterinary healthcare mobile application built with **Flutter 3.x**, **Riverpod**, **GoRouter**, and **Material 3 Design System**.

Every legacy HTML prototype has been fully migrated into native Flutter widgets while strictly preserving Clean Architecture, responsive layouts, and role-based authentication safety.

---

## 🚀 Accomplishments & Milestones Completed

- ✅ **100% Native Flutter UI Migration**: Replaced all **64 HTML prototype screens** with production-ready Flutter screens.
- ✅ **Dual-Role Authentication Architecture**: Implemented completely separate login, registration, and dashboard journeys for **Farmers** and **Veterinarians**.
- ✅ **GoRouter Guards & Session Restoration**: Active role validation preventing Farmers from seeing Vet tools and vice versa.
- ✅ **Redesigned Disease Outbreak Workflow**:
  `Farmer AI Scan` ➔ `AI Prediction Result` ➔ `Farmer Submits Report` ➔ `Veterinarian Clinical Review` ➔ `Official Confirmation` ➔ `Spatial Radius Outbreak Broadcast`.
- ✅ **Clean Architecture Standard**: Structured by feature layers (`data`, `domain`, `presentation`) with zero duplicated layout code.
- ✅ **Quality Gates Passed**: 0 issues on `flutter analyze`, 100% pass on `flutter test`.

---

## 📱 User Roles & Complete Feature Inventory

### 🐄 1. Farmer Module
Targeted for livestock owners, dairy managers, and herd keepers.

- **Farmer Dashboard (`/farmer-dashboard`)**: Overview metrics (Registered Animals, Checkups Due), active outbreak alerts, and quick actions.
- **My Animals & Herd Management (`/my-animals`)**: Animal cards, offline state support, tag filtering.
- **Animal Passport & Timeline (`/animal-passport`, `/animal-timeline`)**: QR code identification, digital passport, breeding records, document vault, ownership transfer.
- **AI Disease Scanner (`/disease-scanner`, `/analyzing-scan`, `/scan-accuracy-comparison`)**: Camera/gallery image capture, AI prediction, confidence scoring.
- **Nearby Vets & Appointment Booking (`/nearby-vets`, `/appointment-booking`)**: Spatial vet discovery, clinic details, booking flow.
- **Outbreak Map & Risk Zones (`/outbreak-map`, `/risk-zone`)**: Local outbreak heatmap and quarantine radius alerts.
- **Farmer Profile & Settings (`/profile`, `/settings-overview`)**: Farm details, notification preferences, security, language options.

---

### 🩺 2. Veterinarian Module
Targeted for licensed veterinary practitioners and clinical epidemiologists.

- **Vet Dashboard (`/vet-dashboard`)**: Practitioner header, active license badge (`VET ROLE`), today's appointments, pending triage requests, and urgent AI disease review queue.
- **Incoming Triage Requests (`/vet-requests`)**: Farmer consultation requests, emergency calls, appointment accept/reschedule controls.
- **Consultation History & Case Management (`/consultation-history`)**: Historical clinical cases, diagnosis entries, prescription details.
- **Vet Outbreak Map & GIS Layer (`/vet-outbreak-map`)**: Interactive GIS map, 15 km practice radius overlay, confirmed outbreak listings, pending AI reports awaiting clinical verification, map legend.
- **Vet Profile & Duty Status (`/vet-profile`)**: Practitioner info (Reg #, Qualification, Specialization, Clinic/Hospital, Experience), interactive **Duty Availability Switch** (On-Call / Unavailable), quick actions, and secure logout.

---

## 🎨 Design System Components

Located under `lib/core/design_system/`:

- **Tokens**: `AppColors` (Tailored palette), `AppTypography` (Google Fonts Inter), `AppSpacing`, `AppTheme`.
- **Buttons**: `PrimaryButton`, `SecondaryButton`.
- **Cards**: `AlertCard`, `AnimalCard`, `VetCard`, `ProfileHeaderCard`, `AvailabilityCard`, `ActionCard`.
- **Tiles & Inputs**: `InfoTile`, `AppTextField`.
- **Navigation Bars**: `FarmerBottomNavigation` (5 tabs), `VetBottomNavigation` (5 tabs).

---

## 📂 Project Directory Structure

```
lib/
├── main.dart                             # App entry point with ProviderScope
├── core/
│   ├── design_system/                    # Material 3 tokens, colors, typography, buttons, cards, tiles
│   ├── models/                           # Core entities (UserRole, UserModel)
│   ├── router/                           # AppRouter GoRouter configuration & role guards
│   └── services/                         # AuthService & session restoration logic
└── features/
    ├── ai/                               # Disease scanner, scan analysis & accuracy comparison
    ├── animal/                           # My Animals, Animal Passport, Timeline, Ownership Transfer
    ├── auth/                             # Splash, Onboarding, Welcome, Farmer Login/Register, Vet Login/Register
    ├── disease/                          # Report disease, disease details, biosecurity advice
    ├── farmer/                           # Farmer Dashboard, Nearby Vets
    ├── maps/                             # Outbreak Map, Risk Zones
    ├── medical/                          # Diagnosis entry, Treatment, Prescriptions, Vaccination Schedule
    ├── profile/                          # Farmer Profile, Vet Profile & modular profile widgets
    ├── settings/                         # App Settings, Security, Privacy, Language
    ├── shared/                           # Notifications, Global Search, QR Scanner
    └── veterinarian/                     # Vet Dashboard, Vet Requests, Cases, Vet Outbreak Map
```

---

## 🔗 Backend API Integration Specs

A complete Spring Boot API integration specification mapping every Flutter screen to REST endpoints, request/response DTOs, and PostgreSQL/PostGIS database entities is available at:

📄 **[docs/BACKEND_INTEGRATION_GUIDE.md](file:///Users/0mrajput/vetra/docs/BACKEND_INTEGRATION_GUIDE.md)**

---

## 🛠️ Getting Started & Verification

### Prerequisites
- Flutter SDK `^3.x.x`
- Dart SDK `^3.x.x`

### Running the Application
```bash
# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit & widget test suite
flutter test

# Run app on device or emulator
flutter run
```

---

## 📜 Branch & Commit Information

- **Main Feature Branch**: `feature/flutter-native-ui`
- **Repository**: [https://github.com/omrajput14/vetra](https://github.com/omrajput14/vetra)
