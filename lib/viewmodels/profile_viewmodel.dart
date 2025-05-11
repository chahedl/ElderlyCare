import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ProfileViewModel extends ChangeNotifier {
  User? user;
  String? errorMessage;
  bool isLoading = false;
  final String token;
  final NotificationService notificationService;

  ProfileViewModel(this.token) : notificationService = NotificationService();

  Future<void> fetchUserData() async {
    final apiService = ApiService(token, notificationService);
    isLoading = true;
    notifyListeners();

    try {
      user = await apiService.getUser();
      if (user == null || user!.username == null || user!.email == null) {
        errorMessage = 'Incomplete user data. Please try again.';
      }
    } catch (e) {
      errorMessage = 'Failed to load profile: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateUsername(String value) {
    if (user != null) {
      user!.username = value.isEmpty ? null : value;
      notifyListeners();
    }
  }

  void updateEmail(String value) {
    if (user != null) {
      user!.email = value.isEmpty ? null : value;
      notifyListeners();
    }
  }

  void updateWeight(String value) {
    if (user != null) {
      user!.weight = double.tryParse(value) ?? user!.weight;
      notifyListeners();
    }
  }

  void updateHeight(String value) {
    if (user != null) {
      user!.height = double.tryParse(value) ?? user!.height;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile() async {
    if (user == null) {
      errorMessage = 'No user data to update';
      notifyListeners();
      return;
    }

    final apiService = ApiService(token, notificationService);

    try {
      await apiService.updateUserProfile(user!);
      errorMessage = 'Profile updated successfully';
    } catch (e) {
      errorMessage = 'Failed to update profile: $e';
    }

    notifyListeners();
  }
}
