class AnimalModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String? animalName;
  final String tagNumber;
  final String? qrCodeId;
  final String species;
  final String? breed;
  final String gender;
  final String? status;
  final String? birthDate;
  final String? photoUrl;
  final String? localPhotoPath;
  final String createdAt;
  final String updatedAt;

  /// Saved on this device only; the server has not received it yet.
  final bool isPendingSync;

  AnimalModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    this.animalName,
    required this.tagNumber,
    this.qrCodeId,
    required this.species,
    this.breed,
    required this.gender,
    this.status = 'ACTIVE',
    this.birthDate,
    this.photoUrl,
    this.localPhotoPath,
    required this.createdAt,
    required this.updatedAt,
    this.isPendingSync = false,
  });

  String get displayName => (animalName != null && animalName!.isNotEmpty) ? animalName! : tagNumber;

  bool get isDeceased => status?.toUpperCase() == 'DECEASED';

  AnimalModel copyWith({
    String? status,
    String? photoUrl,
    String? localPhotoPath,
  }) {
    return AnimalModel(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      animalName: animalName,
      tagNumber: tagNumber,
      qrCodeId: qrCodeId,
      species: species,
      breed: breed,
      gender: gender,
      status: status ?? this.status,
      birthDate: birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPendingSync: isPendingSync,
    );
  }

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'].toString(),
      farmerId: json['farmerId']?.toString() ?? '',
      farmerName: json['farmerName']?.toString() ?? 'Owner',
      animalName: json['animalName']?.toString(),
      tagNumber: json['tagNumber']?.toString() ?? '',
      qrCodeId: json['qrCodeId']?.toString(),
      species: json['species']?.toString() ?? 'CATTLE',
      breed: json['breed']?.toString(),
      gender: json['gender']?.toString() ?? 'FEMALE',
      status: json['status']?.toString() ?? 'ACTIVE',
      birthDate: json['birthDate']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      localPhotoPath: json['localPhotoPath']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'animalName': animalName,
      'tagNumber': tagNumber,
      'qrCodeId': qrCodeId,
      'species': species,
      'breed': breed,
      'gender': gender,
      'status': status,
      'birthDate': birthDate,
      'photoUrl': photoUrl,
      'localPhotoPath': localPhotoPath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
