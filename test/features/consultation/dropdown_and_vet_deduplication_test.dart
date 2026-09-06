import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('Bug 1 & 2 Regressions — Animal Dropdown & Vet Deduplication', () {
    test('AnimalModel equality compares by ID', () {
      final a1 = AnimalModel(
        id: 'animal-1',
        farmerId: 'farmer-1',
        farmerName: 'Ramesh',
        tagNumber: 'TAG-001',
        species: 'CATTLE',
        gender: 'FEMALE',
        createdAt: '2026-09-01',
        updatedAt: '2026-09-01',
      );

      final a2 = AnimalModel(
        id: 'animal-1',
        farmerId: 'farmer-1',
        farmerName: 'Ramesh',
        tagNumber: 'TAG-001',
        species: 'CATTLE',
        gender: 'FEMALE',
        createdAt: '2026-09-02',
        updatedAt: '2026-09-02',
      );

      final a3 = AnimalModel(
        id: 'animal-2',
        farmerId: 'farmer-1',
        farmerName: 'Ramesh',
        tagNumber: 'TAG-002',
        species: 'CATTLE',
        gender: 'FEMALE',
        createdAt: '2026-09-01',
        updatedAt: '2026-09-01',
      );

      expect(a1 == a2, isTrue);
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1 == a3, isFalse);
    });

    testWidgets('DropdownButtonFormField with AnimalModel renders cleanly and selects value', (tester) async {
      final a1 = AnimalModel(
        id: 'animal-1',
        farmerId: 'farmer-1',
        farmerName: 'Ramesh',
        animalName: 'Gauri',
        tagNumber: 'TAG-001',
        species: 'CATTLE',
        gender: 'FEMALE',
        createdAt: '2026-09-01',
        updatedAt: '2026-09-01',
      );

      final a2 = AnimalModel(
        id: 'animal-2',
        farmerId: 'farmer-1',
        farmerName: 'Ramesh',
        animalName: 'Nandini',
        tagNumber: 'TAG-002',
        species: 'CATTLE',
        gender: 'FEMALE',
        createdAt: '2026-09-01',
        updatedAt: '2026-09-01',
      );

      // Distinct list
      final animals = [a1, a2];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DropdownButtonFormField<AnimalModel>(
              initialValue: a1,
              items: animals.map((a) {
                return DropdownMenuItem<AnimalModel>(
                  value: a,
                  child: Text(a.displayName),
                );
              }).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Gauri'), findsOneWidget);
    });

    test('AuthNotifier _deduplicateVets consolidates duplicate vet accounts by identity', () {
      final rawVets = [
        {
          'id': 'uuid-1',
          'fullName': 'Dr. Ananya Roy',
          'clinicName': 'Roy Animal Hospital',
          'registrationNumber': 'VCI-REG-1001',
        },
        {
          'id': 'uuid-2',
          'fullName': 'Dr. Ananya Roy',
          'clinicName': 'Roy Animal Hospital',
          'registrationNumber': 'VCI-REG-1002',
        },
        {
          'id': 'uuid-3',
          'fullName': '[RETIRED-TEST] Staging Vet',
          'clinicName': 'Retired Clinic',
          'registrationNumber': 'VCI-REG-1003',
        },
        {
          'id': 'uuid-4',
          'fullName': 'Dr. Anjali Deshmukh',
          'clinicName': 'Baramati Veterinary Poly-Clinic',
          'registrationNumber': 'DEMO-VET-MH-2026',
        },
      ];

      // Access _deduplicateVets via dynamic reflection or testing the helper
      final deduped = authNotifier.deduplicateVets(rawVets);

      expect(deduped.length, equals(2));
      expect(deduped.any((v) => v['fullName'] == 'Dr. Ananya Roy'), isTrue);
      expect(deduped.any((v) => v['fullName'] == 'Dr. Anjali Deshmukh'), isTrue);
      expect(deduped.any((v) => v['fullName'].toString().contains('RETIRED')), isFalse);
    });
  });
}
