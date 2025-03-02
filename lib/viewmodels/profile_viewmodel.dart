import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfileViewModel extends ChangeNotifier {
  User? user;
  String? errorMessage;
  bool isLoading = false;
  final String token;
  bool _disposed = false;

  ProfileViewModel(this.token);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> fetchUserData() async {
    isLoading = true;
    _safeNotifyListeners();

    final apiService = ApiService(token); // Updated instantiation
    
    try {
      user = await apiService.getUser();
      if (user == null) {
        errorMessage = 'User data is incomplete';
      }
    } catch (e) {
      errorMessage = 'Error fetching user data: $e';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  void updateUsername(String value) {
    if (user != null) {
      user!.username = value;
      _safeNotifyListeners();
    }
  }

  void updateEmail(String value) {
    if (user != null) {
      user!.email = value;
      _safeNotifyListeners();
    }
  }

  void updateWeight(String value) {
    if (user != null) {
      user!.weight = double.tryParse(value) ?? user!.weight;
      _safeNotifyListeners();
    }
  }

  void updateHeight(String value) {
    if (user != null) {
      user!.height = double.tryParse(value) ?? user!.height;
      _safeNotifyListeners();
    }
  }

  Future<void> updateUserProfile() async {
    if (user == null) {
      errorMessage = 'User data is incomplete, cannot update profile.';
      _safeNotifyListeners();
      return;
    }

    final apiService = ApiService(token); // Updated instantiation
    
    try {
      await apiService.updateUserProfile(user!);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error updating user profile: $e';
    }

    _safeNotifyListeners();
  }
}
