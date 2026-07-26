import 'package:vetra/core/models/animal.dart';

abstract class AnimalRepository {
  Future<List<Animal>> getAnimals();
}

class MockAnimalRepository implements AnimalRepository {
  @override
  Future<List<Animal>> getAnimals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      Animal(id: '1', tagId: 'GIR-104', name: 'Gauri', species: 'Cattle', breed: 'Gir', status: 'Healthy'),
      Animal(id: '2', tagId: 'MUR-208', name: 'Lakshmi', species: 'Buffalo', breed: 'Murrah', status: 'Vaccination Due'),
    ];
  }
}
