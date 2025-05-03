import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmacy/models/pharmacy.dart';
import 'package:pharmacy/services/collect_api_service.dart';
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}