class Pharmacy {
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final List<String> drugs;

  Pharmacy({
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    this.drugs = const [],
  });
}
