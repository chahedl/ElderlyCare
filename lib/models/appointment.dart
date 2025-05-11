// lib/models/appointment.dart
import 'package:pim/models/doctor.dart';

class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final DateTime date;
  final String time;
  final String meetingType;
  final String paymentStatus;
  final String paymentIntentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Doctor? doctor; // Populated doctor details

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.date,
    required this.time,
    required this.meetingType,
    required this.paymentStatus,
    required this.paymentIntentId,
    required this.createdAt,
    required this.updatedAt,
    this.doctor,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      doctorId: json['doctorId']['_id'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      meetingType: json['meetingType'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentIntentId: json['paymentIntentId'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      doctor: json['doctorId'] != null && json['doctorId'] is Map
          ? Doctor.fromJson(json['doctorId'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'doctorId': doctorId,
      'date': date.toIso8601String(),
      'time': time,
      'meetingType': meetingType,
      'paymentStatus': paymentStatus,
      'paymentIntentId': paymentIntentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
