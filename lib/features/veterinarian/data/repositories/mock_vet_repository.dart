import 'package:vetra/core/models/veterinarian.dart';

abstract class VetRepository {
  Future<List<Veterinarian>> getNearbyVets();
}

class MockVetRepository implements VetRepository {
  @override
  Future<List<Veterinarian>> getNearbyVets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Veterinarian(id: 'V1', name: 'Dr. Rajesh Kumar', designation: 'Govt Vet Officer', distance: '2.5 km', rating: 4.9),
      Veterinarian(id: 'V2', name: 'Dr. Priya Sharma', designation: 'Surgeon', distance: '5.1 km', rating: 4.8),
    ];
  }
}
