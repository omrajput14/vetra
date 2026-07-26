class Farmer {
  final String id;
  final String name;
  final String phone;
  final String location;
  final bool isVerified;

  const Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    this.isVerified = true,
  });
}