import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DistanceService {
  final String apiKey;

  DistanceService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      throw ArgumentError('OpenRouteService API key cannot be empty');
    }
  }

  Future<Map<String, dynamic>> fetchDistances(
    double originLat,
    double originLon,
    double destLat,
    double destLon,
  ) async {
    const baseUrl = 'https://api.openrouteservice.org/v2/directions';
    final modes = {
      'walking': 'foot-walking',
      'driving': 'driving-car',
      'cycling': 'cycling-regular', // Used as proxy for motorcycle
    };
    final distances = <String, dynamic>{};

    for (var mode in modes.keys) {
      final profile = modes[mode];
      final url =
          '$baseUrl/$profile?api_key=$apiKey&start=$originLon,$originLat&end=$destLon,$destLat';

      try {
        final response =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['features'] != null && data['features'].isNotEmpty) {
            final feature = data['features'][0];
            final distance = feature['properties']['segments'][0]['distance'] /
                1000; // Convert meters to km
            final duration = feature['properties']['segments'][0]['duration'] /
                60; // Convert seconds to minutes
            distances[mode] = {
              'distance': '${distance.toStringAsFixed(1)} km',
              'duration': '${duration.toStringAsFixed(0)} mins',
            };
          } else {
            distances[mode] = {'error': 'No route found'};
          }
        } else {
          distances[mode] = {'error': 'HTTP error: ${response.statusCode}'};
        }
      } catch (e) {
        distances[mode] = {'error': 'Failed to fetch: $e'};
      }
    }

    return distances;
  }
}
