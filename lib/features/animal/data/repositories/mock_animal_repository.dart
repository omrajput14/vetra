// ignore_for_file: deprecated_member_use_from_same_package
import 'package:vetra/core/models/animal.dart';

/// Abstract interface retained for test scaffolding compatibility.
/// Do NOT use MockAnimalRepository in production code.
abstract class AnimalRepository {
  Future<List<Animal>> getAnimals();
}

/// BUG 4 FIX: All hardcoded fake animals removed.
/// Returns an empty list — production code uses OfflineFirstAnimalRepository.
@Deprecated('Do not use in production — returns empty list intentionally.')
class MockAnimalRepository implements AnimalRepository {
  @override
  Future<List<Animal>> getAnimals() async {
    // Intentionally empty — no fake/mock animals in production.
    return const [];
  }
}
