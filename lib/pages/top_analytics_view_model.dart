// lib/viewmodels/top_analytics_view_model.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TopAnalyticsViewModel with ChangeNotifier {
  final ApiService _apiService;
  Map<String, dynamic>? _mostBoughtProduct;
  Map<String, dynamic>? _mostBookedDoctor;
  bool _isLoading = false;
  String? _errorMessage;

  TopAnalyticsViewModel(this._apiService);

  Map<String, dynamic>? get mostBoughtProduct => _mostBoughtProduct;
  Map<String, dynamic>? get mostBookedDoctor => _mostBookedDoctor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTopAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final productFuture = _apiService.getMostBoughtProduct();
      final doctorFuture = _apiService.getMostBookedDoctor();
      final results = await Future.wait([productFuture, doctorFuture]);
      _mostBoughtProduct = results[0];
      _mostBookedDoctor = results[1];
    } catch (e) {
      _errorMessage = 'Failed to load top analytics: $e';
      _mostBoughtProduct = {'x': 'No Products', 'y': 0};
      _mostBookedDoctor = {'x': 'No Doctors', 'y': 0};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
