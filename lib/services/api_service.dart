import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product_model.dart'; // Import the Product model
import 'notification_service.dart';

class ApiService {
  final String baseUrl = 'http://localhost:2000/api'; // Updated to use localhost

  Future<List<Product>> getProducts() async { 
    // Fetch products from the backend
    try {
      final response = await _makeRequest(() => http.get(
        Uri.parse('$baseUrl/products'),
        headers: _getHeaders(),
      ));

      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
  final String token;
  final int timeoutSeconds = 30;
  final int maxRetries = 2;
  final NotificationService notificationService; // Injected dependency

  ApiService(this.token, this.notificationService);

  Future<http.Response> _makeRequest(Future<http.Response> Function() request) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final response = await request().timeout(Duration(seconds: timeoutSeconds));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        print('Request failed (attempt ${attempt + 1}): ${response.statusCode}');
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
      print('Attempting to log in with email: $email');
      final response = await _makeRequest(() => http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: _getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      ));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);
      final token = data['token'];

      // ✅ Fetch and show a motivational quote
      String quote = await fetchMotivationalQuote();
      await notificationService.showNotification('Motivational Quote', quote);

      return token;
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

  Future<String> fetchMotivationalQuote() async {
    try {
      final response = await http.get(Uri.parse('https://qapi.vercel.app/api/random')); // No headers needed

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final quote = data['quote'];

        // Show notification with the quote
        await notificationService.showNotification('Motivational Quote', quote);

        return quote;
      } else {
        print('Failed to fetch quote, using fallback.');
        return 'Every day is a new opportunity to grow and improve.';
      }
    } catch (e) {
      print('Error fetching quote: $e');
      return 'Challenges are what make life interesting. Overcoming them is what makes life meaningful.';
    }
  }

  /// Call this method on **app launch** to show a motivational quote
  Future<void> showQuoteOnAppLaunch() async {
    try {
      String quote = await fetchMotivationalQuote();
      await notificationService.showNotification('Motivational Quote', quote);
    } catch (e) {
      print('Error showing quote on app launch: $e');
    }
  }
}
