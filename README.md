# Vetra Mobile Client — Veterinary Operating System (VetOS)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.x-purple.svg)](https://riverpod.dev)
[![GoRouter](https://img.shields.io/badge/Router-GoRouter-teal.svg)](https://pub.dev/packages/go_router)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Vetra is an enterprise **Veterinary Operating System (VetOS)** application built for rural farmers and field veterinarians. Built with Flutter 3, Riverpod 2, GoRouter, and Clean Architecture, it provides digital animal identity (Animal Passport), clinical workflow management, Electronic Veterinary Medical Records (EVMR), and visual diagnostic support.

---

## Core Capabilities

- **Dual-Role Navigation:** Role-Based Access Control (RBAC) enforcing distinct, secure navigation stacks for **Farmers** and **Veterinarians**.
- **Digital Animal Passport:** Register livestock, generate and scan QR codes, and view complete chronological animal medical histories.
- **Appointment Management:** Schedule clinical visits with registered vets, track booking states (`PENDING` → `CONFIRMED` → `COMPLETED` / `CANCELLED`).
- **Immutable Clinical History (EVMR):** Vets issue digital medical records upon visit completion; farmers access permanent medical timelines for their herd.
- **Offline Resilience:** Local caching of Animal Passports and medical records for operation in zero-connectivity rural zones.

---

## Clean Architecture & Project Structure

Each feature in `lib/features/` follows strict Clean Architecture layer isolation:

```
lib/
├── core/             ← Design system, router, network client (Dio), config
├── features/
│   ├── auth/         ← Dual-role login & registration, JWT token storage
│   ├── farmer/       ← Farmer dashboard & animal management
│   ├── veterinarian/ ← Vet dashboard & appointment queue
│   ├── animal/       ← Animal CRUD, QR scanner, Animal Passport
│   ├── appointment/  ← Booking flow & status management
│   ├── medical_record/ ← EVMR creation (vet) & timeline view (farmer)
│   ├── profile/      ← Profile management
│   ├── maps/         ← Outbreak map & spatial risk zones
│   └── settings/     ← User preferences & security
```

---

## Professional Documentation Index

Comprehensive engineering specifications and design records are organized under `docs/`:

### 🏛 Architecture & Product
- [Engineering Principles](docs/engineering/00-principles.md) — *The Vetra Engineering Constitution*
- [Product Requirements Document (PRD v2.0.0)](docs/product/01-PRD.md)
- [Software Architecture Document (SAD)](docs/architecture/02-SAD.md)
- [Architecture Decision Records (ADRs)](docs/architecture/adr/INDEX.md)
- [Project Roadmap](docs/roadmap/19-roadmap.md)

### 🎨 Design & Navigation
- [Navigation Graph](docs/design/NAVIGATION_GRAPH.md)
- [Screen Status Tracker](docs/design/SCREEN_STATUS.md)
- [Vetra Design System](docs/design/VETRA_DESIGN.md)

### 🛠 Engineering Guides & Standards
- [Developer Onboarding Guide](docs/guides/20-developer-onboarding.md) — *Start here!*
- [Coding Standards & Conventions (Flutter/Dart)](docs/engineering/12-coding-standards.md)
- [Git Workflow & Branching Strategy](docs/engineering/13-git-workflow.md)
- [Testing Strategy](docs/guides/14-testing-strategy.md)
- [Backend Integration Guide](docs/api/backend-integration.md)

---

## Getting Started

### 1. Prerequisites
- Flutter SDK (3.x stable)
- Android Studio / VS Code with Flutter extension
- Android SDK API 34+ / Xcode 15+
- Android Emulator or physical device

### 2. Run Application
```bash
# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Launch on emulator/device
flutter run
```

Ensure the backend service (`vetra-backend`) is running locally at `http://10.0.2.2:8080`. For complete setup instructions, consult the [Developer Onboarding Guide](docs/guides/20-developer-onboarding.md).
