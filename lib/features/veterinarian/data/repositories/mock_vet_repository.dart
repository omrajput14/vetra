// ignore_for_file: deprecated_member_use_from_same_package
import 'package:vetra/core/models/veterinarian.dart';

/// Abstract interface retained for test scaffolding compatibility.
/// Do NOT use MockVetRepository in production code.
abstract class VetRepository {
  Future<List<Veterinarian>> getNearbyVets();
}

/// BUG 4 FIX: All hardcoded fake veterinarians removed.
/// Returns an empty list — production code uses authNotifier.fetchNearbyVets().
@Deprecated('Do not use in production — returns empty list intentionally.')
class MockVetRepository implements VetRepository {
  @override
  Future<List<Veterinarian>> getNearbyVets() async {
    // Intentionally empty — no hardcoded/fake vet data in production.
    return const [];
  }
}
