// lib/models/medication.dart
class Medication {
  final int? id;
  final String name;
  final String dosage;
  final DateTime time;
  final String frequency;
  final bool isTaken;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    this.isTaken = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time.toIso8601String(),
      'frequency': frequency,
      'isTaken': isTaken ? 1 : 0,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      time: DateTime.parse(map['time']),
      frequency: map['frequency'],
      isTaken: map['isTaken'] == 1,
    );
  }
}
