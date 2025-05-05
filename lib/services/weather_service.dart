import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey;
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }
  }

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    _validateCoordinates(lat, lon);

    final url =
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseWeatherResponse(response.body);
      } else {
        throw WeatherException(
          'API request failed with status ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw WeatherException('Network error: ${e.message}', 0);
    } on FormatException {
      throw WeatherException('Invalid API response format', 0);
    } catch (e) {
      // This will catch TimeoutException and any other unexpected errors
      throw WeatherException('Unexpected error: $e', 0);
    }
  }

  Map<String, dynamic> _parseWeatherResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      // Validate required fields
      if (data['main'] == null || data['weather'] == null) {
        throw WeatherException('Invalid weather data format', 0);
      }

      return data;
    } on FormatException {
      throw WeatherException('Failed to parse weather data', 0);
    }
  }

  void _validateCoordinates(double lat, double lon) {
    if (lat < -90 || lat > 90) {
      throw ArgumentError('Latitude must be between -90 and 90');
    }
    if (lon < -180 || lon > 180) {
      throw ArgumentError('Longitude must be between -180 and 180');
    }
  }
}

class WeatherException implements Exception {
  final String message;
  final int statusCode;

  WeatherException(this.message, this.statusCode);

  @override
  String toString() => 'WeatherException: $message (Status: $statusCode)';
}
