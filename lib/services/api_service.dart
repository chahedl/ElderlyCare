// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final int _timeoutSeconds = 30;
  final int _maxRetries = 2;

  ApiService({required this.baseUrl});

  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json'};
  }

  Future<http.Response> _makeRequest(
      Future<http.Response> Function() request) async {
    int attempt = 0;
    while (true) {
      try {
        final response =
            await request().timeout(Duration(seconds: _timeoutSeconds));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        attempt++;
        if (attempt >= _maxRetries) {
          throw Exception(
              'Request failed with status ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  // Fetch most bought product
  Future<Map<String, dynamic>> getMostBoughtProduct() async {
    final uri = Uri.parse('$baseUrl/cart/analytics/most-bought');
    final response = await _makeRequest(
      () => http.get(uri, headers: _getHeaders()),
    );
    try {
      final json = jsonDecode(response.body);
      return {
        'x': json['x']?.toString() ?? 'No Products',
        'y': (json['y'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      print('Error parsing most bought product: $e');
      return {'x': 'No Products', 'y': 0};
    }
  }

  // Fetch most booked doctor
  Future<Map<String, dynamic>> getMostBookedDoctor() async {
    final uri = Uri.parse('$baseUrl/appointments/analytics/most-booked');
    final response = await _makeRequest(
      () => http.get(uri, headers: _getHeaders()),
    );
    try {
      final json = jsonDecode(response.body);
      return {
        'x': json['x']?.toString() ?? 'No Doctors',
        'y': (json['y'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      print('Error parsing most booked doctor: $e');
      return {'x': 'No Doctors', 'y': 0};
    }
  }

  // Existing methods (unchanged)
  Future<List<Map<String, dynamic>>> getSpecializationAnalytics() async {
    final uri = Uri.parse('$baseUrl/doctors/analytics/specialization');
    final response = await _makeRequest(
      () => http.get(uri, headers: _getHeaders()),
    );
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');
    try {
      final List<dynamic> jsonList = json.decode(response.body);
      print('Parsed JSON: $jsonList');
      return jsonList
          .map((e) => {
                'x': e['x']?.toString() ?? 'Unknown',
                'y': (e['y'] as num?)?.toInt() ?? 0,
              })
          .toList();
    } catch (e) {
      print('Parsing Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBMIAnalytics() async {
    final uri = Uri.parse('$baseUrl/users/analytics/bmi');
    final response = await _makeRequest(
      () => http.get(uri, headers: _getHeaders()),
    );
    print('BMI Response Status: ${response.statusCode}');
    print('BMI Response Body: ${response.body}');
    try {
      final List<dynamic> jsonList = json.decode(response.body);
      print('Parsed BMI JSON: $jsonList');
      return jsonList
          .map((e) => {
                'x': e['x']?.toString() ?? 'Unknown',
                'y': (e['y'] as num?)?.toInt() ?? 0,
              })
          .toList();
    } catch (e) {
      print('BMI Parsing Error: $e');
      return [];
    }
  }

  Future<int> getTotalProducts() async {
    final uri = Uri.parse('$baseUrl/products/count');
    final response = await _makeRequest(
      () => http.get(uri, headers: _getHeaders()),
    );
    try {
      final data = json.decode(response.body);
      return data['count'] as int;
    } catch (e) {
      print('Error parsing total products: $e');
      return 0;
    }
  }

  Future<int> getTotalUsers() async {
    final uri = Uri.parse('$baseUrl/users/count');
    final response = await _makeRequest(
      () => http.get(uri, headers: _getHeaders()),
    );
    try {
      final data = json.decode(response.body);
      return data['count'] as int;
    } catch (e) {
      print('Error parsing total users: $e');
      return 0;
    }
  }
}
