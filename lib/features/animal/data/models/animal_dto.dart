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
  final String? birthDate;
  final String? photoUrl;
  final String createdAt;
  final String updatedAt;

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
    this.birthDate,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => (animalName != null && animalName!.isNotEmpty) ? animalName! : tagNumber;

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
      birthDate: json['birthDate']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
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
      'birthDate': birthDate,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
