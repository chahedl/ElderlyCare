// lib/viewmodels/appointment_viewmodel.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class AppointmentViewModel extends ChangeNotifier {
  final ApiService apiService;
  List<Appointment> appointments = [];
  bool isLoading = false;
  String errorMessage = '';

  AppointmentViewModel({required this.apiService});

  Future<void> fetchAppointments() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final appointmentData = await apiService.getAppointments();
      appointments =
          appointmentData.map((data) => Appointment.fromJson(data)).toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
