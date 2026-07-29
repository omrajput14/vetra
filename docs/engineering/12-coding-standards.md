# Coding Standards & Conventions — Flutter / Dart
**Document ID:** ENG-12-FLUTTER  
**Status:** Active  
**Last Updated:** 2026-07-29  
**Applies To:** `omrajput14/vetra`  
**References:** [Engineering Principles](./00-principles.md), [Git Workflow](./13-git-workflow.md)

---

## Overview

This document defines the Dart and Flutter coding standards for the Vetra mobile application. All code submitted to this repository must comply with these standards. Compliance is verified by `flutter analyze`, which must return 0 errors and 0 warnings before any PR is merged.

---

## File & Directory Naming

- All files: `snake_case.dart` — `medical_record_page.dart`, `vet_card.dart`
- Directories: `snake_case/` — `medical_record/`, `design_system/`
- Test files: `<subject>_test.dart` — `medical_record_service_test.dart`

---

## Class Naming

| Type | Convention | Example |
|---|---|---|
| Page/Screen | `PascalCase + Page` | `MedicalRecordPage` |
| Widget (reusable) | `PascalCase` | `VetCard`, `AnimatedAppBar` |
| Model (data) | `PascalCase + Model` | `MedicalRecordModel` |
| Provider | camelCase + `Provider` | `medicalRecordProvider` |
| Repository | `PascalCase + Repository` | `MedicalRecordRepository` |
| API Service | `PascalCase + ApiService` | `MedicalRecordApiService` |
| Exception | `PascalCase + Exception` | `ApiException` |
| Enum | `PascalCase` | `AppointmentStatus` |
| Enum value | `camelCase` | `AppointmentStatus.pending` |
| Constant | `kCamelCase` | `kPrimaryColor`, `kDefaultPadding` |

---

## Feature Module Structure

Every feature follows **Clean Architecture** with three layers:

```
lib/features/<feature_name>/
├── data/
│   ├── models/           ← Data models (from API JSON)
│   ├── services/         ← API service classes (Dio HTTP calls)
│   └── repositories/     ← Repository implementations
├── domain/
│   └── repositories/     ← Abstract repository interfaces
└── presentation/
    ├── pages/            ← Full-screen pages/views
    ├── widgets/          ← Reusable widgets for this feature
    └── providers/        ← Riverpod providers
```

**Do not put business logic in widgets.** Widgets observe providers and render state — they do not call repositories directly.

---

## Riverpod Standards

### Provider Declaration

Providers are defined at the file level (not inside classes or functions):

```dart
// ✅ Correct
final medicalRecordProvider = StateNotifierProvider.autoDispose<
    MedicalRecordNotifier, MedicalRecordState>((ref) {
  return MedicalRecordNotifier(ref.read(medicalRecordRepositoryProvider));
});

// ❌ Incorrect — inside a class
class MyWidget extends ConsumerWidget {
  final provider = StateNotifierProvider<...>(...);  // Wrong
}
```

### Provider Naming

- `<feature>Provider` — `medicalRecordProvider`
- `<feature>RepositoryProvider` — `medicalRecordRepositoryProvider`
- `<feature>ServiceProvider` — `medicalRecordApiServiceProvider`

### State Management Pattern

Use `StateNotifier` + `freezed` state classes for complex state:

```dart
@freezed
class MedicalRecordState with _$MedicalRecordState {
  const factory MedicalRecordState.initial() = _Initial;
  const factory MedicalRecordState.loading() = _Loading;
  const factory MedicalRecordState.loaded(MedicalRecordModel record) = _Loaded;
  const factory MedicalRecordState.error(String code, String message) = _Error;
}
```

For simple async data, use `FutureProvider` or `AsyncNotifierProvider`.

---

## Widget Design Rules

### 1. Widget Decomposition

A widget that is longer than **100 lines** should be decomposed into smaller widgets. A widget that does more than one thing should be decomposed.

### 2. No Business Logic in Widgets

Widgets call provider methods. They do not call repositories, API services, or perform computations:

```dart
// ✅ Correct
ElevatedButton(
  onPressed: () => ref.read(appointmentProvider.notifier).confirmAppointment(id),
  child: const Text('Confirm'),
)

// ❌ Incorrect
ElevatedButton(
  onPressed: () async {
    await Dio().put('/api/v1/appointments/$id/status', data: {'status': 'CONFIRMED'});
    setState(() { /* ... */ });
  },
  child: const Text('Confirm'),
)
```

### 3. `const` Constructors

Use `const` constructors wherever possible. This enables Flutter to skip rebuilding static subtrees:

```dart
const Text('My Animals')        // ✅
const SizedBox(height: 16)      // ✅
const Padding(padding: EdgeInsets.all(16), child: MyWidget())  // ✅ if MyWidget is const
```

### 4. `ConsumerWidget` vs `StatelessWidget`

- Use `ConsumerWidget` only when the widget reads from Riverpod providers.
- Use `StatelessWidget` for pure UI widgets that receive all data via constructor parameters.
- Avoid `StatefulWidget` — prefer stateless + Riverpod for all state management.

---

## API Service Standards

API services use **Dio** with a shared instance configured via the `DioClient`:

```dart
class MedicalRecordApiService {
  final Dio _dio;

  MedicalRecordApiService(this._dio);

  Future<MedicalRecordModel> getMedicalRecord(String id) async {
    final response = await _dio.get('/api/v1/medical-records/$id');
    return MedicalRecordModel.fromJson(response.data as Map<String, dynamic>);
  }
}
```

- Never create a `Dio()` instance inside a method. Always inject via constructor.
- All HTTP errors are caught and converted to `ApiException` in the Dio interceptor.
- Never return `Response` objects from service methods — always return domain models.

---

## Error Handling

```dart
// In a Riverpod notifier:
Future<void> loadRecord(String id) async {
  state = const MedicalRecordState.loading();
  try {
    final record = await _repository.getMedicalRecord(id);
    state = MedicalRecordState.loaded(record);
  } on ApiException catch (e) {
    if (e.isSessionExpired) {
      // Trigger logout via auth provider
      ref.read(authProvider.notifier).logout();
      return;
    }
    state = MedicalRecordState.error(e.code, e.message);
  }
}
```

Error codes and their UI behavior are defined in the [Error Catalogue](../../vetra-backend/docs/api/23-error-catalogue.md).

---

## Code Review Checklist — Flutter

Before requesting review, verify:

- [ ] `flutter analyze` returns 0 errors, 0 warnings
- [ ] `flutter test` passes
- [ ] No `print()` statements in production code
- [ ] No `const` missing where it could be used
- [ ] Widgets are decomposed (< 100 lines each)
- [ ] No business logic in widget `build()` methods
- [ ] No direct Dio calls outside of API service classes
- [ ] All new features follow 3-layer feature module structure
- [ ] No generated files committed (`build/`, `.dart_tool/`, `*.iml`)
- [ ] New screen added to navigation graph in docs
