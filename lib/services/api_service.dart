import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/user.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:2000/api'; // Updated with local IP
  final String token;
  final int timeoutSeconds = 30;
  final int maxRetries = 2;

  ApiService(this.token);

  Future<http.Response> _makeRequest(
      Future<http.Response> Function() request) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response =
            await request().timeout(Duration(seconds: timeoutSeconds));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        print(
            'Request failed (attempt ${attempt + 1}): ${response.statusCode}');
      } catch (e) {
        print('Request error (attempt ${attempt + 1}): $e');
      }
      attempt++;
      if (attempt < maxRetries) {
        await Future.delayed(Duration(seconds: 2));
      }
    }
    throw Exception('Request failed after $maxRetries attempts');
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, X-Auth-Token'
    };
  }

  Future<String> signup(User user) async {
    try {
      final response = await _makeRequest(() => http.post(
            Uri.parse('$baseUrl/users/register'),
            headers: _getHeaders(),
            body: json.encode(user.toJson()),
          ));

      final data = json.decode(response.body);
      return data['token'];
    } catch (e) {
      print('Error during signup: $e');
      throw Exception('Failed to signup: $e');
    }
  }

  Future<String> login(String email, String password) async {
    try {
      final response = await _makeRequest(() => http.post(
            Uri.parse('$baseUrl/users/login'),
            headers: _getHeaders(),
            body: json.encode({'email': email, 'password': password}),
          ));

      final data = json.decode(response.body);
      return data['token'];
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> getUser() async {
    try {
      final response = await _makeRequest(() => http.get(
            Uri.parse('$baseUrl/users/profile-details'),
            headers: _getHeaders(),
          ));

      return User.fromJson(json.decode(response.body));
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> updateUserProfile(User user) async {
    try {
      await _makeRequest(() => http.put(
            Uri.parse('$baseUrl/users/profile-update'),
            headers: _getHeaders(),
            body: json.encode(user.toJson()),
          ));
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user: $e');
    }
  }
}
