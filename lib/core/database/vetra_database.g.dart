// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vetra_database.dart';

// ignore_for_file: type=lint
class $AnimalsTableTable extends AnimalsTable
    with TableInfo<$AnimalsTableTable, AnimalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnimalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
      'local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _farmerIdMeta =
      const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
      'farmer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalNameMeta =
      const VerificationMeta('animalName');
  @override
  late final GeneratedColumn<String> animalName = GeneratedColumn<String>(
      'animal_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagNumberMeta =
      const VerificationMeta('tagNumber');
  @override
  late final GeneratedColumn<String> tagNumber = GeneratedColumn<String>(
      'tag_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qrCodeIdMeta =
      const VerificationMeta('qrCodeId');
  @override
  late final GeneratedColumn<String> qrCodeId = GeneratedColumn<String>(
      'qr_code_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPhotoPathMeta =
      const VerificationMeta('localPhotoPath');
  @override
  late final GeneratedColumn<String> localPhotoPath = GeneratedColumn<String>(
      'local_photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _serverVersionMeta =
      const VerificationMeta('serverVersion');
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
      'server_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverId,
        farmerId,
        animalName,
        tagNumber,
        qrCodeId,
        species,
        breed,
        gender,
        birthDate,
        photoUrl,
        localPhotoPath,
        syncStatus,
        createdAt,
        updatedAt,
        serverVersion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animals';
  @override
  VerificationContext validateIntegrity(Insertable<AnimalsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta,
          farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('animal_name')) {
      context.handle(
          _animalNameMeta,
          animalName.isAcceptableOrUnknown(
              data['animal_name']!, _animalNameMeta));
    }
    if (data.containsKey('tag_number')) {
      context.handle(_tagNumberMeta,
          tagNumber.isAcceptableOrUnknown(data['tag_number']!, _tagNumberMeta));
    } else if (isInserting) {
      context.missing(_tagNumberMeta);
    }
    if (data.containsKey('qr_code_id')) {
      context.handle(_qrCodeIdMeta,
          qrCodeId.isAcceptableOrUnknown(data['qr_code_id']!, _qrCodeIdMeta));
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('local_photo_path')) {
      context.handle(
          _localPhotoPathMeta,
          localPhotoPath.isAcceptableOrUnknown(
              data['local_photo_path']!, _localPhotoPathMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_version')) {
      context.handle(
          _serverVersionMeta,
          serverVersion.isAcceptableOrUnknown(
              data['server_version']!, _serverVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  AnimalsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnimalsTableData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      farmerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      animalName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_name']),
      tagNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_number'])!,
      qrCodeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}qr_code_id']),
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_date']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      localPhotoPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_photo_path']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      serverVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_version'])!,
    );
  }

  @override
  $AnimalsTableTable createAlias(String alias) {
    return $AnimalsTableTable(attachedDatabase, alias);
  }
}

class AnimalsTableData extends DataClass
    implements Insertable<AnimalsTableData> {
  /// Device-generated UUID — primary key; never changes.
  final String localId;

  /// Server-assigned UUID — null until this record is synced successfully.
  final String? serverId;

  /// UUID of the farmer who owns this animal (from auth token cache).
  final String farmerId;
  final String? animalName;
  final String tagNumber;
  final String? qrCodeId;
  final String species;
  final String? breed;
  final String gender;
  final String? birthDate;

  /// Remote photo URL (from server response).
  final String? photoUrl;

  /// Local file path for a photo captured/selected offline before upload.
  final String? localPhotoPath;

  /// Serialised sync status enum value.
  final String syncStatus;

  /// Unix milliseconds.
  final int createdAt;
  final int updatedAt;

  /// Used for optimistic concurrency — incremented by server on update.
  final int serverVersion;
  const AnimalsTableData(
      {required this.localId,
      this.serverId,
      required this.farmerId,
      this.animalName,
      required this.tagNumber,
      this.qrCodeId,
      required this.species,
      this.breed,
      required this.gender,
      this.birthDate,
      this.photoUrl,
      this.localPhotoPath,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt,
      required this.serverVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['farmer_id'] = Variable<String>(farmerId);
    if (!nullToAbsent || animalName != null) {
      map['animal_name'] = Variable<String>(animalName);
    }
    map['tag_number'] = Variable<String>(tagNumber);
    if (!nullToAbsent || qrCodeId != null) {
      map['qr_code_id'] = Variable<String>(qrCodeId);
    }
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || localPhotoPath != null) {
      map['local_photo_path'] = Variable<String>(localPhotoPath);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['server_version'] = Variable<int>(serverVersion);
    return map;
  }

  AnimalsTableCompanion toCompanion(bool nullToAbsent) {
    return AnimalsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      farmerId: Value(farmerId),
      animalName: animalName == null && nullToAbsent
          ? const Value.absent()
          : Value(animalName),
      tagNumber: Value(tagNumber),
      qrCodeId: qrCodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(qrCodeId),
      species: Value(species),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      gender: Value(gender),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      localPhotoPath: localPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPhotoPath),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverVersion: Value(serverVersion),
    );
  }

  factory AnimalsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnimalsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      animalName: serializer.fromJson<String?>(json['animalName']),
      tagNumber: serializer.fromJson<String>(json['tagNumber']),
      qrCodeId: serializer.fromJson<String?>(json['qrCodeId']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String?>(json['breed']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<String?>(json['birthDate']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      localPhotoPath: serializer.fromJson<String?>(json['localPhotoPath']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'farmerId': serializer.toJson<String>(farmerId),
      'animalName': serializer.toJson<String?>(animalName),
      'tagNumber': serializer.toJson<String>(tagNumber),
      'qrCodeId': serializer.toJson<String?>(qrCodeId),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String?>(breed),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<String?>(birthDate),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'localPhotoPath': serializer.toJson<String?>(localPhotoPath),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverVersion': serializer.toJson<int>(serverVersion),
    };
  }

  AnimalsTableData copyWith(
          {String? localId,
          Value<String?> serverId = const Value.absent(),
          String? farmerId,
          Value<String?> animalName = const Value.absent(),
          String? tagNumber,
          Value<String?> qrCodeId = const Value.absent(),
          String? species,
          Value<String?> breed = const Value.absent(),
          String? gender,
          Value<String?> birthDate = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<String?> localPhotoPath = const Value.absent(),
          String? syncStatus,
          int? createdAt,
          int? updatedAt,
          int? serverVersion}) =>
      AnimalsTableData(
        localId: localId ?? this.localId,
        serverId: serverId.present ? serverId.value : this.serverId,
        farmerId: farmerId ?? this.farmerId,
        animalName: animalName.present ? animalName.value : this.animalName,
        tagNumber: tagNumber ?? this.tagNumber,
        qrCodeId: qrCodeId.present ? qrCodeId.value : this.qrCodeId,
        species: species ?? this.species,
        breed: breed.present ? breed.value : this.breed,
        gender: gender ?? this.gender,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        localPhotoPath:
            localPhotoPath.present ? localPhotoPath.value : this.localPhotoPath,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        serverVersion: serverVersion ?? this.serverVersion,
      );
  AnimalsTableData copyWithCompanion(AnimalsTableCompanion data) {
    return AnimalsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      animalName:
          data.animalName.present ? data.animalName.value : this.animalName,
      tagNumber: data.tagNumber.present ? data.tagNumber.value : this.tagNumber,
      qrCodeId: data.qrCodeId.present ? data.qrCodeId.value : this.qrCodeId,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      localPhotoPath: data.localPhotoPath.present
          ? data.localPhotoPath.value
          : this.localPhotoPath,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('farmerId: $farmerId, ')
          ..write('animalName: $animalName, ')
          ..write('tagNumber: $tagNumber, ')
          ..write('qrCodeId: $qrCodeId, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverVersion: $serverVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      serverId,
      farmerId,
      animalName,
      tagNumber,
      qrCodeId,
      species,
      breed,
      gender,
      birthDate,
      photoUrl,
      localPhotoPath,
      syncStatus,
      createdAt,
      updatedAt,
      serverVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnimalsTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.farmerId == this.farmerId &&
          other.animalName == this.animalName &&
          other.tagNumber == this.tagNumber &&
          other.qrCodeId == this.qrCodeId &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.photoUrl == this.photoUrl &&
          other.localPhotoPath == this.localPhotoPath &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverVersion == this.serverVersion);
}

class AnimalsTableCompanion extends UpdateCompanion<AnimalsTableData> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> farmerId;
  final Value<String?> animalName;
  final Value<String> tagNumber;
  final Value<String?> qrCodeId;
  final Value<String> species;
  final Value<String?> breed;
  final Value<String> gender;
  final Value<String?> birthDate;
  final Value<String?> photoUrl;
  final Value<String?> localPhotoPath;
  final Value<String> syncStatus;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> serverVersion;
  final Value<int> rowid;
  const AnimalsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.animalName = const Value.absent(),
    this.tagNumber = const Value.absent(),
    this.qrCodeId = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnimalsTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String farmerId,
    this.animalName = const Value.absent(),
    required String tagNumber,
    this.qrCodeId = const Value.absent(),
    required String species,
    this.breed = const Value.absent(),
    required String gender,
    this.birthDate = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.serverVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : localId = Value(localId),
        farmerId = Value(farmerId),
        tagNumber = Value(tagNumber),
        species = Value(species),
        gender = Value(gender),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AnimalsTableData> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? farmerId,
    Expression<String>? animalName,
    Expression<String>? tagNumber,
    Expression<String>? qrCodeId,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? gender,
    Expression<String>? birthDate,
    Expression<String>? photoUrl,
    Expression<String>? localPhotoPath,
    Expression<String>? syncStatus,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? serverVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (animalName != null) 'animal_name': animalName,
      if (tagNumber != null) 'tag_number': tagNumber,
      if (qrCodeId != null) 'qr_code_id': qrCodeId,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (localPhotoPath != null) 'local_photo_path': localPhotoPath,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverVersion != null) 'server_version': serverVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnimalsTableCompanion copyWith(
      {Value<String>? localId,
      Value<String?>? serverId,
      Value<String>? farmerId,
      Value<String?>? animalName,
      Value<String>? tagNumber,
      Value<String?>? qrCodeId,
      Value<String>? species,
      Value<String?>? breed,
      Value<String>? gender,
      Value<String?>? birthDate,
      Value<String?>? photoUrl,
      Value<String?>? localPhotoPath,
      Value<String>? syncStatus,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? serverVersion,
      Value<int>? rowid}) {
    return AnimalsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      farmerId: farmerId ?? this.farmerId,
      animalName: animalName ?? this.animalName,
      tagNumber: tagNumber ?? this.tagNumber,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverVersion: serverVersion ?? this.serverVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (animalName.present) {
      map['animal_name'] = Variable<String>(animalName.value);
    }
    if (tagNumber.present) {
      map['tag_number'] = Variable<String>(tagNumber.value);
    }
    if (qrCodeId.present) {
      map['qr_code_id'] = Variable<String>(qrCodeId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (localPhotoPath.present) {
      map['local_photo_path'] = Variable<String>(localPhotoPath.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnimalsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('farmerId: $farmerId, ')
          ..write('animalName: $animalName, ')
          ..write('tagNumber: $tagNumber, ')
          ..write('qrCodeId: $qrCodeId, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiseaseReportsTableTable extends DiseaseReportsTable
    with TableInfo<$DiseaseReportsTableTable, DiseaseReportsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiseaseReportsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
      'local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalLocalIdMeta =
      const VerificationMeta('animalLocalId');
  @override
  late final GeneratedColumn<String> animalLocalId = GeneratedColumn<String>(
      'animal_local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalServerIdMeta =
      const VerificationMeta('animalServerId');
  @override
  late final GeneratedColumn<String> animalServerId = GeneratedColumn<String>(
      'animal_server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _diseaseNameMeta =
      const VerificationMeta('diseaseName');
  @override
  late final GeneratedColumn<String> diseaseName = GeneratedColumn<String>(
      'disease_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _diagnosisStatusMeta =
      const VerificationMeta('diagnosisStatus');
  @override
  late final GeneratedColumn<String> diagnosisStatus = GeneratedColumn<String>(
      'diagnosis_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('SUSPECTED'));
  static const VerificationMeta _reportSourceMeta =
      const VerificationMeta('reportSource');
  @override
  late final GeneratedColumn<String> reportSource = GeneratedColumn<String>(
      'report_source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('MANUAL'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gpsAccuracyMeta =
      const VerificationMeta('gpsAccuracy');
  @override
  late final GeneratedColumn<double> gpsAccuracy = GeneratedColumn<double>(
      'gps_accuracy', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _gpsQualityMeta =
      const VerificationMeta('gpsQuality');
  @override
  late final GeneratedColumn<String> gpsQuality = GeneratedColumn<String>(
      'gps_quality', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ACCURATE'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiScanLocalIdMeta =
      const VerificationMeta('aiScanLocalId');
  @override
  late final GeneratedColumn<String> aiScanLocalId = GeneratedColumn<String>(
      'ai_scan_local_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiScanServerIdMeta =
      const VerificationMeta('aiScanServerId');
  @override
  late final GeneratedColumn<String> aiScanServerId = GeneratedColumn<String>(
      'ai_scan_server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverId,
        animalLocalId,
        animalServerId,
        diseaseName,
        diagnosisStatus,
        reportSource,
        latitude,
        longitude,
        gpsAccuracy,
        gpsQuality,
        notes,
        aiScanLocalId,
        aiScanServerId,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_disease_reports';
  @override
  VerificationContext validateIntegrity(
      Insertable<DiseaseReportsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('animal_local_id')) {
      context.handle(
          _animalLocalIdMeta,
          animalLocalId.isAcceptableOrUnknown(
              data['animal_local_id']!, _animalLocalIdMeta));
    } else if (isInserting) {
      context.missing(_animalLocalIdMeta);
    }
    if (data.containsKey('animal_server_id')) {
      context.handle(
          _animalServerIdMeta,
          animalServerId.isAcceptableOrUnknown(
              data['animal_server_id']!, _animalServerIdMeta));
    }
    if (data.containsKey('disease_name')) {
      context.handle(
          _diseaseNameMeta,
          diseaseName.isAcceptableOrUnknown(
              data['disease_name']!, _diseaseNameMeta));
    } else if (isInserting) {
      context.missing(_diseaseNameMeta);
    }
    if (data.containsKey('diagnosis_status')) {
      context.handle(
          _diagnosisStatusMeta,
          diagnosisStatus.isAcceptableOrUnknown(
              data['diagnosis_status']!, _diagnosisStatusMeta));
    }
    if (data.containsKey('report_source')) {
      context.handle(
          _reportSourceMeta,
          reportSource.isAcceptableOrUnknown(
              data['report_source']!, _reportSourceMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('gps_accuracy')) {
      context.handle(
          _gpsAccuracyMeta,
          gpsAccuracy.isAcceptableOrUnknown(
              data['gps_accuracy']!, _gpsAccuracyMeta));
    }
    if (data.containsKey('gps_quality')) {
      context.handle(
          _gpsQualityMeta,
          gpsQuality.isAcceptableOrUnknown(
              data['gps_quality']!, _gpsQualityMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('ai_scan_local_id')) {
      context.handle(
          _aiScanLocalIdMeta,
          aiScanLocalId.isAcceptableOrUnknown(
              data['ai_scan_local_id']!, _aiScanLocalIdMeta));
    }
    if (data.containsKey('ai_scan_server_id')) {
      context.handle(
          _aiScanServerIdMeta,
          aiScanServerId.isAcceptableOrUnknown(
              data['ai_scan_server_id']!, _aiScanServerIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  DiseaseReportsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiseaseReportsTableData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      animalLocalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}animal_local_id'])!,
      animalServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}animal_server_id']),
      diseaseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}disease_name'])!,
      diagnosisStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}diagnosis_status'])!,
      reportSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}report_source'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      gpsAccuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_accuracy']),
      gpsQuality: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gps_quality'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      aiScanLocalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ai_scan_local_id']),
      aiScanServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ai_scan_server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DiseaseReportsTableTable createAlias(String alias) {
    return $DiseaseReportsTableTable(attachedDatabase, alias);
  }
}

class DiseaseReportsTableData extends DataClass
    implements Insertable<DiseaseReportsTableData> {
  final String localId;
  final String? serverId;

  /// FK to local_animals.localId
  final String animalLocalId;

  /// Populated once the animal has been synced and has a real server UUID.
  final String? animalServerId;
  final String diseaseName;
  final String diagnosisStatus;
  final String reportSource;
  final double latitude;
  final double longitude;

  /// GPS accuracy in metres (from Geolocator).
  final double? gpsAccuracy;

  /// ACCURATE | APPROXIMATE | UNAVAILABLE | USER_SELECTED
  final String gpsQuality;
  final String? notes;

  /// FK to local_ai_scans.localId if this report is linked to a scan.
  final String? aiScanLocalId;
  final String? aiScanServerId;
  final String syncStatus;
  final int createdAt;
  final int updatedAt;
  const DiseaseReportsTableData(
      {required this.localId,
      this.serverId,
      required this.animalLocalId,
      this.animalServerId,
      required this.diseaseName,
      required this.diagnosisStatus,
      required this.reportSource,
      required this.latitude,
      required this.longitude,
      this.gpsAccuracy,
      required this.gpsQuality,
      this.notes,
      this.aiScanLocalId,
      this.aiScanServerId,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['animal_local_id'] = Variable<String>(animalLocalId);
    if (!nullToAbsent || animalServerId != null) {
      map['animal_server_id'] = Variable<String>(animalServerId);
    }
    map['disease_name'] = Variable<String>(diseaseName);
    map['diagnosis_status'] = Variable<String>(diagnosisStatus);
    map['report_source'] = Variable<String>(reportSource);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || gpsAccuracy != null) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy);
    }
    map['gps_quality'] = Variable<String>(gpsQuality);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || aiScanLocalId != null) {
      map['ai_scan_local_id'] = Variable<String>(aiScanLocalId);
    }
    if (!nullToAbsent || aiScanServerId != null) {
      map['ai_scan_server_id'] = Variable<String>(aiScanServerId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DiseaseReportsTableCompanion toCompanion(bool nullToAbsent) {
    return DiseaseReportsTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      animalLocalId: Value(animalLocalId),
      animalServerId: animalServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalServerId),
      diseaseName: Value(diseaseName),
      diagnosisStatus: Value(diagnosisStatus),
      reportSource: Value(reportSource),
      latitude: Value(latitude),
      longitude: Value(longitude),
      gpsAccuracy: gpsAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsAccuracy),
      gpsQuality: Value(gpsQuality),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      aiScanLocalId: aiScanLocalId == null && nullToAbsent
          ? const Value.absent()
          : Value(aiScanLocalId),
      aiScanServerId: aiScanServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(aiScanServerId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiseaseReportsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiseaseReportsTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      animalLocalId: serializer.fromJson<String>(json['animalLocalId']),
      animalServerId: serializer.fromJson<String?>(json['animalServerId']),
      diseaseName: serializer.fromJson<String>(json['diseaseName']),
      diagnosisStatus: serializer.fromJson<String>(json['diagnosisStatus']),
      reportSource: serializer.fromJson<String>(json['reportSource']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      gpsAccuracy: serializer.fromJson<double?>(json['gpsAccuracy']),
      gpsQuality: serializer.fromJson<String>(json['gpsQuality']),
      notes: serializer.fromJson<String?>(json['notes']),
      aiScanLocalId: serializer.fromJson<String?>(json['aiScanLocalId']),
      aiScanServerId: serializer.fromJson<String?>(json['aiScanServerId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'animalLocalId': serializer.toJson<String>(animalLocalId),
      'animalServerId': serializer.toJson<String?>(animalServerId),
      'diseaseName': serializer.toJson<String>(diseaseName),
      'diagnosisStatus': serializer.toJson<String>(diagnosisStatus),
      'reportSource': serializer.toJson<String>(reportSource),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'gpsAccuracy': serializer.toJson<double?>(gpsAccuracy),
      'gpsQuality': serializer.toJson<String>(gpsQuality),
      'notes': serializer.toJson<String?>(notes),
      'aiScanLocalId': serializer.toJson<String?>(aiScanLocalId),
      'aiScanServerId': serializer.toJson<String?>(aiScanServerId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DiseaseReportsTableData copyWith(
          {String? localId,
          Value<String?> serverId = const Value.absent(),
          String? animalLocalId,
          Value<String?> animalServerId = const Value.absent(),
          String? diseaseName,
          String? diagnosisStatus,
          String? reportSource,
          double? latitude,
          double? longitude,
          Value<double?> gpsAccuracy = const Value.absent(),
          String? gpsQuality,
          Value<String?> notes = const Value.absent(),
          Value<String?> aiScanLocalId = const Value.absent(),
          Value<String?> aiScanServerId = const Value.absent(),
          String? syncStatus,
          int? createdAt,
          int? updatedAt}) =>
      DiseaseReportsTableData(
        localId: localId ?? this.localId,
        serverId: serverId.present ? serverId.value : this.serverId,
        animalLocalId: animalLocalId ?? this.animalLocalId,
        animalServerId:
            animalServerId.present ? animalServerId.value : this.animalServerId,
        diseaseName: diseaseName ?? this.diseaseName,
        diagnosisStatus: diagnosisStatus ?? this.diagnosisStatus,
        reportSource: reportSource ?? this.reportSource,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        gpsAccuracy: gpsAccuracy.present ? gpsAccuracy.value : this.gpsAccuracy,
        gpsQuality: gpsQuality ?? this.gpsQuality,
        notes: notes.present ? notes.value : this.notes,
        aiScanLocalId:
            aiScanLocalId.present ? aiScanLocalId.value : this.aiScanLocalId,
        aiScanServerId:
            aiScanServerId.present ? aiScanServerId.value : this.aiScanServerId,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DiseaseReportsTableData copyWithCompanion(DiseaseReportsTableCompanion data) {
    return DiseaseReportsTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      animalLocalId: data.animalLocalId.present
          ? data.animalLocalId.value
          : this.animalLocalId,
      animalServerId: data.animalServerId.present
          ? data.animalServerId.value
          : this.animalServerId,
      diseaseName:
          data.diseaseName.present ? data.diseaseName.value : this.diseaseName,
      diagnosisStatus: data.diagnosisStatus.present
          ? data.diagnosisStatus.value
          : this.diagnosisStatus,
      reportSource: data.reportSource.present
          ? data.reportSource.value
          : this.reportSource,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      gpsAccuracy:
          data.gpsAccuracy.present ? data.gpsAccuracy.value : this.gpsAccuracy,
      gpsQuality:
          data.gpsQuality.present ? data.gpsQuality.value : this.gpsQuality,
      notes: data.notes.present ? data.notes.value : this.notes,
      aiScanLocalId: data.aiScanLocalId.present
          ? data.aiScanLocalId.value
          : this.aiScanLocalId,
      aiScanServerId: data.aiScanServerId.present
          ? data.aiScanServerId.value
          : this.aiScanServerId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiseaseReportsTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('animalLocalId: $animalLocalId, ')
          ..write('animalServerId: $animalServerId, ')
          ..write('diseaseName: $diseaseName, ')
          ..write('diagnosisStatus: $diagnosisStatus, ')
          ..write('reportSource: $reportSource, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('gpsQuality: $gpsQuality, ')
          ..write('notes: $notes, ')
          ..write('aiScanLocalId: $aiScanLocalId, ')
          ..write('aiScanServerId: $aiScanServerId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      serverId,
      animalLocalId,
      animalServerId,
      diseaseName,
      diagnosisStatus,
      reportSource,
      latitude,
      longitude,
      gpsAccuracy,
      gpsQuality,
      notes,
      aiScanLocalId,
      aiScanServerId,
      syncStatus,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiseaseReportsTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.animalLocalId == this.animalLocalId &&
          other.animalServerId == this.animalServerId &&
          other.diseaseName == this.diseaseName &&
          other.diagnosisStatus == this.diagnosisStatus &&
          other.reportSource == this.reportSource &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.gpsAccuracy == this.gpsAccuracy &&
          other.gpsQuality == this.gpsQuality &&
          other.notes == this.notes &&
          other.aiScanLocalId == this.aiScanLocalId &&
          other.aiScanServerId == this.aiScanServerId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DiseaseReportsTableCompanion
    extends UpdateCompanion<DiseaseReportsTableData> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> animalLocalId;
  final Value<String?> animalServerId;
  final Value<String> diseaseName;
  final Value<String> diagnosisStatus;
  final Value<String> reportSource;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> gpsAccuracy;
  final Value<String> gpsQuality;
  final Value<String?> notes;
  final Value<String?> aiScanLocalId;
  final Value<String?> aiScanServerId;
  final Value<String> syncStatus;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DiseaseReportsTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.animalLocalId = const Value.absent(),
    this.animalServerId = const Value.absent(),
    this.diseaseName = const Value.absent(),
    this.diagnosisStatus = const Value.absent(),
    this.reportSource = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gpsAccuracy = const Value.absent(),
    this.gpsQuality = const Value.absent(),
    this.notes = const Value.absent(),
    this.aiScanLocalId = const Value.absent(),
    this.aiScanServerId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiseaseReportsTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String animalLocalId,
    this.animalServerId = const Value.absent(),
    required String diseaseName,
    this.diagnosisStatus = const Value.absent(),
    this.reportSource = const Value.absent(),
    required double latitude,
    required double longitude,
    this.gpsAccuracy = const Value.absent(),
    this.gpsQuality = const Value.absent(),
    this.notes = const Value.absent(),
    this.aiScanLocalId = const Value.absent(),
    this.aiScanServerId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : localId = Value(localId),
        animalLocalId = Value(animalLocalId),
        diseaseName = Value(diseaseName),
        latitude = Value(latitude),
        longitude = Value(longitude),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DiseaseReportsTableData> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? animalLocalId,
    Expression<String>? animalServerId,
    Expression<String>? diseaseName,
    Expression<String>? diagnosisStatus,
    Expression<String>? reportSource,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? gpsAccuracy,
    Expression<String>? gpsQuality,
    Expression<String>? notes,
    Expression<String>? aiScanLocalId,
    Expression<String>? aiScanServerId,
    Expression<String>? syncStatus,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (animalLocalId != null) 'animal_local_id': animalLocalId,
      if (animalServerId != null) 'animal_server_id': animalServerId,
      if (diseaseName != null) 'disease_name': diseaseName,
      if (diagnosisStatus != null) 'diagnosis_status': diagnosisStatus,
      if (reportSource != null) 'report_source': reportSource,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gpsAccuracy != null) 'gps_accuracy': gpsAccuracy,
      if (gpsQuality != null) 'gps_quality': gpsQuality,
      if (notes != null) 'notes': notes,
      if (aiScanLocalId != null) 'ai_scan_local_id': aiScanLocalId,
      if (aiScanServerId != null) 'ai_scan_server_id': aiScanServerId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiseaseReportsTableCompanion copyWith(
      {Value<String>? localId,
      Value<String?>? serverId,
      Value<String>? animalLocalId,
      Value<String?>? animalServerId,
      Value<String>? diseaseName,
      Value<String>? diagnosisStatus,
      Value<String>? reportSource,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double?>? gpsAccuracy,
      Value<String>? gpsQuality,
      Value<String?>? notes,
      Value<String?>? aiScanLocalId,
      Value<String?>? aiScanServerId,
      Value<String>? syncStatus,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return DiseaseReportsTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      animalLocalId: animalLocalId ?? this.animalLocalId,
      animalServerId: animalServerId ?? this.animalServerId,
      diseaseName: diseaseName ?? this.diseaseName,
      diagnosisStatus: diagnosisStatus ?? this.diagnosisStatus,
      reportSource: reportSource ?? this.reportSource,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      gpsQuality: gpsQuality ?? this.gpsQuality,
      notes: notes ?? this.notes,
      aiScanLocalId: aiScanLocalId ?? this.aiScanLocalId,
      aiScanServerId: aiScanServerId ?? this.aiScanServerId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (animalLocalId.present) {
      map['animal_local_id'] = Variable<String>(animalLocalId.value);
    }
    if (animalServerId.present) {
      map['animal_server_id'] = Variable<String>(animalServerId.value);
    }
    if (diseaseName.present) {
      map['disease_name'] = Variable<String>(diseaseName.value);
    }
    if (diagnosisStatus.present) {
      map['diagnosis_status'] = Variable<String>(diagnosisStatus.value);
    }
    if (reportSource.present) {
      map['report_source'] = Variable<String>(reportSource.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (gpsAccuracy.present) {
      map['gps_accuracy'] = Variable<double>(gpsAccuracy.value);
    }
    if (gpsQuality.present) {
      map['gps_quality'] = Variable<String>(gpsQuality.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (aiScanLocalId.present) {
      map['ai_scan_local_id'] = Variable<String>(aiScanLocalId.value);
    }
    if (aiScanServerId.present) {
      map['ai_scan_server_id'] = Variable<String>(aiScanServerId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiseaseReportsTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('animalLocalId: $animalLocalId, ')
          ..write('animalServerId: $animalServerId, ')
          ..write('diseaseName: $diseaseName, ')
          ..write('diagnosisStatus: $diagnosisStatus, ')
          ..write('reportSource: $reportSource, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gpsAccuracy: $gpsAccuracy, ')
          ..write('gpsQuality: $gpsQuality, ')
          ..write('notes: $notes, ')
          ..write('aiScanLocalId: $aiScanLocalId, ')
          ..write('aiScanServerId: $aiScanServerId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiScansTableTable extends AiScansTable
    with TableInfo<$AiScansTableTable, AiScansTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiScansTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
      'local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _animalLocalIdMeta =
      const VerificationMeta('animalLocalId');
  @override
  late final GeneratedColumn<String> animalLocalId = GeneratedColumn<String>(
      'animal_local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalServerIdMeta =
      const VerificationMeta('animalServerId');
  @override
  late final GeneratedColumn<String> animalServerId = GeneratedColumn<String>(
      'animal_server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localImagePathMeta =
      const VerificationMeta('localImagePath');
  @override
  late final GeneratedColumn<String> localImagePath = GeneratedColumn<String>(
      'local_image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING_UPLOAD'));
  static const VerificationMeta _diagnosisMeta =
      const VerificationMeta('diagnosis');
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
      'diagnosis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceScoreMeta =
      const VerificationMeta('confidenceScore');
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
      'confidence_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _observationsJsonMeta =
      const VerificationMeta('observationsJson');
  @override
  late final GeneratedColumn<String> observationsJson = GeneratedColumn<String>(
      'observations_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rawResultJsonMeta =
      const VerificationMeta('rawResultJson');
  @override
  late final GeneratedColumn<String> rawResultJson = GeneratedColumn<String>(
      'raw_result_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('localOnly'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverId,
        animalLocalId,
        animalServerId,
        localImagePath,
        status,
        diagnosis,
        confidenceScore,
        severity,
        observationsJson,
        rawResultJson,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_ai_scans';
  @override
  VerificationContext validateIntegrity(Insertable<AiScansTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('animal_local_id')) {
      context.handle(
          _animalLocalIdMeta,
          animalLocalId.isAcceptableOrUnknown(
              data['animal_local_id']!, _animalLocalIdMeta));
    } else if (isInserting) {
      context.missing(_animalLocalIdMeta);
    }
    if (data.containsKey('animal_server_id')) {
      context.handle(
          _animalServerIdMeta,
          animalServerId.isAcceptableOrUnknown(
              data['animal_server_id']!, _animalServerIdMeta));
    }
    if (data.containsKey('local_image_path')) {
      context.handle(
          _localImagePathMeta,
          localImagePath.isAcceptableOrUnknown(
              data['local_image_path']!, _localImagePathMeta));
    } else if (isInserting) {
      context.missing(_localImagePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('diagnosis')) {
      context.handle(_diagnosisMeta,
          diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta));
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
          _confidenceScoreMeta,
          confidenceScore.isAcceptableOrUnknown(
              data['confidence_score']!, _confidenceScoreMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    }
    if (data.containsKey('observations_json')) {
      context.handle(
          _observationsJsonMeta,
          observationsJson.isAcceptableOrUnknown(
              data['observations_json']!, _observationsJsonMeta));
    }
    if (data.containsKey('raw_result_json')) {
      context.handle(
          _rawResultJsonMeta,
          rawResultJson.isAcceptableOrUnknown(
              data['raw_result_json']!, _rawResultJsonMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  AiScansTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiScansTableData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      animalLocalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}animal_local_id'])!,
      animalServerId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}animal_server_id']),
      localImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_image_path'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      diagnosis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnosis']),
      confidenceScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}confidence_score']),
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity']),
      observationsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}observations_json']),
      rawResultJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_result_json']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AiScansTableTable createAlias(String alias) {
    return $AiScansTableTable(attachedDatabase, alias);
  }
}

class AiScansTableData extends DataClass
    implements Insertable<AiScansTableData> {
  final String localId;
  final String? serverId;
  final String animalLocalId;
  final String? animalServerId;

  /// Permanent file path inside app documents directory.
  /// Format: <appDocumentsDir>/vetra/scans/<localId>.jpg
  final String localImagePath;

  /// PENDING_UPLOAD | UPLOADING | PENDING_ANALYSIS | COMPLETED | FAILED
  final String status;
  final String? diagnosis;
  final double? confidenceScore;
  final String? severity;

  /// JSON array of observation strings stored as text.
  final String? observationsJson;

  /// Full raw API response JSON for debugging.
  final String? rawResultJson;
  final String syncStatus;
  final int createdAt;
  final int updatedAt;
  const AiScansTableData(
      {required this.localId,
      this.serverId,
      required this.animalLocalId,
      this.animalServerId,
      required this.localImagePath,
      required this.status,
      this.diagnosis,
      this.confidenceScore,
      this.severity,
      this.observationsJson,
      this.rawResultJson,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['animal_local_id'] = Variable<String>(animalLocalId);
    if (!nullToAbsent || animalServerId != null) {
      map['animal_server_id'] = Variable<String>(animalServerId);
    }
    map['local_image_path'] = Variable<String>(localImagePath);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || diagnosis != null) {
      map['diagnosis'] = Variable<String>(diagnosis);
    }
    if (!nullToAbsent || confidenceScore != null) {
      map['confidence_score'] = Variable<double>(confidenceScore);
    }
    if (!nullToAbsent || severity != null) {
      map['severity'] = Variable<String>(severity);
    }
    if (!nullToAbsent || observationsJson != null) {
      map['observations_json'] = Variable<String>(observationsJson);
    }
    if (!nullToAbsent || rawResultJson != null) {
      map['raw_result_json'] = Variable<String>(rawResultJson);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AiScansTableCompanion toCompanion(bool nullToAbsent) {
    return AiScansTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      animalLocalId: Value(animalLocalId),
      animalServerId: animalServerId == null && nullToAbsent
          ? const Value.absent()
          : Value(animalServerId),
      localImagePath: Value(localImagePath),
      status: Value(status),
      diagnosis: diagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosis),
      confidenceScore: confidenceScore == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceScore),
      severity: severity == null && nullToAbsent
          ? const Value.absent()
          : Value(severity),
      observationsJson: observationsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(observationsJson),
      rawResultJson: rawResultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rawResultJson),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiScansTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiScansTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      animalLocalId: serializer.fromJson<String>(json['animalLocalId']),
      animalServerId: serializer.fromJson<String?>(json['animalServerId']),
      localImagePath: serializer.fromJson<String>(json['localImagePath']),
      status: serializer.fromJson<String>(json['status']),
      diagnosis: serializer.fromJson<String?>(json['diagnosis']),
      confidenceScore: serializer.fromJson<double?>(json['confidenceScore']),
      severity: serializer.fromJson<String?>(json['severity']),
      observationsJson: serializer.fromJson<String?>(json['observationsJson']),
      rawResultJson: serializer.fromJson<String?>(json['rawResultJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'animalLocalId': serializer.toJson<String>(animalLocalId),
      'animalServerId': serializer.toJson<String?>(animalServerId),
      'localImagePath': serializer.toJson<String>(localImagePath),
      'status': serializer.toJson<String>(status),
      'diagnosis': serializer.toJson<String?>(diagnosis),
      'confidenceScore': serializer.toJson<double?>(confidenceScore),
      'severity': serializer.toJson<String?>(severity),
      'observationsJson': serializer.toJson<String?>(observationsJson),
      'rawResultJson': serializer.toJson<String?>(rawResultJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AiScansTableData copyWith(
          {String? localId,
          Value<String?> serverId = const Value.absent(),
          String? animalLocalId,
          Value<String?> animalServerId = const Value.absent(),
          String? localImagePath,
          String? status,
          Value<String?> diagnosis = const Value.absent(),
          Value<double?> confidenceScore = const Value.absent(),
          Value<String?> severity = const Value.absent(),
          Value<String?> observationsJson = const Value.absent(),
          Value<String?> rawResultJson = const Value.absent(),
          String? syncStatus,
          int? createdAt,
          int? updatedAt}) =>
      AiScansTableData(
        localId: localId ?? this.localId,
        serverId: serverId.present ? serverId.value : this.serverId,
        animalLocalId: animalLocalId ?? this.animalLocalId,
        animalServerId:
            animalServerId.present ? animalServerId.value : this.animalServerId,
        localImagePath: localImagePath ?? this.localImagePath,
        status: status ?? this.status,
        diagnosis: diagnosis.present ? diagnosis.value : this.diagnosis,
        confidenceScore: confidenceScore.present
            ? confidenceScore.value
            : this.confidenceScore,
        severity: severity.present ? severity.value : this.severity,
        observationsJson: observationsJson.present
            ? observationsJson.value
            : this.observationsJson,
        rawResultJson:
            rawResultJson.present ? rawResultJson.value : this.rawResultJson,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AiScansTableData copyWithCompanion(AiScansTableCompanion data) {
    return AiScansTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      animalLocalId: data.animalLocalId.present
          ? data.animalLocalId.value
          : this.animalLocalId,
      animalServerId: data.animalServerId.present
          ? data.animalServerId.value
          : this.animalServerId,
      localImagePath: data.localImagePath.present
          ? data.localImagePath.value
          : this.localImagePath,
      status: data.status.present ? data.status.value : this.status,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      severity: data.severity.present ? data.severity.value : this.severity,
      observationsJson: data.observationsJson.present
          ? data.observationsJson.value
          : this.observationsJson,
      rawResultJson: data.rawResultJson.present
          ? data.rawResultJson.value
          : this.rawResultJson,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiScansTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('animalLocalId: $animalLocalId, ')
          ..write('animalServerId: $animalServerId, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('status: $status, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('severity: $severity, ')
          ..write('observationsJson: $observationsJson, ')
          ..write('rawResultJson: $rawResultJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      serverId,
      animalLocalId,
      animalServerId,
      localImagePath,
      status,
      diagnosis,
      confidenceScore,
      severity,
      observationsJson,
      rawResultJson,
      syncStatus,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiScansTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.animalLocalId == this.animalLocalId &&
          other.animalServerId == this.animalServerId &&
          other.localImagePath == this.localImagePath &&
          other.status == this.status &&
          other.diagnosis == this.diagnosis &&
          other.confidenceScore == this.confidenceScore &&
          other.severity == this.severity &&
          other.observationsJson == this.observationsJson &&
          other.rawResultJson == this.rawResultJson &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AiScansTableCompanion extends UpdateCompanion<AiScansTableData> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> animalLocalId;
  final Value<String?> animalServerId;
  final Value<String> localImagePath;
  final Value<String> status;
  final Value<String?> diagnosis;
  final Value<double?> confidenceScore;
  final Value<String?> severity;
  final Value<String?> observationsJson;
  final Value<String?> rawResultJson;
  final Value<String> syncStatus;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AiScansTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.animalLocalId = const Value.absent(),
    this.animalServerId = const Value.absent(),
    this.localImagePath = const Value.absent(),
    this.status = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.severity = const Value.absent(),
    this.observationsJson = const Value.absent(),
    this.rawResultJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiScansTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String animalLocalId,
    this.animalServerId = const Value.absent(),
    required String localImagePath,
    this.status = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.severity = const Value.absent(),
    this.observationsJson = const Value.absent(),
    this.rawResultJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : localId = Value(localId),
        animalLocalId = Value(animalLocalId),
        localImagePath = Value(localImagePath),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AiScansTableData> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? animalLocalId,
    Expression<String>? animalServerId,
    Expression<String>? localImagePath,
    Expression<String>? status,
    Expression<String>? diagnosis,
    Expression<double>? confidenceScore,
    Expression<String>? severity,
    Expression<String>? observationsJson,
    Expression<String>? rawResultJson,
    Expression<String>? syncStatus,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (animalLocalId != null) 'animal_local_id': animalLocalId,
      if (animalServerId != null) 'animal_server_id': animalServerId,
      if (localImagePath != null) 'local_image_path': localImagePath,
      if (status != null) 'status': status,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (severity != null) 'severity': severity,
      if (observationsJson != null) 'observations_json': observationsJson,
      if (rawResultJson != null) 'raw_result_json': rawResultJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiScansTableCompanion copyWith(
      {Value<String>? localId,
      Value<String?>? serverId,
      Value<String>? animalLocalId,
      Value<String?>? animalServerId,
      Value<String>? localImagePath,
      Value<String>? status,
      Value<String?>? diagnosis,
      Value<double?>? confidenceScore,
      Value<String?>? severity,
      Value<String?>? observationsJson,
      Value<String?>? rawResultJson,
      Value<String>? syncStatus,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return AiScansTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      animalLocalId: animalLocalId ?? this.animalLocalId,
      animalServerId: animalServerId ?? this.animalServerId,
      localImagePath: localImagePath ?? this.localImagePath,
      status: status ?? this.status,
      diagnosis: diagnosis ?? this.diagnosis,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      severity: severity ?? this.severity,
      observationsJson: observationsJson ?? this.observationsJson,
      rawResultJson: rawResultJson ?? this.rawResultJson,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (animalLocalId.present) {
      map['animal_local_id'] = Variable<String>(animalLocalId.value);
    }
    if (animalServerId.present) {
      map['animal_server_id'] = Variable<String>(animalServerId.value);
    }
    if (localImagePath.present) {
      map['local_image_path'] = Variable<String>(localImagePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (observationsJson.present) {
      map['observations_json'] = Variable<String>(observationsJson.value);
    }
    if (rawResultJson.present) {
      map['raw_result_json'] = Variable<String>(rawResultJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiScansTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('animalLocalId: $animalLocalId, ')
          ..write('animalServerId: $animalServerId, ')
          ..write('localImagePath: $localImagePath, ')
          ..write('status: $status, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('severity: $severity, ')
          ..write('observationsJson: $observationsJson, ')
          ..write('rawResultJson: $rawResultJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineOperationsTableTable extends OfflineOperationsTable
    with TableInfo<$OfflineOperationsTableTable, OfflineOperationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineOperationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta =
      const VerificationMeta('operationId');
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
      'operation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationTypeMeta =
      const VerificationMeta('operationType');
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
      'operation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityLocalIdMeta =
      const VerificationMeta('entityLocalId');
  @override
  late final GeneratedColumn<String> entityLocalId = GeneratedColumn<String>(
      'entity_local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxRetriesMeta =
      const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
      'max_retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _dependsOnMeta =
      const VerificationMeta('dependsOn');
  @override
  late final GeneratedColumn<String> dependsOn = GeneratedColumn<String>(
      'depends_on', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastAttemptedAtMeta =
      const VerificationMeta('lastAttemptedAt');
  @override
  late final GeneratedColumn<int> lastAttemptedAt = GeneratedColumn<int>(
      'last_attempted_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        operationId,
        operationType,
        entityType,
        entityLocalId,
        payloadJson,
        status,
        retryCount,
        maxRetries,
        lastError,
        idempotencyKey,
        dependsOn,
        createdAt,
        lastAttemptedAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_operations';
  @override
  VerificationContext validateIntegrity(
      Insertable<OfflineOperationsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
          _operationIdMeta,
          operationId.isAcceptableOrUnknown(
              data['operation_id']!, _operationIdMeta));
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
          _operationTypeMeta,
          operationType.isAcceptableOrUnknown(
              data['operation_type']!, _operationTypeMeta));
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_local_id')) {
      context.handle(
          _entityLocalIdMeta,
          entityLocalId.isAcceptableOrUnknown(
              data['entity_local_id']!, _entityLocalIdMeta));
    } else if (isInserting) {
      context.missing(_entityLocalIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(
          _maxRetriesMeta,
          maxRetries.isAcceptableOrUnknown(
              data['max_retries']!, _maxRetriesMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('depends_on')) {
      context.handle(_dependsOnMeta,
          dependsOn.isAcceptableOrUnknown(data['depends_on']!, _dependsOnMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempted_at')) {
      context.handle(
          _lastAttemptedAtMeta,
          lastAttemptedAt.isAcceptableOrUnknown(
              data['last_attempted_at']!, _lastAttemptedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  OfflineOperationsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineOperationsTableData(
      operationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_id'])!,
      operationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_type'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityLocalId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entity_local_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      maxRetries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      dependsOn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}depends_on']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      lastAttemptedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_attempted_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $OfflineOperationsTableTable createAlias(String alias) {
    return $OfflineOperationsTableTable(attachedDatabase, alias);
  }
}

class OfflineOperationsTableData extends DataClass
    implements Insertable<OfflineOperationsTableData> {
  /// Client-generated UUID; also used as [idempotencyKey].
  final String operationId;

  /// createAnimal | updateAnimal | deleteAnimal |
  /// createDiseaseReport | submitAiScan
  final String operationType;

  /// animal | diseaseReport | aiScan
  final String entityType;

  /// FK to the relevant local_* table's localId.
  final String entityLocalId;

  /// Full JSON request body to replay against the API.
  final String payloadJson;

  /// pending | processing | completed | failed | cancelled
  final String status;
  final int retryCount;
  final int maxRetries;
  final String? lastError;

  /// Sent as `Idempotency-Key: <value>` HTTP header. Equals [operationId].
  final String idempotencyKey;

  /// [operationId] of a prior operation that MUST be COMPLETED before this one runs.
  /// Used to ensure createAnimal finishes before createDiseaseReport is submitted.
  final String? dependsOn;
  final int createdAt;
  final int? lastAttemptedAt;
  final int? completedAt;
  const OfflineOperationsTableData(
      {required this.operationId,
      required this.operationType,
      required this.entityType,
      required this.entityLocalId,
      required this.payloadJson,
      required this.status,
      required this.retryCount,
      required this.maxRetries,
      this.lastError,
      required this.idempotencyKey,
      this.dependsOn,
      required this.createdAt,
      this.lastAttemptedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['operation_type'] = Variable<String>(operationType);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_local_id'] = Variable<String>(entityLocalId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    if (!nullToAbsent || dependsOn != null) {
      map['depends_on'] = Variable<String>(dependsOn);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || lastAttemptedAt != null) {
      map['last_attempted_at'] = Variable<int>(lastAttemptedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  OfflineOperationsTableCompanion toCompanion(bool nullToAbsent) {
    return OfflineOperationsTableCompanion(
      operationId: Value(operationId),
      operationType: Value(operationType),
      entityType: Value(entityType),
      entityLocalId: Value(entityLocalId),
      payloadJson: Value(payloadJson),
      status: Value(status),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      idempotencyKey: Value(idempotencyKey),
      dependsOn: dependsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOn),
      createdAt: Value(createdAt),
      lastAttemptedAt: lastAttemptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory OfflineOperationsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineOperationsTableData(
      operationId: serializer.fromJson<String>(json['operationId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityLocalId: serializer.fromJson<String>(json['entityLocalId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      dependsOn: serializer.fromJson<String?>(json['dependsOn']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      lastAttemptedAt: serializer.fromJson<int?>(json['lastAttemptedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'operationType': serializer.toJson<String>(operationType),
      'entityType': serializer.toJson<String>(entityType),
      'entityLocalId': serializer.toJson<String>(entityLocalId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'lastError': serializer.toJson<String?>(lastError),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'dependsOn': serializer.toJson<String?>(dependsOn),
      'createdAt': serializer.toJson<int>(createdAt),
      'lastAttemptedAt': serializer.toJson<int?>(lastAttemptedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }

  OfflineOperationsTableData copyWith(
          {String? operationId,
          String? operationType,
          String? entityType,
          String? entityLocalId,
          String? payloadJson,
          String? status,
          int? retryCount,
          int? maxRetries,
          Value<String?> lastError = const Value.absent(),
          String? idempotencyKey,
          Value<String?> dependsOn = const Value.absent(),
          int? createdAt,
          Value<int?> lastAttemptedAt = const Value.absent(),
          Value<int?> completedAt = const Value.absent()}) =>
      OfflineOperationsTableData(
        operationId: operationId ?? this.operationId,
        operationType: operationType ?? this.operationType,
        entityType: entityType ?? this.entityType,
        entityLocalId: entityLocalId ?? this.entityLocalId,
        payloadJson: payloadJson ?? this.payloadJson,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        maxRetries: maxRetries ?? this.maxRetries,
        lastError: lastError.present ? lastError.value : this.lastError,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        dependsOn: dependsOn.present ? dependsOn.value : this.dependsOn,
        createdAt: createdAt ?? this.createdAt,
        lastAttemptedAt: lastAttemptedAt.present
            ? lastAttemptedAt.value
            : this.lastAttemptedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  OfflineOperationsTableData copyWithCompanion(
      OfflineOperationsTableCompanion data) {
    return OfflineOperationsTableData(
      operationId:
          data.operationId.present ? data.operationId.value : this.operationId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityLocalId: data.entityLocalId.present
          ? data.entityLocalId.value
          : this.entityLocalId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      maxRetries:
          data.maxRetries.present ? data.maxRetries.value : this.maxRetries,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      dependsOn: data.dependsOn.present ? data.dependsOn.value : this.dependsOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptedAt: data.lastAttemptedAt.present
          ? data.lastAttemptedAt.value
          : this.lastAttemptedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineOperationsTableData(')
          ..write('operationId: $operationId, ')
          ..write('operationType: $operationType, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('lastError: $lastError, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      operationId,
      operationType,
      entityType,
      entityLocalId,
      payloadJson,
      status,
      retryCount,
      maxRetries,
      lastError,
      idempotencyKey,
      dependsOn,
      createdAt,
      lastAttemptedAt,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineOperationsTableData &&
          other.operationId == this.operationId &&
          other.operationType == this.operationType &&
          other.entityType == this.entityType &&
          other.entityLocalId == this.entityLocalId &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries &&
          other.lastError == this.lastError &&
          other.idempotencyKey == this.idempotencyKey &&
          other.dependsOn == this.dependsOn &&
          other.createdAt == this.createdAt &&
          other.lastAttemptedAt == this.lastAttemptedAt &&
          other.completedAt == this.completedAt);
}

class OfflineOperationsTableCompanion
    extends UpdateCompanion<OfflineOperationsTableData> {
  final Value<String> operationId;
  final Value<String> operationType;
  final Value<String> entityType;
  final Value<String> entityLocalId;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  final Value<String?> lastError;
  final Value<String> idempotencyKey;
  final Value<String?> dependsOn;
  final Value<int> createdAt;
  final Value<int?> lastAttemptedAt;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const OfflineOperationsTableCompanion({
    this.operationId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityLocalId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.lastError = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.dependsOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineOperationsTableCompanion.insert({
    required String operationId,
    required String operationType,
    required String entityType,
    required String entityLocalId,
    required String payloadJson,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.lastError = const Value.absent(),
    required String idempotencyKey,
    this.dependsOn = const Value.absent(),
    required int createdAt,
    this.lastAttemptedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : operationId = Value(operationId),
        operationType = Value(operationType),
        entityType = Value(entityType),
        entityLocalId = Value(entityLocalId),
        payloadJson = Value(payloadJson),
        idempotencyKey = Value(idempotencyKey),
        createdAt = Value(createdAt);
  static Insertable<OfflineOperationsTableData> custom({
    Expression<String>? operationId,
    Expression<String>? operationType,
    Expression<String>? entityType,
    Expression<String>? entityLocalId,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
    Expression<String>? lastError,
    Expression<String>? idempotencyKey,
    Expression<String>? dependsOn,
    Expression<int>? createdAt,
    Expression<int>? lastAttemptedAt,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (operationType != null) 'operation_type': operationType,
      if (entityType != null) 'entity_type': entityType,
      if (entityLocalId != null) 'entity_local_id': entityLocalId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (lastError != null) 'last_error': lastError,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (dependsOn != null) 'depends_on': dependsOn,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptedAt != null) 'last_attempted_at': lastAttemptedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineOperationsTableCompanion copyWith(
      {Value<String>? operationId,
      Value<String>? operationType,
      Value<String>? entityType,
      Value<String>? entityLocalId,
      Value<String>? payloadJson,
      Value<String>? status,
      Value<int>? retryCount,
      Value<int>? maxRetries,
      Value<String?>? lastError,
      Value<String>? idempotencyKey,
      Value<String?>? dependsOn,
      Value<int>? createdAt,
      Value<int?>? lastAttemptedAt,
      Value<int?>? completedAt,
      Value<int>? rowid}) {
    return OfflineOperationsTableCompanion(
      operationId: operationId ?? this.operationId,
      operationType: operationType ?? this.operationType,
      entityType: entityType ?? this.entityType,
      entityLocalId: entityLocalId ?? this.entityLocalId,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      lastError: lastError ?? this.lastError,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      dependsOn: dependsOn ?? this.dependsOn,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityLocalId.present) {
      map['entity_local_id'] = Variable<String>(entityLocalId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (dependsOn.present) {
      map['depends_on'] = Variable<String>(dependsOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (lastAttemptedAt.present) {
      map['last_attempted_at'] = Variable<int>(lastAttemptedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineOperationsTableCompanion(')
          ..write('operationId: $operationId, ')
          ..write('operationType: $operationType, ')
          ..write('entityType: $entityType, ')
          ..write('entityLocalId: $entityLocalId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('lastError: $lastError, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptedAt: $lastAttemptedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTableTable extends SyncMetadataTable
    with TableInfo<$SyncMetadataTableTable, SyncMetadataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncVersionMeta =
      const VerificationMeta('syncVersion');
  @override
  late final GeneratedColumn<int> syncVersion = GeneratedColumn<int>(
      'sync_version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [entityType, lastSyncedAt, syncVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncMetadataTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('sync_version')) {
      context.handle(
          _syncVersionMeta,
          syncVersion.isAcceptableOrUnknown(
              data['sync_version']!, _syncVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncMetadataTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataTableData(
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      lastSyncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_synced_at']),
      syncVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_version'])!,
    );
  }

  @override
  $SyncMetadataTableTable createAlias(String alias) {
    return $SyncMetadataTableTable(attachedDatabase, alias);
  }
}

class SyncMetadataTableData extends DataClass
    implements Insertable<SyncMetadataTableData> {
  /// Entity type identifier: 'animals' | 'diseaseReports' | 'aiScans'
  final String entityType;

  /// Unix milliseconds of last successful pull from server.
  final int? lastSyncedAt;

  /// Monotonically increasing counter; bumped after every successful sync cycle.
  final int syncVersion;
  const SyncMetadataTableData(
      {required this.entityType, this.lastSyncedAt, required this.syncVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    map['sync_version'] = Variable<int>(syncVersion);
    return map;
  }

  SyncMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataTableCompanion(
      entityType: Value(entityType),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      syncVersion: Value(syncVersion),
    );
  }

  factory SyncMetadataTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataTableData(
      entityType: serializer.fromJson<String>(json['entityType']),
      lastSyncedAt: serializer.fromJson<int?>(json['lastSyncedAt']),
      syncVersion: serializer.fromJson<int>(json['syncVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastSyncedAt': serializer.toJson<int?>(lastSyncedAt),
      'syncVersion': serializer.toJson<int>(syncVersion),
    };
  }

  SyncMetadataTableData copyWith(
          {String? entityType,
          Value<int?> lastSyncedAt = const Value.absent(),
          int? syncVersion}) =>
      SyncMetadataTableData(
        entityType: entityType ?? this.entityType,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        syncVersion: syncVersion ?? this.syncVersion,
      );
  SyncMetadataTableData copyWithCompanion(SyncMetadataTableCompanion data) {
    return SyncMetadataTableData(
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      syncVersion:
          data.syncVersion.present ? data.syncVersion.value : this.syncVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataTableData(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncVersion: $syncVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, lastSyncedAt, syncVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataTableData &&
          other.entityType == this.entityType &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.syncVersion == this.syncVersion);
}

class SyncMetadataTableCompanion
    extends UpdateCompanion<SyncMetadataTableData> {
  final Value<String> entityType;
  final Value<int?> lastSyncedAt;
  final Value<int> syncVersion;
  final Value<int> rowid;
  const SyncMetadataTableCompanion({
    this.entityType = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataTableCompanion.insert({
    required String entityType,
    this.lastSyncedAt = const Value.absent(),
    this.syncVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType);
  static Insertable<SyncMetadataTableData> custom({
    Expression<String>? entityType,
    Expression<int>? lastSyncedAt,
    Expression<int>? syncVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (syncVersion != null) 'sync_version': syncVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataTableCompanion copyWith(
      {Value<String>? entityType,
      Value<int?>? lastSyncedAt,
      Value<int>? syncVersion,
      Value<int>? rowid}) {
    return SyncMetadataTableCompanion(
      entityType: entityType ?? this.entityType,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (syncVersion.present) {
      map['sync_version'] = Variable<int>(syncVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataTableCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('syncVersion: $syncVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VetraDatabase extends GeneratedDatabase {
  _$VetraDatabase(QueryExecutor e) : super(e);
  $VetraDatabaseManager get managers => $VetraDatabaseManager(this);
  late final $AnimalsTableTable animalsTable = $AnimalsTableTable(this);
  late final $DiseaseReportsTableTable diseaseReportsTable =
      $DiseaseReportsTableTable(this);
  late final $AiScansTableTable aiScansTable = $AiScansTableTable(this);
  late final $OfflineOperationsTableTable offlineOperationsTable =
      $OfflineOperationsTableTable(this);
  late final $SyncMetadataTableTable syncMetadataTable =
      $SyncMetadataTableTable(this);
  late final AnimalDao animalDao = AnimalDao(this as VetraDatabase);
  late final DiseaseReportDao diseaseReportDao =
      DiseaseReportDao(this as VetraDatabase);
  late final AiScanDao aiScanDao = AiScanDao(this as VetraDatabase);
  late final OfflineOperationDao offlineOperationDao =
      OfflineOperationDao(this as VetraDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        animalsTable,
        diseaseReportsTable,
        aiScansTable,
        offlineOperationsTable,
        syncMetadataTable
      ];
}

typedef $$AnimalsTableTableCreateCompanionBuilder = AnimalsTableCompanion
    Function({
  required String localId,
  Value<String?> serverId,
  required String farmerId,
  Value<String?> animalName,
  required String tagNumber,
  Value<String?> qrCodeId,
  required String species,
  Value<String?> breed,
  required String gender,
  Value<String?> birthDate,
  Value<String?> photoUrl,
  Value<String?> localPhotoPath,
  Value<String> syncStatus,
  required int createdAt,
  required int updatedAt,
  Value<int> serverVersion,
  Value<int> rowid,
});
typedef $$AnimalsTableTableUpdateCompanionBuilder = AnimalsTableCompanion
    Function({
  Value<String> localId,
  Value<String?> serverId,
  Value<String> farmerId,
  Value<String?> animalName,
  Value<String> tagNumber,
  Value<String?> qrCodeId,
  Value<String> species,
  Value<String?> breed,
  Value<String> gender,
  Value<String?> birthDate,
  Value<String?> photoUrl,
  Value<String?> localPhotoPath,
  Value<String> syncStatus,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> serverVersion,
  Value<int> rowid,
});

class $$AnimalsTableTableFilterComposer
    extends Composer<_$VetraDatabase, $AnimalsTableTable> {
  $$AnimalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerId => $composableBuilder(
      column: $table.farmerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalName => $composableBuilder(
      column: $table.animalName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagNumber => $composableBuilder(
      column: $table.tagNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qrCodeId => $composableBuilder(
      column: $table.qrCodeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPhotoPath => $composableBuilder(
      column: $table.localPhotoPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverVersion => $composableBuilder(
      column: $table.serverVersion, builder: (column) => ColumnFilters(column));
}

class $$AnimalsTableTableOrderingComposer
    extends Composer<_$VetraDatabase, $AnimalsTableTable> {
  $$AnimalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerId => $composableBuilder(
      column: $table.farmerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalName => $composableBuilder(
      column: $table.animalName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagNumber => $composableBuilder(
      column: $table.tagNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qrCodeId => $composableBuilder(
      column: $table.qrCodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPhotoPath => $composableBuilder(
      column: $table.localPhotoPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverVersion => $composableBuilder(
      column: $table.serverVersion,
      builder: (column) => ColumnOrderings(column));
}

class $$AnimalsTableTableAnnotationComposer
    extends Composer<_$VetraDatabase, $AnimalsTableTable> {
  $$AnimalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get animalName => $composableBuilder(
      column: $table.animalName, builder: (column) => column);

  GeneratedColumn<String> get tagNumber =>
      $composableBuilder(column: $table.tagNumber, builder: (column) => column);

  GeneratedColumn<String> get qrCodeId =>
      $composableBuilder(column: $table.qrCodeId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get localPhotoPath => $composableBuilder(
      column: $table.localPhotoPath, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
      column: $table.serverVersion, builder: (column) => column);
}

class $$AnimalsTableTableTableManager extends RootTableManager<
    _$VetraDatabase,
    $AnimalsTableTable,
    AnimalsTableData,
    $$AnimalsTableTableFilterComposer,
    $$AnimalsTableTableOrderingComposer,
    $$AnimalsTableTableAnnotationComposer,
    $$AnimalsTableTableCreateCompanionBuilder,
    $$AnimalsTableTableUpdateCompanionBuilder,
    (
      AnimalsTableData,
      BaseReferences<_$VetraDatabase, $AnimalsTableTable, AnimalsTableData>
    ),
    AnimalsTableData,
    PrefetchHooks Function()> {
  $$AnimalsTableTableTableManager(_$VetraDatabase db, $AnimalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnimalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnimalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnimalsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localId = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> farmerId = const Value.absent(),
            Value<String?> animalName = const Value.absent(),
            Value<String> tagNumber = const Value.absent(),
            Value<String?> qrCodeId = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<String?> breed = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String?> birthDate = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> localPhotoPath = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> serverVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsTableCompanion(
            localId: localId,
            serverId: serverId,
            farmerId: farmerId,
            animalName: animalName,
            tagNumber: tagNumber,
            qrCodeId: qrCodeId,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            photoUrl: photoUrl,
            localPhotoPath: localPhotoPath,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverVersion: serverVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localId,
            Value<String?> serverId = const Value.absent(),
            required String farmerId,
            Value<String?> animalName = const Value.absent(),
            required String tagNumber,
            Value<String?> qrCodeId = const Value.absent(),
            required String species,
            Value<String?> breed = const Value.absent(),
            required String gender,
            Value<String?> birthDate = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> localPhotoPath = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> serverVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnimalsTableCompanion.insert(
            localId: localId,
            serverId: serverId,
            farmerId: farmerId,
            animalName: animalName,
            tagNumber: tagNumber,
            qrCodeId: qrCodeId,
            species: species,
            breed: breed,
            gender: gender,
            birthDate: birthDate,
            photoUrl: photoUrl,
            localPhotoPath: localPhotoPath,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverVersion: serverVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnimalsTableTableProcessedTableManager = ProcessedTableManager<
    _$VetraDatabase,
    $AnimalsTableTable,
    AnimalsTableData,
    $$AnimalsTableTableFilterComposer,
    $$AnimalsTableTableOrderingComposer,
    $$AnimalsTableTableAnnotationComposer,
    $$AnimalsTableTableCreateCompanionBuilder,
    $$AnimalsTableTableUpdateCompanionBuilder,
    (
      AnimalsTableData,
      BaseReferences<_$VetraDatabase, $AnimalsTableTable, AnimalsTableData>
    ),
    AnimalsTableData,
    PrefetchHooks Function()>;
typedef $$DiseaseReportsTableTableCreateCompanionBuilder
    = DiseaseReportsTableCompanion Function({
  required String localId,
  Value<String?> serverId,
  required String animalLocalId,
  Value<String?> animalServerId,
  required String diseaseName,
  Value<String> diagnosisStatus,
  Value<String> reportSource,
  required double latitude,
  required double longitude,
  Value<double?> gpsAccuracy,
  Value<String> gpsQuality,
  Value<String?> notes,
  Value<String?> aiScanLocalId,
  Value<String?> aiScanServerId,
  Value<String> syncStatus,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$DiseaseReportsTableTableUpdateCompanionBuilder
    = DiseaseReportsTableCompanion Function({
  Value<String> localId,
  Value<String?> serverId,
  Value<String> animalLocalId,
  Value<String?> animalServerId,
  Value<String> diseaseName,
  Value<String> diagnosisStatus,
  Value<String> reportSource,
  Value<double> latitude,
  Value<double> longitude,
  Value<double?> gpsAccuracy,
  Value<String> gpsQuality,
  Value<String?> notes,
  Value<String?> aiScanLocalId,
  Value<String?> aiScanServerId,
  Value<String> syncStatus,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$DiseaseReportsTableTableFilterComposer
    extends Composer<_$VetraDatabase, $DiseaseReportsTableTable> {
  $$DiseaseReportsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalLocalId => $composableBuilder(
      column: $table.animalLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalServerId => $composableBuilder(
      column: $table.animalServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diseaseName => $composableBuilder(
      column: $table.diseaseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosisStatus => $composableBuilder(
      column: $table.diagnosisStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reportSource => $composableBuilder(
      column: $table.reportSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gpsQuality => $composableBuilder(
      column: $table.gpsQuality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiScanLocalId => $composableBuilder(
      column: $table.aiScanLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiScanServerId => $composableBuilder(
      column: $table.aiScanServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DiseaseReportsTableTableOrderingComposer
    extends Composer<_$VetraDatabase, $DiseaseReportsTableTable> {
  $$DiseaseReportsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalLocalId => $composableBuilder(
      column: $table.animalLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalServerId => $composableBuilder(
      column: $table.animalServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diseaseName => $composableBuilder(
      column: $table.diseaseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosisStatus => $composableBuilder(
      column: $table.diagnosisStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reportSource => $composableBuilder(
      column: $table.reportSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gpsQuality => $composableBuilder(
      column: $table.gpsQuality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiScanLocalId => $composableBuilder(
      column: $table.aiScanLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiScanServerId => $composableBuilder(
      column: $table.aiScanServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DiseaseReportsTableTableAnnotationComposer
    extends Composer<_$VetraDatabase, $DiseaseReportsTableTable> {
  $$DiseaseReportsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get animalLocalId => $composableBuilder(
      column: $table.animalLocalId, builder: (column) => column);

  GeneratedColumn<String> get animalServerId => $composableBuilder(
      column: $table.animalServerId, builder: (column) => column);

  GeneratedColumn<String> get diseaseName => $composableBuilder(
      column: $table.diseaseName, builder: (column) => column);

  GeneratedColumn<String> get diagnosisStatus => $composableBuilder(
      column: $table.diagnosisStatus, builder: (column) => column);

  GeneratedColumn<String> get reportSource => $composableBuilder(
      column: $table.reportSource, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get gpsAccuracy => $composableBuilder(
      column: $table.gpsAccuracy, builder: (column) => column);

  GeneratedColumn<String> get gpsQuality => $composableBuilder(
      column: $table.gpsQuality, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get aiScanLocalId => $composableBuilder(
      column: $table.aiScanLocalId, builder: (column) => column);

  GeneratedColumn<String> get aiScanServerId => $composableBuilder(
      column: $table.aiScanServerId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DiseaseReportsTableTableTableManager extends RootTableManager<
    _$VetraDatabase,
    $DiseaseReportsTableTable,
    DiseaseReportsTableData,
    $$DiseaseReportsTableTableFilterComposer,
    $$DiseaseReportsTableTableOrderingComposer,
    $$DiseaseReportsTableTableAnnotationComposer,
    $$DiseaseReportsTableTableCreateCompanionBuilder,
    $$DiseaseReportsTableTableUpdateCompanionBuilder,
    (
      DiseaseReportsTableData,
      BaseReferences<_$VetraDatabase, $DiseaseReportsTableTable,
          DiseaseReportsTableData>
    ),
    DiseaseReportsTableData,
    PrefetchHooks Function()> {
  $$DiseaseReportsTableTableTableManager(
      _$VetraDatabase db, $DiseaseReportsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiseaseReportsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiseaseReportsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiseaseReportsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localId = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> animalLocalId = const Value.absent(),
            Value<String?> animalServerId = const Value.absent(),
            Value<String> diseaseName = const Value.absent(),
            Value<String> diagnosisStatus = const Value.absent(),
            Value<String> reportSource = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double?> gpsAccuracy = const Value.absent(),
            Value<String> gpsQuality = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> aiScanLocalId = const Value.absent(),
            Value<String?> aiScanServerId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiseaseReportsTableCompanion(
            localId: localId,
            serverId: serverId,
            animalLocalId: animalLocalId,
            animalServerId: animalServerId,
            diseaseName: diseaseName,
            diagnosisStatus: diagnosisStatus,
            reportSource: reportSource,
            latitude: latitude,
            longitude: longitude,
            gpsAccuracy: gpsAccuracy,
            gpsQuality: gpsQuality,
            notes: notes,
            aiScanLocalId: aiScanLocalId,
            aiScanServerId: aiScanServerId,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localId,
            Value<String?> serverId = const Value.absent(),
            required String animalLocalId,
            Value<String?> animalServerId = const Value.absent(),
            required String diseaseName,
            Value<String> diagnosisStatus = const Value.absent(),
            Value<String> reportSource = const Value.absent(),
            required double latitude,
            required double longitude,
            Value<double?> gpsAccuracy = const Value.absent(),
            Value<String> gpsQuality = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> aiScanLocalId = const Value.absent(),
            Value<String?> aiScanServerId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DiseaseReportsTableCompanion.insert(
            localId: localId,
            serverId: serverId,
            animalLocalId: animalLocalId,
            animalServerId: animalServerId,
            diseaseName: diseaseName,
            diagnosisStatus: diagnosisStatus,
            reportSource: reportSource,
            latitude: latitude,
            longitude: longitude,
            gpsAccuracy: gpsAccuracy,
            gpsQuality: gpsQuality,
            notes: notes,
            aiScanLocalId: aiScanLocalId,
            aiScanServerId: aiScanServerId,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DiseaseReportsTableTableProcessedTableManager = ProcessedTableManager<
    _$VetraDatabase,
    $DiseaseReportsTableTable,
    DiseaseReportsTableData,
    $$DiseaseReportsTableTableFilterComposer,
    $$DiseaseReportsTableTableOrderingComposer,
    $$DiseaseReportsTableTableAnnotationComposer,
    $$DiseaseReportsTableTableCreateCompanionBuilder,
    $$DiseaseReportsTableTableUpdateCompanionBuilder,
    (
      DiseaseReportsTableData,
      BaseReferences<_$VetraDatabase, $DiseaseReportsTableTable,
          DiseaseReportsTableData>
    ),
    DiseaseReportsTableData,
    PrefetchHooks Function()>;
typedef $$AiScansTableTableCreateCompanionBuilder = AiScansTableCompanion
    Function({
  required String localId,
  Value<String?> serverId,
  required String animalLocalId,
  Value<String?> animalServerId,
  required String localImagePath,
  Value<String> status,
  Value<String?> diagnosis,
  Value<double?> confidenceScore,
  Value<String?> severity,
  Value<String?> observationsJson,
  Value<String?> rawResultJson,
  Value<String> syncStatus,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$AiScansTableTableUpdateCompanionBuilder = AiScansTableCompanion
    Function({
  Value<String> localId,
  Value<String?> serverId,
  Value<String> animalLocalId,
  Value<String?> animalServerId,
  Value<String> localImagePath,
  Value<String> status,
  Value<String?> diagnosis,
  Value<double?> confidenceScore,
  Value<String?> severity,
  Value<String?> observationsJson,
  Value<String?> rawResultJson,
  Value<String> syncStatus,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$AiScansTableTableFilterComposer
    extends Composer<_$VetraDatabase, $AiScansTableTable> {
  $$AiScansTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalLocalId => $composableBuilder(
      column: $table.animalLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalServerId => $composableBuilder(
      column: $table.animalServerId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get observationsJson => $composableBuilder(
      column: $table.observationsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawResultJson => $composableBuilder(
      column: $table.rawResultJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AiScansTableTableOrderingComposer
    extends Composer<_$VetraDatabase, $AiScansTableTable> {
  $$AiScansTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalLocalId => $composableBuilder(
      column: $table.animalLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalServerId => $composableBuilder(
      column: $table.animalServerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get observationsJson => $composableBuilder(
      column: $table.observationsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawResultJson => $composableBuilder(
      column: $table.rawResultJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AiScansTableTableAnnotationComposer
    extends Composer<_$VetraDatabase, $AiScansTableTable> {
  $$AiScansTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get animalLocalId => $composableBuilder(
      column: $table.animalLocalId, builder: (column) => column);

  GeneratedColumn<String> get animalServerId => $composableBuilder(
      column: $table.animalServerId, builder: (column) => column);

  GeneratedColumn<String> get localImagePath => $composableBuilder(
      column: $table.localImagePath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get observationsJson => $composableBuilder(
      column: $table.observationsJson, builder: (column) => column);

  GeneratedColumn<String> get rawResultJson => $composableBuilder(
      column: $table.rawResultJson, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiScansTableTableTableManager extends RootTableManager<
    _$VetraDatabase,
    $AiScansTableTable,
    AiScansTableData,
    $$AiScansTableTableFilterComposer,
    $$AiScansTableTableOrderingComposer,
    $$AiScansTableTableAnnotationComposer,
    $$AiScansTableTableCreateCompanionBuilder,
    $$AiScansTableTableUpdateCompanionBuilder,
    (
      AiScansTableData,
      BaseReferences<_$VetraDatabase, $AiScansTableTable, AiScansTableData>
    ),
    AiScansTableData,
    PrefetchHooks Function()> {
  $$AiScansTableTableTableManager(_$VetraDatabase db, $AiScansTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiScansTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiScansTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiScansTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localId = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<String> animalLocalId = const Value.absent(),
            Value<String?> animalServerId = const Value.absent(),
            Value<String> localImagePath = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> diagnosis = const Value.absent(),
            Value<double?> confidenceScore = const Value.absent(),
            Value<String?> severity = const Value.absent(),
            Value<String?> observationsJson = const Value.absent(),
            Value<String?> rawResultJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AiScansTableCompanion(
            localId: localId,
            serverId: serverId,
            animalLocalId: animalLocalId,
            animalServerId: animalServerId,
            localImagePath: localImagePath,
            status: status,
            diagnosis: diagnosis,
            confidenceScore: confidenceScore,
            severity: severity,
            observationsJson: observationsJson,
            rawResultJson: rawResultJson,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localId,
            Value<String?> serverId = const Value.absent(),
            required String animalLocalId,
            Value<String?> animalServerId = const Value.absent(),
            required String localImagePath,
            Value<String> status = const Value.absent(),
            Value<String?> diagnosis = const Value.absent(),
            Value<double?> confidenceScore = const Value.absent(),
            Value<String?> severity = const Value.absent(),
            Value<String?> observationsJson = const Value.absent(),
            Value<String?> rawResultJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AiScansTableCompanion.insert(
            localId: localId,
            serverId: serverId,
            animalLocalId: animalLocalId,
            animalServerId: animalServerId,
            localImagePath: localImagePath,
            status: status,
            diagnosis: diagnosis,
            confidenceScore: confidenceScore,
            severity: severity,
            observationsJson: observationsJson,
            rawResultJson: rawResultJson,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AiScansTableTableProcessedTableManager = ProcessedTableManager<
    _$VetraDatabase,
    $AiScansTableTable,
    AiScansTableData,
    $$AiScansTableTableFilterComposer,
    $$AiScansTableTableOrderingComposer,
    $$AiScansTableTableAnnotationComposer,
    $$AiScansTableTableCreateCompanionBuilder,
    $$AiScansTableTableUpdateCompanionBuilder,
    (
      AiScansTableData,
      BaseReferences<_$VetraDatabase, $AiScansTableTable, AiScansTableData>
    ),
    AiScansTableData,
    PrefetchHooks Function()>;
typedef $$OfflineOperationsTableTableCreateCompanionBuilder
    = OfflineOperationsTableCompanion Function({
  required String operationId,
  required String operationType,
  required String entityType,
  required String entityLocalId,
  required String payloadJson,
  Value<String> status,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<String?> lastError,
  required String idempotencyKey,
  Value<String?> dependsOn,
  required int createdAt,
  Value<int?> lastAttemptedAt,
  Value<int?> completedAt,
  Value<int> rowid,
});
typedef $$OfflineOperationsTableTableUpdateCompanionBuilder
    = OfflineOperationsTableCompanion Function({
  Value<String> operationId,
  Value<String> operationType,
  Value<String> entityType,
  Value<String> entityLocalId,
  Value<String> payloadJson,
  Value<String> status,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<String?> lastError,
  Value<String> idempotencyKey,
  Value<String?> dependsOn,
  Value<int> createdAt,
  Value<int?> lastAttemptedAt,
  Value<int?> completedAt,
  Value<int> rowid,
});

class $$OfflineOperationsTableTableFilterComposer
    extends Composer<_$VetraDatabase, $OfflineOperationsTableTable> {
  $$OfflineOperationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependsOn => $composableBuilder(
      column: $table.dependsOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastAttemptedAt => $composableBuilder(
      column: $table.lastAttemptedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineOperationsTableTableOrderingComposer
    extends Composer<_$VetraDatabase, $OfflineOperationsTableTable> {
  $$OfflineOperationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationType => $composableBuilder(
      column: $table.operationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependsOn => $composableBuilder(
      column: $table.dependsOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastAttemptedAt => $composableBuilder(
      column: $table.lastAttemptedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$OfflineOperationsTableTableAnnotationComposer
    extends Composer<_$VetraDatabase, $OfflineOperationsTableTable> {
  $$OfflineOperationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
      column: $table.operationId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
      column: $table.operationType, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityLocalId => $composableBuilder(
      column: $table.entityLocalId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get dependsOn =>
      $composableBuilder(column: $table.dependsOn, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastAttemptedAt => $composableBuilder(
      column: $table.lastAttemptedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$OfflineOperationsTableTableTableManager extends RootTableManager<
    _$VetraDatabase,
    $OfflineOperationsTableTable,
    OfflineOperationsTableData,
    $$OfflineOperationsTableTableFilterComposer,
    $$OfflineOperationsTableTableOrderingComposer,
    $$OfflineOperationsTableTableAnnotationComposer,
    $$OfflineOperationsTableTableCreateCompanionBuilder,
    $$OfflineOperationsTableTableUpdateCompanionBuilder,
    (
      OfflineOperationsTableData,
      BaseReferences<_$VetraDatabase, $OfflineOperationsTableTable,
          OfflineOperationsTableData>
    ),
    OfflineOperationsTableData,
    PrefetchHooks Function()> {
  $$OfflineOperationsTableTableTableManager(
      _$VetraDatabase db, $OfflineOperationsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineOperationsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineOperationsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineOperationsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> operationId = const Value.absent(),
            Value<String> operationType = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityLocalId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String?> dependsOn = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int?> lastAttemptedAt = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineOperationsTableCompanion(
            operationId: operationId,
            operationType: operationType,
            entityType: entityType,
            entityLocalId: entityLocalId,
            payloadJson: payloadJson,
            status: status,
            retryCount: retryCount,
            maxRetries: maxRetries,
            lastError: lastError,
            idempotencyKey: idempotencyKey,
            dependsOn: dependsOn,
            createdAt: createdAt,
            lastAttemptedAt: lastAttemptedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String operationId,
            required String operationType,
            required String entityType,
            required String entityLocalId,
            required String payloadJson,
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required String idempotencyKey,
            Value<String?> dependsOn = const Value.absent(),
            required int createdAt,
            Value<int?> lastAttemptedAt = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineOperationsTableCompanion.insert(
            operationId: operationId,
            operationType: operationType,
            entityType: entityType,
            entityLocalId: entityLocalId,
            payloadJson: payloadJson,
            status: status,
            retryCount: retryCount,
            maxRetries: maxRetries,
            lastError: lastError,
            idempotencyKey: idempotencyKey,
            dependsOn: dependsOn,
            createdAt: createdAt,
            lastAttemptedAt: lastAttemptedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineOperationsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$VetraDatabase,
        $OfflineOperationsTableTable,
        OfflineOperationsTableData,
        $$OfflineOperationsTableTableFilterComposer,
        $$OfflineOperationsTableTableOrderingComposer,
        $$OfflineOperationsTableTableAnnotationComposer,
        $$OfflineOperationsTableTableCreateCompanionBuilder,
        $$OfflineOperationsTableTableUpdateCompanionBuilder,
        (
          OfflineOperationsTableData,
          BaseReferences<_$VetraDatabase, $OfflineOperationsTableTable,
              OfflineOperationsTableData>
        ),
        OfflineOperationsTableData,
        PrefetchHooks Function()>;
typedef $$SyncMetadataTableTableCreateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  required String entityType,
  Value<int?> lastSyncedAt,
  Value<int> syncVersion,
  Value<int> rowid,
});
typedef $$SyncMetadataTableTableUpdateCompanionBuilder
    = SyncMetadataTableCompanion Function({
  Value<String> entityType,
  Value<int?> lastSyncedAt,
  Value<int> syncVersion,
  Value<int> rowid,
});

class $$SyncMetadataTableTableFilterComposer
    extends Composer<_$VetraDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncVersion => $composableBuilder(
      column: $table.syncVersion, builder: (column) => ColumnFilters(column));
}

class $$SyncMetadataTableTableOrderingComposer
    extends Composer<_$VetraDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncVersion => $composableBuilder(
      column: $table.syncVersion, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetadataTableTableAnnotationComposer
    extends Composer<_$VetraDatabase, $SyncMetadataTableTable> {
  $$SyncMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get syncVersion => $composableBuilder(
      column: $table.syncVersion, builder: (column) => column);
}

class $$SyncMetadataTableTableTableManager extends RootTableManager<
    _$VetraDatabase,
    $SyncMetadataTableTable,
    SyncMetadataTableData,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadataTableData,
      BaseReferences<_$VetraDatabase, $SyncMetadataTableTable,
          SyncMetadataTableData>
    ),
    SyncMetadataTableData,
    PrefetchHooks Function()> {
  $$SyncMetadataTableTableTableManager(
      _$VetraDatabase db, $SyncMetadataTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityType = const Value.absent(),
            Value<int?> lastSyncedAt = const Value.absent(),
            Value<int> syncVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion(
            entityType: entityType,
            lastSyncedAt: lastSyncedAt,
            syncVersion: syncVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityType,
            Value<int?> lastSyncedAt = const Value.absent(),
            Value<int> syncVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetadataTableCompanion.insert(
            entityType: entityType,
            lastSyncedAt: lastSyncedAt,
            syncVersion: syncVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetadataTableTableProcessedTableManager = ProcessedTableManager<
    _$VetraDatabase,
    $SyncMetadataTableTable,
    SyncMetadataTableData,
    $$SyncMetadataTableTableFilterComposer,
    $$SyncMetadataTableTableOrderingComposer,
    $$SyncMetadataTableTableAnnotationComposer,
    $$SyncMetadataTableTableCreateCompanionBuilder,
    $$SyncMetadataTableTableUpdateCompanionBuilder,
    (
      SyncMetadataTableData,
      BaseReferences<_$VetraDatabase, $SyncMetadataTableTable,
          SyncMetadataTableData>
    ),
    SyncMetadataTableData,
    PrefetchHooks Function()>;

class $VetraDatabaseManager {
  final _$VetraDatabase _db;
  $VetraDatabaseManager(this._db);
  $$AnimalsTableTableTableManager get animalsTable =>
      $$AnimalsTableTableTableManager(_db, _db.animalsTable);
  $$DiseaseReportsTableTableTableManager get diseaseReportsTable =>
      $$DiseaseReportsTableTableTableManager(_db, _db.diseaseReportsTable);
  $$AiScansTableTableTableManager get aiScansTable =>
      $$AiScansTableTableTableManager(_db, _db.aiScansTable);
  $$OfflineOperationsTableTableTableManager get offlineOperationsTable =>
      $$OfflineOperationsTableTableTableManager(
          _db, _db.offlineOperationsTable);
  $$SyncMetadataTableTableTableManager get syncMetadataTable =>
      $$SyncMetadataTableTableTableManager(_db, _db.syncMetadataTable);
}
