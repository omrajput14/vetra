import 'package:vetra/core/models/farmer.dart';

abstract class FarmerRepository {
  Future<Farmer> getFarmerProfile();
}

class MockFarmerRepository implements FarmerRepository {
  @override
  Future<Farmer> getFarmerProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Farmer(id: 'F101', name: 'Ramesh Patel', phone: '+91 98765 43210', location: 'Anand, Gujarat');
  }
}
