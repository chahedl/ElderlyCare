import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppointmentViewModel extends ChangeNotifier {
  final ApiService apiService;
  bool isLoading = false;
  String errorMessage = '';

  AppointmentViewModel({required this.apiService});

  Future<void> bookAppointment(
    String doctorId,
    DateTime appointmentDateTime,
    String appointmentType,
  ) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await apiService.bookAppointment({
        'doctorId': doctorId,
        'appointmentDateTime': appointmentDateTime.toIso8601String(),
        'appointmentType': appointmentType,
      });
    } catch (e) {
      errorMessage = e.toString();
      print('Error booking appointment: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

extension on ApiService {
  bookAppointment(Map<String, String> map) {}
}
