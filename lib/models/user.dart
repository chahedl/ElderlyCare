enum Role {
  user,
  doctor,
  admin,
}

enum ChronicIllness {
  diabetes,
  hypertension,
  asthma,
}

class User {
  String? email;
  String? password;
  String? username;
  DateTime? birthDate; // Made nullable
  List<ChronicIllness> chronicIllnesses;
  double? weight;
  double? height;
  final String? profilePic;
  final Role role;

  User({
    this.email,
    this.password,
    this.username,
    this.birthDate,
    required this.chronicIllnesses,
    this.weight,
    this.height,
    this.profilePic,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle nested 'user' object
    final userJson = json['user'] as Map<String, dynamic>? ?? json;
    print('Parsing JSON: $userJson'); // Debug JSON structure

    return User(
      email: userJson['email'] as String? ?? '',
      password: userJson['password'] as String? ?? '',
      username: userJson['username'] as String? ?? '',
      birthDate: userJson['birthDate'] != null
          ? DateTime.tryParse(userJson['birthDate'] as String)
          : null,
      chronicIllnesses:
          (userJson['chronicIllnesses'] as List<dynamic>?)?.map((illness) {
                try {
                  return ChronicIllness.values.firstWhere(
                    (e) => e.toString().split('.').last == illness,
                    orElse: () => ChronicIllness.diabetes,
                  );
                } catch (e) {
                  print('Error parsing chronic illness: $illness, error: $e');
                  return ChronicIllness.diabetes;
                }
              }).toList() ??
              [],
      weight: (userJson['weight'] as num?)?.toDouble(),
      height: (userJson['height'] as num?)?.toDouble(),
      profilePic: userJson['profilePic'] as String?,
      role: userJson['role'] != null
          ? Role.values.firstWhere(
              (e) =>
                  e.toString().split('.').last ==
                  (userJson['role'] as String).toLowerCase(),
              orElse: () => Role.user,
            )
          : Role.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'birthDate': birthDate?.toIso8601String(),
      'chronicIllnesses': chronicIllnesses
          .map((illness) => illness.toString().split('.').last)
          .toList(),
      'weight': weight,
      'height': height,
      'profilePic': profilePic,
      'role': role.toString().split('.').last,
    };
  }
}
