import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:pharmacy/models/pharmacy.dart';
import 'dart:math';

class CollectApiService {
  Future<List<Pharmacy>> getPharmaciesNearUser(Position position) async {
    const url = 'https://overpass.kumi.systems/api/interpreter';
    final south = position.latitude - 0.2;
    final north = position.latitude + 0.2;
    final west = position.longitude - 0.2;
    final east = position.longitude + 0.2;

    final query = '''
      [out:json][timeout:30];
      node["amenity"="pharmacy"]($south,$west,$north,$east);
      out center;
    ''';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: query,
        headers: {'Content-Type': 'text/plain'},
      );

      print('Overpass API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> elements = data['elements'] ?? [];
        final List<Pharmacy> pharmacies = [];

        // Pool of Alzheimer’s-related and normal drugs
        const List<String> drugPool = [
          // Alzheimer’s-related drugs
          'Donepezil', 'Rivastigmine', 'Galantamine', 'Memantine', 'Tacrine',
          'Vitamin E', 'Selegiline', 'Namzaric', 'Huperzine A', 'Ginkgo Biloba',
          // Normal drugs
          'Paracetamol', 'Ibuprofen', 'Aspirin', 'Amoxicillin', 'Cetirizine',
          'Omeprazole', 'Lisinopril', 'Metformin', 'Simvastatin', 'Loratadine',
        ];

        final random = Random();
        for (var element in elements) {
          final latitude = element['lat'] as double? ?? element['center']['lat'] as double;
          final longitude = element['lon'] as double? ?? element['center']['lon'] as double;
          final name = element['tags']['name']?.toString() ?? 'Unknown Pharmacy';
          final address = element['tags']['address']?.toString() ?? 'No address';

          // Filter out invalid names
          if (name != 'Unknown Pharmacy' && RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(name)) {
            // Select 10 unique random drugs
            final availableDrugs = <String>[];
            final drugIndices = <int>{};
            while (drugIndices.length < 10 && drugIndices.length < drugPool.length) {
              final index = random.nextInt(drugPool.length);
              drugIndices.add(index);
            }
            for (var index in drugIndices) {
              availableDrugs.add(drugPool[index]);
            }

            pharmacies.add(Pharmacy(
              name: name,
              address: address,
              phone: element['tags']['phone']?.toString() ?? 'No phone',
              latitude: latitude,
              longitude: longitude,
              drugs: availableDrugs,
            ));
          }
        }

        print('Pharmacies found: ${pharmacies.length}');

        // Fallback to mock data only if no valid pharmacies are found
        if (pharmacies.isEmpty) {
          print('No valid pharmacies found in OSM. Returning mock data.');
          return [
            Pharmacy(
              name: "Mock Pharmacy 1",
              address: "123 Tunis St, Tunis",
              phone: "123-456-7890",
              latitude: position.latitude + 0.01,
              longitude: position.longitude + 0.01,
              drugs: _getRandomDrugs(drugPool, random),
            ),
            Pharmacy(
              name: "Mock Pharmacy 2",
              address: "456 Avenue Habib Bourguiba, Tunis",
              phone: "987-654-3210",
              latitude: position.latitude - 0.01,
              longitude: position.longitude - 0.01,
              drugs: _getRandomDrugs(drugPool, random),
            ),
          ];
        }

        return pharmacies;
      } else {
        throw Exception('Failed to fetch pharmacies: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pharmacies: $e');
      throw Exception('Failed to fetch pharmacies: $e');
    }
  }

  // Helper function to get 10 random drugs
  List<String> _getRandomDrugs(List<String> drugPool, Random random) {
    final drugIndices = <int>{};
    while (drugIndices.length < 10 && drugIndices.length < drugPool.length) {
      final index = random.nextInt(drugPool.length);
      drugIndices.add(index);
    }
    return drugIndices.map((index) => drugPool[index]).toList();
  }
}