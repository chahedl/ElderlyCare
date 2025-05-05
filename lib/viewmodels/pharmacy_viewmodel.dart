import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '/models/pharmacy.dart';
import '/services/collect_api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PharmacyViewModel with ChangeNotifier {
  final CollectApiService _apiService = CollectApiService();
  List<Pharmacy> pharmacies = [];
  bool isLoading = false;
  String? error;
  Position? _userPosition;

  Position? get userPosition => _userPosition;

  void setUserPosition(Position position) {
    _userPosition = position;
    notifyListeners();
  }

  Future<void> fetchPharmaciesNearUser() async {
    if (_userPosition == null) {
      error = 'User position not set';
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      error = null;
      notifyListeners();
      pharmacies = await _apiService.getPharmaciesNearUser(_userPosition!);
    } catch (e) {
      error = e.toString();
      // Fallback to mock data with required fields
      pharmacies = [
        Pharmacy(
          name: 'Mock Pharmacy 1',
          address: '123 Mock Street, Tunis',
          phone: '+216 12 345 678',
          latitude: _userPosition!.latitude + 0.01,
          longitude: _userPosition!.longitude + 0.01,
          drugs: ['Paracetamol', 'Ibuprofen'],
        ),
        Pharmacy(
          name: 'Mock Pharmacy 2',
          address: '456 Mock Avenue, Tunis',
          phone: '+216 98 765 432',
          latitude: _userPosition!.latitude + 0.02,
          longitude: _userPosition!.longitude + 0.02,
          drugs: ['Aspirin', 'Antibiotics'],
        ),
      ];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
