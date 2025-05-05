class Appointment {
  final String id;
  final String doctorId;
  final String userId;
  final DateTime appointmentDateTime;
  final String appointmentType;
  final String status;
  final String paymentStatus;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.appointmentDateTime,
    required this.appointmentType,
    required this.status,
    required this.paymentStatus,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'],
      doctorId: json['doctorId'],
      userId: json['userId'],
      appointmentDateTime: DateTime.parse(json['appointmentDateTime']),
      appointmentType: json['appointmentType'],
      status: json['status'],
      paymentStatus: json['paymentStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'doctorId': doctorId,
      'userId': userId,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'appointmentType': appointmentType,
      'status': status,
      'paymentStatus': paymentStatus,
    };
  }
}
