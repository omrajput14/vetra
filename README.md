# Vetra Mobile Client — Flutter Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod%202.x-purple.svg)](https://riverpod.dev)
[![GoRouter](https://img.shields.io/badge/Router-GoRouter-teal.svg)](https://pub.dev/packages/go_router)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Vetra is an AI-powered livestock healthcare and disease surveillance application built for rural farmers and field veterinarians. Built with Flutter, Riverpod, and Clean Architecture, it provides digital animal identity (Animal Passport), appointment scheduling, Electronic Veterinary Medical Records (EVMR), and AI-assisted preliminary diagnostics.

---

## Features

- **Dual-Role Navigation:** Customized, secure dashboards and navigation stacks for **Farmers** and **Veterinarians**.
- **Digital Animal Passport:** Register livestock, generate & scan QR codes, and view complete animal medical histories.
- **Appointment Management:** Book clinical appointments with nearby registered vets, track booking status (`PENDING` → `CONFIRMED` → `COMPLETED`).
- **Clinical History (EVMR):** Vets issue immutable digital medical records; farmers view their animals' permanent medical timelines.
- **Offline First:** Local caching of animal passports and medical records for low-connectivity rural environments.

---

## Clean Architecture & Project Structure

Each feature in `lib/features/` follows strict Clean Architecture boundaries:

```
lib/
├── core/             ← Design system, router, network client, config
├── features/
│   ├── auth/         ← Dual-role login & registration
│   ├── farmer/       ← Farmer dashboard & animal management
│   ├── veterinarian/ ← Vet dashboard & appointment queue
│   ├── animal/       ← Animal CRUD, QR scanner, Animal Passport
│   ├── appointment/  ← Booking flow & status management
│   ├── medical_record/ ← EVMR creation (vet) & timeline view (farmer)
│   ├── profile/      ← Profile editing
│   ├── maps/         ← Outbreak map & risk zones
│   └── settings/     ← User preferences & security
```

---

## Documentation Index

Comprehensive documentation for this repository is organized under `docs/`:

### 🏛 Architecture & Product
- [Engineering Principles](docs/engineering/00-principles.md) — *The Vetra Engineering Constitution*
- [Product Requirements Document (PRD)](docs/product/01-PRD.md)
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
- Android Emulator or physical device

### 2. Run Application
```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

Make sure the backend API (`vetra-backend`) is running locally at `http://10.0.2.2:8080`. For step-by-step setup, see the [Developer Onboarding Guide](docs/guides/20-developer-onboarding.md).
