import 'package:flutter/material.dart';
import '/services/api_service.dart';

class BMIViewModel extends ChangeNotifier {
  final ApiService apiService;
  List<Map<String, dynamic>> bmiStats = [];
  bool isLoading = false;
  String? errorMessage;

  BMIViewModel(this.apiService);

  Future<void> fetchBMIAnalytics() async {
    isLoading = true;
    errorMessage = null;
    bmiStats = [];
    notifyListeners();

    try {
      bmiStats = await apiService.getBMIAnalytics();
      print('BMI Stats: $bmiStats');
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load BMI data: $e';
      print('BMI ViewModel Error: $e');
      notifyListeners();
    }
  }
}
