# Software Architecture Document — Flutter App
**Document ID:** ARCH-02-FLUTTER  
**Status:** Active  
**Last Updated:** 2026-07-29  
**Applies To:** `omrajput14/vetra`  
**References:** [Engineering Principles](../engineering/00-principles.md), [Domain Model](../domain/03-domain-model.md), [API Specification](../../vetra-backend/docs/api/06-specification.md)

---

## 1. System Overview

The Vetra Flutter app is the mobile client for the Vetra platform. It serves two distinct user roles — Farmers and Veterinarians — through role-specific navigation stacks, UI layouts, and data access patterns.

**Technology Stack:**

| Component | Technology |
|---|---|
| Language | Dart 3.x |
| Framework | Flutter 3.x (Material 3) |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| HTTP Client | Dio (with interceptors) |
| Local Storage | flutter_secure_storage (tokens), SharedPreferences (preferences) |
| Minimum Android SDK | API 24 (Android 7.0) |
| Target Android SDK | API 34 (Android 14) |

---

## 2. Clean Architecture

Each feature module in `lib/features/` is structured into three layers following Clean Architecture:

```
lib/features/<feature>/
├── data/
│   ├── models/          ← Dart data models (from JSON)
│   ├── services/        ← Dio HTTP service classes
│   └── repositories/    ← Concrete repository implementations
├── domain/
│   └── repositories/    ← Abstract repository interfaces (Dart abstract classes)
└── presentation/
    ├── pages/           ← Full-screen pages
    ├── widgets/         ← Feature-scoped reusable widgets
    └── providers/       ← Riverpod providers & state notifiers
```

**Dependency rule:** `presentation/` depends on `domain/`; `data/` implements `domain/`. Widgets never import from `data/` directly.

---

## 3. Feature Modules

| Module | Path | Description |
|---|---|---|
| `auth` | `lib/features/auth/` | Login, registration, JWT management, token refresh |
| `farmer` | `lib/features/farmer/` | Farmer dashboard, animal list navigation |
| `veterinarian` | `lib/features/veterinarian/` | Vet dashboard, appointment management |
| `animal` | `lib/features/animal/` | Animal CRUD, QR code scanning, Animal Passport |
| `appointment` | `lib/features/appointment/` | Booking flow, status display |
| `medical_record` | `lib/features/medical_record/` | EVMR creation (vet) and viewing (farmer) |
| `profile` | `lib/features/profile/` | Profile view/edit for both roles |
| `maps` | `lib/features/maps/` | Outbreak map, disease risk zones |
| `disease` | `lib/features/disease/` | Disease reporting, biosecurity info |
| `settings` | `lib/features/settings/` | App settings, notifications, security |
| `ai` | `lib/features/ai/` | AI disease scan (camera integration) |
| `dashboard` | `lib/features/dashboard/` | Role-agnostic dashboard data |

---

## 4. Navigation Architecture

Navigation uses **GoRouter** with declarative route guards. Routes are protected based on authentication status and user role.

```
/splash
/onboarding
/login
/register
  /farmer
  /vet

← Auth required below this point →
← Role = FARMER below →
/farmer/dashboard
/farmer/animals
/farmer/animals/:id
/farmer/animals/:id/medical-history
/farmer/appointments
/farmer/appointments/:id

← Role = VET below →
/vet/dashboard
/vet/appointments
/vet/appointments/:id
/vet/appointments/:id/medical-record/create
/vet/appointments/:id/medical-record

← Both roles →
/profile
/settings
/notifications
/maps/outbreak
```

**Route Guards:**
- Unauthenticated → redirect to `/login`
- Farmer accessing `/vet/**` → redirect to farmer dashboard
- Vet accessing `/farmer/**` → redirect to vet dashboard

Full navigation graph: [`docs/design/NAVIGATION_GRAPH.md`](../design/NAVIGATION_GRAPH.md)

---

## 5. State Management

**Riverpod** is used for all application state. No `setState()` except for purely local widget animations.

### Provider Types by Use Case

| Use Case | Provider Type |
|---|---|
| Authentication state | `StateNotifierProvider<AuthNotifier, AuthState>` |
| Async data (single fetch) | `FutureProvider` or `AsyncNotifierProvider` |
| List data with refresh | `StateNotifierProvider` with `AsyncValue<List<T>>` |
| Simple derived state | `Provider` |
| User-scoped data | `.family` modifier with `userId` or `animalId` |

### Auth State Flow

```
App start
    │
    ▼ SplashPage
Check flutter_secure_storage for refresh_token
    │ Found → POST /auth/refresh
    │ Not found → /login
    ▼
AuthState.authenticated(user, role)
    │
    ▼ GoRouter redirect
role = FARMER → /farmer/dashboard
role = VET → /vet/dashboard
```

---

## 6. Network Layer

**Dio** instance is configured once via `DioClient` and provided via Riverpod:

```
DioClient
├── BaseOptions (baseUrl, connectTimeout, receiveTimeout)
├── LogInterceptor (debug builds only)
├── AuthInterceptor (injects Authorization: Bearer <token>)
└── ErrorInterceptor (converts Dio errors → ApiException)
```

**Token refresh on 401:**
The `AuthInterceptor` catches `401 Unauthorized` responses. If the error code is `AUTH_002` (access token expired), it:
1. Calls `POST /auth/refresh` with the stored refresh token
2. Retries the original request with the new access token
3. If refresh fails (AUTH_004/AUTH_005), triggers logout

---

## 7. Design System

The design system lives in `lib/core/design_system/` and provides:

- **Color tokens:** Primary, secondary, surface, error — defined once, used everywhere
- **Typography:** Material 3 text theme with custom font (system default + Outfit via Google Fonts)
- **Spacing:** 4/8/12/16/24/32 px grid
- **Component library:** `VetraButton`, `VetraCard`, `VetraTextField`, `StatusBadge`, `EmptyState`, `LoadingState`

**Rule:** No hardcoded colors, font sizes, or padding values in widget files. All values must reference the design system tokens or theme.

---

## 8. Key Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| State management | Riverpod | Compile-safe DI, no `BuildContext` needed for providers, testable |
| Navigation | GoRouter | Declarative, URL-based, testable route guards |
| HTTP client | Dio | Interceptor support for auth/retry, multipart support for future image upload |
| Token storage | flutter_secure_storage | Platform-native Keystore/Keychain — safer than SharedPreferences |
| Role separation | Separate navigation stacks | Security isolation; impossible to accidentally render wrong role's UI |
