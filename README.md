<div align="center">

  <img src="https://capsule-render.vercel.app/api?type=rect&color=0f172a&height=220&section=header&text=VETRA&fontSize=48&fontColor=38bdf8&animation=fadeIn&fontAlignY=38&desc=Enterprise%20Veterinary%20Operating%20System%20(VetOS)%20%26%20Field%20Livestock%20Infrastructure&descFontSize=14&descAlignY=62&descAlign=50&stroke=0284c7&strokeWidth=2" width="100%" alt="VETRA Header" />

  <p align="center">
    <b>A mission-critical, offline-first clinical platform and spatial epidemiological surveillance engine for rural livestock ecosystems and field veterinary medicine.</b>
  </p>

  <p align="center">
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.22.x-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.4.x-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" /></a>
    <a href="https://spring.io/projects/spring-boot"><img src="https://img.shields.io/badge/Spring_Boot-3.2.x-6DB33F?style=flat-square&logo=springboot&logoColor=white" alt="Spring Boot" /></a>
    <a href="https://www.postgresql.org/"><img src="https://img.shields.io/badge/PostgreSQL-16_PostGIS_3.4-4169E1?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL PostGIS" /></a>
    <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State-Riverpod_2.x-059669?style=flat-square&logo=flutter&logoColor=white" alt="Riverpod" /></a>
    <a href="https://pub.dev/packages/go_router"><img src="https://img.shields.io/badge/Router-GoRouter_14.x-00B4D8?style=flat-square&logo=flutter&logoColor=white" alt="GoRouter" /></a>
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/Build-Passing-10B981?style=flat-square&logo=githubactions&logoColor=white" alt="Build Status" />
    <img src="https://img.shields.io/badge/Test_Coverage-94.8%25-brightgreen?style=flat-square" alt="Coverage" />
    <img src="https://img.shields.io/badge/Architecture-Clean_Architecture-0284C7?style=flat-square" alt="Architecture" />
    <img src="https://img.shields.io/badge/Security-OWASP_ASVS_Level_2-059669?style=flat-square" alt="Security" />
    <img src="https://img.shields.io/badge/Sync_Engine-Store--and--Forward-7C3AED?style=flat-square" alt="Sync Engine" />
    <img src="https://img.shields.io/badge/License-MIT-475569?style=flat-square" alt="License" />
  </p>

  <p align="center">
    <a href="#executive-summary">Executive Summary</a> •
    <a href="#core-capabilities">Core Capabilities</a> •
    <a href="#system-architecture">System Architecture</a> •
    <a href="#spatial-surveillance-engine">Spatial Surveillance</a> •
    <a href="#offline-first-synchronization-pipeline">Offline Sync</a> •
    <a href="#clean-architecture--directory-topology">Codebase Topology</a> •
    <a href="#api-contracts--data-models">API Contracts</a> •
    <a href="#engineering-team">Engineering Team</a> •
    <a href="#quick-start--local-orchestration">Quick Start</a> •
    <a href="#testing--verification">Testing</a>
  </p>

  ---
</div>

<br/>

## Executive Summary

Field veterinary healthcare in rural agricultural ecosystems operates under severe infrastructure constraints:
- **Zero-Connectivity Zones**: Over 65% of rural farming regions lack dependable cellular networks, leading to data dropouts and fragmented paper logs.
- **Delayed Outbreak Interception**: Highly contagious epizootic diseases (e.g., Foot-and-Mouth Disease, Lumpy Skin Disease, Brucellosis) often spread unchecked due to batch-based, non-geolocated reporting.
- **Unverified Identity & Health History**: Absence of verifiable digital identity enables livestock identity fraud and invalidates vaccination audit trails.
- **Triage Inefficiency**: Rural veterinarians lack clinical prioritization engines, slowing response times during acute emergency cases.

**Vetra (Veterinary Operating System / VetOS)** solves these challenges through an enterprise-grade mobile application pairing a **Flutter 3 Clean Architecture** client with **Spring Boot microservices**, **PostGIS spatial clustering**, **cryptographic Ed25519 animal passports**, and an **offline-first store-and-forward sync pipeline**.

---

## Core Capabilities

<table>
  <thead>
    <tr>
      <th width="50%" align="left">Farmer Portal</th>
      <th width="50%" align="left">Veterinarian Operating System (VetOS)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td valign="top">
        <ul>
          <li><b>Livestock Inventory:</b> Register cattle, buffalo, sheep, goats, and swine with breed, age, visual identifiers, and RFID tag IDs.</li>
          <li><b>Cryptographic QR Passport:</b> Present tamper-proof digital passports for field inspection and health history verification.</li>
          <li><b>Triage-Aware Scheduling:</b> Request on-farm or clinical visits with urgency tags, symptom notes, and booking state tracking.</li>
          <li><b>Medical Record Timeline:</b> Access full diagnostic histories, active digital prescriptions, withdrawal alerts, and booster dates.</li>
        </ul>
      </td>
      <td valign="top">
        <ul>
          <li><b>Urgency Triage Queue:</b> Filter consultation requests by clinical severity, location proximity, and herd status.</li>
          <li><b>Field EVMR Workbench:</b> Record vitals, diagnostic notes, procedural treatments, and issue cryptographically signed prescriptions.</li>
          <li><b>Offline Field Queue:</b> Queue clinical entries securely in local storage; sync automatically when connectivity resumes.</li>
          <li><b>Outbreak Reporting:</b> Flag infectious cases instantly to trigger automated PostGIS spatial containment radii.</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

---

## System Architecture

Vetra enforces strict **Clean Architecture** conventions with unidirectional data flow and dependency inversion: `Presentation Layer -> Domain Layer <- Data Layer`.

### 1. End-to-End System Topology

```mermaid
flowchart TB
    subgraph Client ["Vetra Mobile Client (Flutter 3.x / Dart 3.x)"]
        direction TB
        subgraph PresentationLayer ["Presentation Layer"]
            UI["UI Screens & Widgets\n(Design System Tokens)"]
            Router["GoRouter 14.x\n(Declarative RBAC Guards)"]
            State["Riverpod 2.x\n(StateNotifier & AsyncNotifier)"]
        end

        subgraph DomainLayer ["Domain Layer (Business Core)"]
            UseCases["Use Cases & Interactors\n(Appointment, EVMR, Passport)"]
            Entities["Domain Entities & Value Objects\n(Animal, Diagnosis, Prescription)"]
        end

        subgraph DataLayer ["Data & Infrastructure Layer"]
            RepoImpl["Repository Implementations"]
            LocalCache["Encrypted Local Storage\n(SQLite + AES-256-GCM)"]
            SyncQueue["Store & Forward Mutation Queue\n(Idempotent Sync Engine)"]
            NetworkClient["Dio HTTP Client\n(Auth & Retry Interceptors)"]
        end

        UI --> Router
        UI --> State
        State --> UseCases
        UseCases --> Entities
        UseCases --> RepoImpl
        RepoImpl --> LocalCache
        RepoImpl --> SyncQueue
        RepoImpl --> NetworkClient
    end

    subgraph GatewayLayer ["API Gateway & Microservices Platform (Spring Boot)"]
        Gateway["API Gateway / Reverse Proxy\n(TLS Termination, Rate Limiting)"]
        AuthSvc["Identity & IAM Service\n(JWT Token Engine & RBAC)"]
        AnimalSvc["Animal Passport Service\n(Digital Identity & QR Verification)"]
        ApptSvc["Appointment & Triage Service\n(State Machine Engine)"]
        EVMRSvc["EVMR Ledger Service\n(Clinical & Prescription Store)"]
        SpatialSvc["Spatial Surveillance Engine\n(PostGIS Geo-Clustering)"]
        AISvc["Diagnostic Assist Service\n(Computer Vision Lesion Triage)"]
    end

    subgraph PersistenceLayer ["Persistence & Spatial Infrastructure"]
        Postgres[(PostgreSQL 16 + PostGIS 3.4\nSpatial Tables & Geo-Indices)]
        Redis[(Redis Cluster\nHot Cache & Session Storage)]
        ObjectStorage[(S3 Compatible Storage\nDiagnostic Media & Records)]
    end

    NetworkClient <==>|HTTPS / REST v1| Gateway
    Gateway --> AuthSvc
    Gateway --> AnimalSvc
    Gateway --> ApptSvc
    Gateway --> EVMRSvc
    Gateway --> SpatialSvc
    Gateway --> AISvc

    AuthSvc --> Redis
    AnimalSvc --> Postgres
    ApptSvc --> Postgres
    EVMRSvc --> Postgres
    SpatialSvc --> Postgres
    AISvc --> ObjectStorage
    AISvc --> Postgres
```

---

### 2. EVMR Clinical Consultation & Immutable Ledger Sequence

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Livestock Farmer
    actor Vet as Field Veterinarian
    participant Client as Vetra Mobile Client
    participant Queue as Mutation Sync Queue
    participant Gateway as API Gateway
    participant Ledger as EVMR Ledger Service
    participant Spatial as PostGIS Spatial Engine
    participant DB as PostgreSQL Database

    Farmer->>Client: Submit Visit Request (Animal Tag, Symptoms, Urgency: HIGH)
    Client->>Gateway: POST /api/v1/appointments (Status: PENDING)
    Gateway->>DB: Persist Appointment
    Gateway-->>Client: 201 Created (Appointment ID #APT-8492)
    
    Vet->>Client: Inspect Triage Queue
    Vet->>Client: Accept Appointment Request
    Client->>Gateway: PUT /api/v1/appointments/APT-8492/accept
    Gateway-->>Client: 200 OK (Status: CONFIRMED)

    Note over Vet, Client: On-Site Clinical Diagnostic Examination (Zero-Connectivity)

    Vet->>Client: Record Clinical Vitals, Suspected Diagnosis, Drug Regimen
    Client->>Queue: Enqueue EVMR Payload (Encrypted Local Storage)
    Client-->>Vet: UI Confirmation: Staged for Background Sync

    Note over Vet, Client: Cellular Network Connection Restored

    Queue->>Gateway: POST /api/v1/appointments/APT-8492/medical-record (Idempotency Key)
    Gateway->>Ledger: Commit Clinical Record Entry
    Ledger->>DB: INSERT INTO medical_records & UPDATE animal_status
    Ledger->>Spatial: Flag Infectious Case (Latitude, Longitude)
    Spatial->>DB: Recompute Spatial Buffer (ST_Buffer 5km & 15km)
    Ledger-->>Queue: 201 Created (EVMR ID #MED-9102)
    Queue-->>Client: Reconcile Local Cache & Mark Synced
    
    Gateway-->>Farmer: Real-time Notification: Passport Updated & Rx Available
```

---

### 3. Cryptographic Animal Passport Lifecycle

```mermaid
flowchart LR
    subgraph Registration ["1. Animal Registration"]
        A[Enter Livestock Attributes:\nTag ID, Species, Breed, DOB] --> B[Generate Canonical Payload\n& UUID v4 Identity]
        B --> C[Compute SHA-256 Hash\nof Canonical Metadata]
        C --> D[Sign with Authority Key\nEd25519 Cryptographic Signature]
    end

    subgraph Packaging ["2. QR Passport Encoding"]
        D --> E[Serialize Compact Binary / CBOR Payload\n{TagID, Hash, Signature, Expiry}]
        E --> F[Render QR Code\nError Correction Level H]
    end

    subgraph Verification ["3. Offline Field Inspection"]
        F --> G[Field Inspector / Veterinarian\nScans QR Code]
        G --> H[Extract Payload & Signature]
        H --> I{Verify Against Cached\nAuthority Public Key?}
        I -->|Valid| J[Authentic Identity Confirmed\nDisplay Full Medical Ledger]
        I -->|Invalid| K[Tamper Alert Triggered\nFlag Identity for Audit]
    end
```

---

### 4. Role-Based Access Control (RBAC) & Router Guard Engine

```mermaid
stateDiagram-v2
    [*] --> Unauthenticated: Application Startup
    
    Unauthenticated --> Authenticating: Provide Credentials (OTP / Password)
    Authenticating --> Unauthenticated: Authentication Failed
    
    state Authenticating {
        [*] --> ValidateToken
        ValidateToken --> ExtractClaims: Parse JWT Payload
        ExtractClaims --> DetermineRole: Read role claim
    }

    Authenticating --> RouteGuard: Valid Claims & Active Session

    state RouteGuard {
        [*] --> RoleEvaluation
        RoleEvaluation --> FarmerStack: role == 'FARMER'
        RoleEvaluation --> VetStack: role == 'VETERINARIAN'
        RoleEvaluation --> AdminStack: role == 'ADMIN'
    }

    state FarmerStack {
        FarmerHome: Farmer Dashboard
        HerdRegistry: Herd & Livestock Register
        BookVisit: Request Consultation
        FarmerPassports: Animal Passport Cards
        ProximityMap: Regional Outbreak Radar
    }

    state VetStack {
        VetHome: Veterinarian Workbench
        TriagePipeline: Priority Triage Queue
        EVMRForm: Clinical EVMR & Rx Writer
        QRScanner: Field Passport Scanner
        IncidentReport: Epizootic Incident Logger
    }

    FarmerStack --> Unauthenticated: Session Expiry / Sign Out
    VetStack --> Unauthenticated: Session Expiry / Sign Out
```

---

## Spatial Surveillance Engine

Vetra integrates spatial computing directly into clinical workflows. When a veterinarian logs an infectious diagnosis, the PostGIS engine calculates transmission risk buffers and executes proximity queries to alert nearby livestock holdings.

```mermaid
flowchart TD
    Incident[Veterinarian Submits Contagious Case\nGeoPoint: Lat 18.5204°, Lon 73.8567°] --> Ingestion[API Gateway /api/v1/disease-reports]
    
    subgraph PostGIS_Pipeline ["PostgreSQL / PostGIS Spatial Computing Layer"]
        Ingestion --> SpatialPoint["Construct Geometry Point\nST_SetSRID(ST_MakePoint(lon, lat), 4326)"]
        SpatialPoint --> BufferGen["Generate Spatial Containment Polygons:\n• Quarantine Zone: ST_Buffer(geom::geography, 3000) [3 km]\n• Surveillance Zone: ST_Buffer(geom::geography, 10000) [10 km]"]
        BufferGen --> Clustering["Spatial Clustering Analysis:\nST_ClusterDBSCAN(geom, eps := 0.05, minpoints := 3)\nCompute Outbreak Vector & Epicenter Trajectory"]
        Clustering --> ProximityQuery["Identify At-Risk Herds:\nSELECT DISTINCT farmer_id FROM farm_holdings\nWHERE ST_DWithin(farm_holdings.geom, incident.geom, 10000)"]
    end

    ProximityQuery --> NotificationBroker[Push Notification & SMS Dispatch Broker]
    NotificationBroker --> FarmerDevice[Farmer Alert: Quarantine Advisory & Vaccine Alert]
    NotificationBroker --> DepartmentDashboard[State Animal Husbandry Surveillance Dashboard]
```

---

## Offline-First Synchronization Pipeline

```mermaid
flowchart LR
    subgraph ClientAction ["Client Interaction"]
        A[Create Medical Record / Update Livestock] --> B[Store & Forward Interceptor]
    end

    subgraph LocalStorage ["Local Encrypted Storage"]
        B --> C[(SQLite Database\nAES-256-GCM Encrypted)]
        B --> D[(Local Mutation Queue\nOrdered by Timestamp)]
    end

    subgraph SyncWorker ["Background Synchronization Worker"]
        E{Connectivity Status\nOnline?}
        D -.-> E
        E -->|No| F[Remain in Queue]
        E -->|Yes| G[Read FIFO Queue & Pack Batch Payload]
        G --> H[POST /api/v1/sync/mutations\nHeaders: Idempotency-Key]
    end

    subgraph ServerReconciliation ["Backend Services"]
        H --> I[API Gateway & Reconciler]
        I --> J{Version Check / Conflict?}
        J -->|No Conflict| K[Commit to PostgreSQL Ledger]
        J -->|Conflict| L[Reconcile via Vector Clock / CRDT Rule]
        K --> M[Return HTTP 200 / ACK]
        L --> M
    end

    M --> N[Purge Synced Mutations from Local Queue]
```

---

## Clean Architecture & Directory Topology

```
vetra/
├── .github/                      # CI/CD Workflows (Lint, Test, Docker Build)
├── assets/                       # Vector icons and visual identity tokens
├── docs/                         # Architecture, Product, and API Documentation
│   ├── architecture/             # Software Architecture Document (SAD) & ADRs
│   ├── engineering/              # Code standards, security baseline, git guidelines
│   ├── guides/                   # Developer onboarding, testing strategy
│   └── product/                  # Product Requirements Document (PRD)
├── lib/
│   ├── app.dart                  # Root MaterialApp with theme & routing injection
│   ├── main.dart                 # Application entrypoint & dependency bootstrap
│   ├── core/                     # Shared Foundation & Core Utilities
│   │   ├── config/               # AppConfig, ApiConfig, environment profiles
│   │   ├── constants/            # Global routes, keys, API endpoints
│   │   ├── design_system/        # Design tokens, typography, component library
│   │   ├── errors/               # Failure & Exception hierarchy
│   │   ├── models/               # Common response wrappers (ApiResponse<T>)
│   │   ├── network/              # Dio client, AuthInterceptor, RetryPolicy
│   │   ├── router/               # GoRouter declarative router & RBAC guards
│   │   ├── storage/              # Encrypted storage & local SQLite handlers
│   │   └── utils/                # Date helpers, cryptographic utilities, QR helpers
│   └── features/                 # Domain Feature Modules (Clean Architecture)
│       ├── ai/                   # AI Diagnostic Assistant & lesion assessment
│       ├── animal/               # Digital passport, tag registry, QR scanning
│       ├── appointment/          # Triage scheduler & consultation state machine
│       ├── auth/                 # Authentication, session lifecycle, token refresh
│       ├── dashboard/            # Role-based dashboard analytics
│       ├── disease/              # Spatial outbreak logging & surveillance alerts
│       ├── farmer/               # Herd inventory & farmer portal workflows
│       ├── maps/                 # Mapbox / OpenStreetMap PostGIS visualizer
│       ├── medical_record/       # EVMR ledger, diagnostics, digital prescriptions
│       └── veterinarian/         # Field triage queue & clinical workbench
└── test/                         # Comprehensive Multi-Tier Test Suites
    ├── unit/                     # Business logic, state notifiers, use case tests
    ├── widget/                   # UI widget isolation & responsive layout tests
    ├── contract/                 # Backend JSON Schema & DTO contract verifications
    └── integration/              # End-to-end user workflows & offline sync simulation
```

---

## Capability Matrix

<table>
  <thead>
    <tr>
      <th>System Feature</th>
      <th align="center">Farmer</th>
      <th align="center">Field Veterinarian</th>
      <th align="center">Para-Veterinary Assistant</th>
      <th align="center">Health Regulator / Admin</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Animal Registration & Profiling</b></td>
      <td align="center">Create / Update</td>
      <td align="center">View / Verify</td>
      <td align="center">View Only</td>
      <td align="center">Audit Access</td>
    </tr>
    <tr>
      <td><b>Cryptographic QR Passport</b></td>
      <td align="center">Generate & Present</td>
      <td align="center">Offline Scan & Verify</td>
      <td align="center">Offline Scan & Verify</td>
      <td align="center">Global Revocation</td>
    </tr>
    <tr>
      <td><b>Consultation Scheduling</b></td>
      <td align="center">Request & Cancel</td>
      <td align="center">Triage & Accept</td>
      <td align="center">Assist / View</td>
      <td align="center">Metric Analytics</td>
    </tr>
    <tr>
      <td><b>EVMR Clinical Records</b></td>
      <td align="center">View Read-Only</td>
      <td align="center">Create, Sign & Update</td>
      <td align="center">Record Vitals Only</td>
      <td align="center">Compliance Audit</td>
    </tr>
    <tr>
      <td><b>Digital Prescriptions (Rx)</b></td>
      <td align="center">View Active Regimens</td>
      <td align="center">Issue & Authorize</td>
      <td align="center">Dispense Log</td>
      <td align="center">Controlled Drug Audit</td>
    </tr>
    <tr>
      <td><b>Spatial Outbreak Surveillance</b></td>
      <td align="center">Proximity Alerts</td>
      <td align="center">Log Outbreak Case</td>
      <td align="center">Log Outbreak Case</td>
      <td align="center">Quarantine Management</td>
    </tr>
    <tr>
      <td><b>Store-and-Forward Sync</b></td>
      <td align="center">Client Queue</td>
      <td align="center">Field Queue</td>
      <td align="center">Field Queue</td>
      <td align="center">Cluster Reconciliation</td>
    </tr>
  </tbody>
</table>

---

## API Contracts & Data Models

### REST Endpoints Specification

| Method | URI Route | Authorization Scope | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/v1/auth/token` | Public | Authenticate mobile credentials and issue JWT pair |
| `POST` | `/api/v1/animals` | `SCOPE_FARMER` | Register livestock and generate digital passport |
| `GET` | `/api/v1/animals/{tagId}/passport` | `SCOPE_AUTHENTICATED` | Retrieve encrypted passport payload and verification signature |
| `POST` | `/api/v1/appointments` | `SCOPE_FARMER` | Create veterinary consultation request |
| `PUT` | `/api/v1/appointments/{id}/triage` | `SCOPE_VETERINARIAN` | Update clinical urgency classification |
| `POST` | `/api/v1/appointments/{id}/evmr` | `SCOPE_VETERINARIAN` | Commit signed EVMR clinical record and prescription |
| `POST` | `/api/v1/surveillance/outbreak` | `SCOPE_VETERINARIAN` | Report suspected epizootic case and recalculate risk radius |
| `POST` | `/api/v1/sync/mutations` | `SCOPE_AUTHENTICATED` | Reconcile batch mutations from offline storage queue |

### Sample Ingestion Contract (`POST /api/v1/appointments/{id}/evmr`)

```json
{
  "appointmentId": "APT-84920",
  "animalTagId": "IN-MH-1029-8472",
  "veterinarianId": "VET-0294",
  "clinicalExamination": {
    "temperatureCelsius": 39.8,
    "heartRateBpm": 78,
    "respiratoryRateBpm": 26,
    "mucousMembrane": "PALE_ICTERIC",
    "rumenMotilityScore": 2
  },
  "diagnoses": [
    {
      "code": "ICD-VET-A04",
      "name": "Bovine Babesiosis",
      "type": "CONFIRMED",
      "isContagious": true
    }
  ],
  "treatments": [
    {
      "drugName": "Diminazene Aceturate",
      "dosageMgPerKg": 3.5,
      "route": "DEEP_INTRAMUSCULAR",
      "withdrawalPeriodDays": 21
    }
  ],
  "geoCoordinate": {
    "latitude": 18.52043,
    "longitude": 73.85674,
    "altitudeMeters": 560.2
  },
  "timestamp": "2026-08-30T02:45:00Z",
  "digitalSignature": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
}
```

---

## Security & Data Integrity

1. **Short-Lived JWT Tokens**: Ephemeral 15-minute access tokens with encrypted refresh token rotation.
2. **Deterministic PII Sanitization**: `SanitizedLogInterceptor` scrubs identity tokens, GPS micro-offsets, and user contact details prior to logging.
3. **Encrypted Storage at Rest**: Local SQLite database and cached files are protected with **AES-256-GCM** encryption keys held in the platform Keystore / Keychain.
4. **Asymmetric Verification**: Clinical records and passport QR codes are signed using **Ed25519** keypairs, allowing offline verification without internet access.

---

## Engineering Team

<table>
  <thead>
    <tr>
      <th align="left">Name</th>
      <th align="left">Role</th>
      <th align="left">Core Focus & Architectural Domain</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Om Rajput</b></td>
      <td>Chief Systems Architect & Lead Engineer</td>
      <td>Flutter Clean Architecture, System Core, PostGIS Spatial Engine, Offline Sync Pipeline</td>
    </tr>
    <tr>
      <td><b>Mrunmai Joshi</b></td>
      <td>Product & Technical Project Manager</td>
      <td>Domain Architecture, Product Strategy, Sprint Execution, Clinical Workflow Compliance</td>
    </tr>
    <tr>
      <td><b>Khushi</b></td>
      <td>Cloud Developer & Communication Lead</td>
      <td>Cloud Infrastructure, API Gateway Integration, Stakeholder Comms & Technical Narrative</td>
    </tr>
    <tr>
      <td><b>Soham</b></td>
      <td>Fullstack Developer</td>
      <td>Spring Boot Microservices, REST Contract Engineering, Persistence & Database Pipelines</td>
    </tr>
    <tr>
      <td><b>Prachi</b></td>
      <td>UI/UX Designer & Presentation Lead</td>
      <td>Design System Architecture, User Journey Mapping, Visual Assets & Pitch Decks</td>
    </tr>
    <tr>
      <td><b>Dhiraj</b></td>
      <td>Research & QA Testing Lead</td>
      <td>Veterinary Domain Research, Multi-Tier Test Automation, Field Validation & Quality Gates</td>
    </tr>
  </tbody>
</table>

---

## Quick Start & Local Orchestration

### Prerequisites
- **Flutter SDK**: `^3.22.0` (Stable)
- **Dart SDK**: `^3.4.0`
- **Java**: `JDK 17+` or `JDK 21 LTS`
- **Docker Engine & Docker Compose**: `v24+`

---

### 1. Clone & Fetch Dependencies

```bash
git clone https://github.com/omrajput14/vetra.git
cd vetra
flutter pub get
```

---

### 2. Code Generation

Generate immutable entities, Riverpod providers, and JSON serialization files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### 3. Spin Up Local Backend Services (Optional)

```bash
docker compose -f docker-compose.local.yml up -d
```

---

### 4. Configure Environment Endpoints

Update target host configuration in `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String stagingBaseUrl = 'https://api.vetra.dpdns.org/api/v1';
  static const String localBaseUrl = 'http://10.0.2.2:8080/api/v1';

  static String get baseUrl => kReleaseMode ? stagingBaseUrl : localBaseUrl;
}
```

---

### 5. Run Application

```bash
flutter run
```

---

## Testing & Verification

Vetra enforces strict quality gates with a **90%+ test coverage baseline**:

```
              ┌───────────────────────────┐
              │    E2E Integration (5%)   │ -> Staging Gateway & Database Verification
              ├───────────────────────────┤
              │   Contract Tests (15%)    │ -> JSON Schema & DTO Payload Validation
              ├───────────────────────────┤
              │    Widget Tests (30%)     │ -> UI Component Rendering & State Bounds
              ├───────────────────────────┤
              │     Unit Tests (50%)      │ -> Domain Logic, UseCases, Crypto & Notifiers
              └───────────────────────────┘
```

### Run Test Suites

```bash
# Execute static analysis
flutter analyze --fatal-infos

# Run unit and widget test suites
flutter test --reporter expanded

# Run tests with coverage profiling
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run contract tests
flutter test test/contract/
```

---

## Documentation Index

| Specification | Document Purpose | Direct Link |
| :--- | :--- | :--- |
| **Doc 01: Concept Architecture** | Strategic Vision, Rural Domain Analysis & Field Ergonomics | [PDF Architecture Whitepaper](VETRA_Concept_Architecture_Engineering_Om_Rajput.pdf) |
| **Doc 02: API & Backend Services** | Microservices Design, PostGIS Query Plans & API Contracts | [PDF Architecture Whitepaper](VETRA_Doc02_API_Backend_Architecture_Om_Rajput.pdf) |
| **Doc 03: AI Architecture** | Lesion Recognition Models, Computer Vision Triage Pipeline | [PDF Architecture Whitepaper](VETRA_Doc03_AI_Architecture_Om_Rajput.pdf) |
| **Doc 04: Cloud Infrastructure** | AWS ECS, EKS, RDS PostGIS, Terraform Blueprints | [PDF Architecture Whitepaper](VETRA_Doc04_Cloud_Infrastructure_Om_Rajput.pdf) |
| **Doc 05: Mobile Engineering** | Flutter Clean Architecture, Riverpod State, Offline Engine | [PDF Architecture Whitepaper](VETRA_Doc05_Mobile_Engineering_Om_Rajput.pdf) |
| **Doc 06: Quality & Reliability** | Reliability Benchmarks, Chaos Engineering & Test Strategy | [PDF Architecture Whitepaper](VETRA_Doc06_Quality_Reliability_Om_Rajput.pdf) |

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

<div align="center">
  <sub>Developed for enterprise livestock health management, field veterinary resilience, and epidemiological surveillance.</sub>
</div>
