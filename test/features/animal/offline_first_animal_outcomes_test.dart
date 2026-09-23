import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/database/vetra_database.dart';
import 'package:vetra/core/network/network_exceptions.dart';
import 'package:vetra/core/network/network_status_service.dart';
import 'package:vetra/features/animal/data/datasources/animal_local_datasource.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/data/repositories/animal_repository_impl.dart';
import 'package:vetra/features/animal/data/repositories/offline_first_animal_repository.dart';

/// Server double: each call either answers, rejects with an HTTP status, or never
/// reaches the server (no status = connectivity failure).
class FakeServer extends AnimalRepositoryImpl {
  int? rejectWith; // HTTP status to reject with
  bool unreachable = false;
  final List<String?> createKeys = [];
  int creates = 0, updates = 0, deletes = 0;

  void _outcome() {
    if (unreachable) throw NetworkException('Please check your internet connection.');
    if (rejectWith != null) throw NetworkException('Rejected by server', statusCode: rejectWith);
  }

  AnimalModel _model(String id, String tag, String? name) => AnimalModel(
        id: id,
        farmerId: 'f1',
        farmerName: 'Sunil Patil',
        animalName: name,
        tagNumber: tag,
        species: 'CATTLE',
        gender: 'FEMALE',
        createdAt: '2026-09-24T00:00:00Z',
        updatedAt: '2026-09-24T00:00:00Z',
      );

  @override
  Future<AnimalModel> createAnimal({
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
    String? localPhotoPath,
    String? idempotencyKey,
  }) async {
    createKeys.add(idempotencyKey);
    _outcome();
    creates++;
    return _model('server-$creates', tagNumber, animalName);
  }

  @override
  Future<AnimalModel> updateAnimal({
    required String id,
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
    String? localPhotoPath,
  }) async {
    _outcome();
    updates++;
    return _model(id, tagNumber, animalName);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    _outcome();
    deletes++;
  }

  @override
  Future<List<AnimalModel>> listAnimals() async => [];
}

class FakeNetwork implements NetworkStatusService {
  bool online = true;
  @override
  bool get isBackendReachable => online;
  @override
  Stream<bool> get onConnectivityRestored => const Stream.empty();
  @override
  Future<bool> checkNow() async => online;
  @override
  void initialize() {}
  @override
  void dispose() {}
}

void main() {
  late VetraDatabase db;
  late FakeServer server;
  late FakeNetwork network;
  late OfflineFirstAnimalRepository repo;

  Future<List<dynamic>> queued() async =>
      (await db.select(db.offlineOperationsTable).get()).where((o) => o.status == 'pending').toList();

  setUp(() {
    db = VetraDatabase.forTesting(NativeDatabase.memory());
    VetraDatabase.setTestInstance(db);
    server = FakeServer();
    network = FakeNetwork();
    repo = OfflineFirstAnimalRepository(remote: server, network: network);
  });

  tearDown(() async {
    await db.close();
    VetraDatabase.setTestInstance(null);
  });

  Future<AnimalModel> seedSyncedAnimal() async {
    final kapila = server._model('server-kapila', 'MH12-4521', 'Kapila');
    await AnimalLocalDatasource.instance.upsertAll([kapila]);
    return kapila;
  }

  group('Item 2: a server rejection is shown, never queued', () {
    test('create rejected (409) throws and queues nothing', () async {
      server.rejectWith = 409;
      await expectLater(
        repo.createAnimal(tagNumber: 'MH12-7788', species: 'CATTLE', gender: 'FEMALE', animalName: 'Ganga'),
        throwsA(isA<NetworkException>().having((e) => e.statusCode, 'status', 409)),
      );
      expect(await queued(), isEmpty);
      expect(await AnimalLocalDatasource.instance.getAll(), isEmpty);
    });

    test('update rejected (400) throws, queues nothing, keeps the server version', () async {
      await seedSyncedAnimal();
      server.rejectWith = 400;
      await expectLater(
        repo.updateAnimal(id: 'server-kapila', tagNumber: 'MH12-4521', species: 'CATTLE', gender: 'FEMALE', animalName: 'Kapila Rani'),
        throwsA(isA<NetworkException>()),
      );
      expect(await queued(), isEmpty);
      final local = await AnimalLocalDatasource.instance.getById('server-kapila');
      expect(local!.animalName, 'Kapila');
    });

    test('delete rejected (409) throws, queues nothing, keeps the animal', () async {
      await seedSyncedAnimal();
      server.rejectWith = 409;
      await expectLater(repo.deleteAnimal('server-kapila'), throwsA(isA<NetworkException>()));
      expect(await queued(), isEmpty);
      expect(await AnimalLocalDatasource.instance.getById('server-kapila'), isNotNull);
    });

    test('an unreachable server still queues (genuine connectivity failure)', () async {
      server.unreachable = true;
      final saved = await repo.createAnimal(tagNumber: 'MH12-7000', species: 'CATTLE', gender: 'FEMALE');
      expect(saved.isPendingSync, isTrue);
      expect(await queued(), hasLength(1));
    });
  });

  group('Item 5: online create carries the idempotency key its queued copy reuses', () {
    test('timed-out create and its queued replay share one key', () async {
      server.unreachable = true; // e.g. request timed out after the server may have committed
      await repo.createAnimal(tagNumber: 'MH12-9200', species: 'CATTLE', gender: 'FEMALE', animalName: 'Kaveri');
      final op = (await queued()).single;
      expect(server.createKeys.single, isNotNull, reason: 'online request must send Idempotency-Key');
      expect(op.idempotencyKey, server.createKeys.single, reason: 'queued replay must reuse the same key');
    });
  });

  group('Items 3 + 4: offline create, offline edit, offline photo', () {
    test('photo path travels with the queued create', () async {
      network.online = false;
      await repo.createAnimal(
        tagNumber: 'MH12-9100', species: 'CATTLE', gender: 'FEMALE', animalName: 'Tara',
        localPhotoPath: '/data/app_flutter/animal_photos/tara.jpg',
      );
      final payload = jsonDecode((await queued()).single.payloadJson) as Map<String, dynamic>;
      expect(payload['localPhotoPath'], '/data/app_flutter/animal_photos/tara.jpg');
    });

    test('editing a not-yet-synced animal queues against its pending create, not a fake server id', () async {
      network.online = false;
      final created = await repo.createAnimal(
        tagNumber: 'MH12-9100', species: 'CATTLE', gender: 'FEMALE', animalName: 'Tara',
        localPhotoPath: '/data/app_flutter/animal_photos/tara.jpg',
      );
      await repo.updateAnimal(
        id: created.id, tagNumber: 'MH12-9100', species: 'CATTLE', gender: 'FEMALE', animalName: 'Tara Devi',
        localPhotoPath: '/data/app_flutter/animal_photos/tara.jpg',
      );

      final ops = await queued();
      expect(ops, hasLength(2));
      final update = ops.firstWhere((o) => o.operationType == 'updateAnimal');
      final payload = jsonDecode(update.payloadJson) as Map<String, dynamic>;
      expect(payload['serverId'], isNull, reason: 'no server id exists yet');
      expect(update.dependsOn, created.id, reason: 'must wait for the create operation');

      final row = await db.animalDao.getByLocalId(created.id);
      expect(row!.serverId, isNull, reason: 'local id must not be written as a server id');
      expect(row.animalName, 'Tara Devi');
      expect(row.localPhotoPath, '/data/app_flutter/animal_photos/tara.jpg', reason: 'photo must survive the edit');
    });
  });
}
