import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final ApiService apiService;
  List<Map<String, dynamic>> stats = [];
  bool isLoading = false;
  String? errorMessage;

  AnalyticsViewModel(this.apiService);

  Future<void> fetchAnalytics() async {
    isLoading = true;
    errorMessage = null;
    stats = [];
    notifyListeners();

    try {
      stats = await apiService.getSpecializationAnalytics();
      print('ViewModel Stats: $stats');
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load data: $e';
      print('ViewModel Error: $e');
      notifyListeners();
    }
  }
}
