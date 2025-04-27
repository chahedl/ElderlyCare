import 'package:flareline_uikit/core/mvvm/base_viewmodel.dart';
import 'package:flareline_uikit/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class SignInProvider extends BaseViewModel {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final GetStorage _storage = GetStorage();
  bool _isLoading = false;

  // Getter for isLoading
  bool get isLoading => _isLoading;

  SignInProvider(BuildContext ctx) : super(ctx) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      SnackBarUtil.showSnack(context, 'Please fill in all fields');
      return;
    }

    _isLoading = true;
    notifyListeners(); // Notify UI of loading state change

    try {
      final response = await http.post(
        Uri.parse('http://localhost:2000/api/users/login'), // Backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login successful
        final user = responseData['user'];
        final token = responseData['token'];

        // Check if the user is an ADMIN
        if (user['role'] == 'ADMIN') {
          // Store the token for future requests
          await _storage.write('token', token);
          await _storage.write('userRole', user['role']);

          // Navigate to the dashboard
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          SnackBarUtil.showSnack(
              context, 'Access denied: You are not an admin');
        }
      } else {
        // Login failed
        SnackBarUtil.showSnack(
            context, responseData['message'] ?? 'Login failed');
      }
    } catch (error) {
      print('Error during sign-in: $error');
      SnackBarUtil.showSnack(context, 'An error occurred. Please try again.');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is complete
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    SnackBarUtil.showSnack(context, 'Sign In With Google - Not Implemented');
  }

  Future<void> signInWithGithub(BuildContext context) async {
    SnackBarUtil.showSnack(context, 'Sign In With Github - Not Implemented');
  }

  // Logout method
  Future<void> logout(BuildContext context) async {
    await _storage.remove('token');
    await _storage.remove('userRole');
    Navigator.of(context).pushReplacementNamed('/signIn');
  }
}
