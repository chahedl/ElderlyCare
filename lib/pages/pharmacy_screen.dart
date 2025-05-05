import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '/models/pharmacy.dart';
import '/viewmodels/pharmacy_viewmodel.dart';
import 'package:provider/provider.dart';
import '/services/weather_service.dart';
import '/services/distance_service.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  late PharmacyViewModel _viewModel;
  late WeatherService _weatherService;
  late DistanceService _distanceService;
  Position? _currentPosition;
  latlong.LatLng? _initialPosition;
  Pharmacy? _selectedPharmacy;
  StreamSubscription<Position>? _positionStream;
  bool _hasLeftGeofence = false;
  static const double _geofenceRadius = 1500.0;
  Map<String, dynamic>? _weatherData;
  String? _weatherError;
  bool _usingMockData = false;
  Map<String, dynamic>? _distances;
  String? _distanceError;
  bool _isDetailsVisible = true;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PharmacyViewModel>(context, listen: false);
    _weatherService = Provider.of<WeatherService>(context, listen: false);
    _distanceService = Provider.of<DistanceService>(context, listen: false);
    _getUserLocation();
    _startPositionStream();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _initialPosition =
            latlong.LatLng(position.latitude, position.longitude);
      });
      _viewModel.setUserPosition(position);
      await _viewModel.fetchPharmaciesNearUser();
      if (_viewModel.pharmacies.isNotEmpty &&
          _viewModel.pharmacies.any((p) => p.name.contains("Mock"))) {
        setState(() {
          _usingMockData = true;
        });
      }
      await _fetchWeather();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _currentPosition = Position(
          latitude: 36.8065,
          longitude: 10.1815,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        _initialPosition = latlong.LatLng(36.8065, 10.1815);
      });
      _viewModel.setUserPosition(_currentPosition!);
      await _viewModel.fetchPharmaciesNearUser();
      if (_viewModel.pharmacies.isNotEmpty &&
          _viewModel.pharmacies.any((p) => p.name.contains("Mock"))) {
        setState(() {
          _usingMockData = true;
        });
      }
      await _fetchWeather();
    }
  }

  void _startPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = position;
      });

      if (_initialPosition != null) {
        final distance = const latlong.Distance().as(
          latlong.LengthUnit.Meter,
          _initialPosition!,
          latlong.LatLng(position.latitude, position.longitude),
        );

        if (distance > _geofenceRadius && !_hasLeftGeofence) {
          _hasLeftGeofence = true;
          _showGeofenceAlert();
        } else if (distance <= _geofenceRadius && _hasLeftGeofence) {
          _hasLeftGeofence = false;
        }
      }
    });
  }

  void _showGeofenceAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text(
            'You have left the safe area! Please return to your starting location.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchWeather() async {
    if (_currentPosition != null) {
      try {
        final weather = await _weatherService.fetchWeather(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        setState(() {
          _weatherData = weather;
          _weatherError = null;
        });
      } catch (e) {
        setState(() {
          _weatherError = 'Failed to load weather: $e';
        });
      }
    }
  }

  Future<void> _fetchDistances(Pharmacy pharmacy) async {
    if (_currentPosition != null) {
      try {
        final distances = await _distanceService.fetchDistances(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          pharmacy.latitude,
          pharmacy.longitude,
        );
        setState(() {
          _distances = distances;
          _distanceError = null;
        });
      } catch (e) {
        setState(() {
          _distanceError = 'Failed to load distances: $e';
        });
      }
    }
  }

  void _selectPharmacy(Pharmacy pharmacy) {
    setState(() {
      _selectedPharmacy = pharmacy;
      _isDetailsVisible = true; // Show details when a pharmacy is selected
    });
    _fetchDistances(pharmacy);
  }

  void _navigateToPharmacy(Pharmacy pharmacy) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${pharmacy.latitude},${pharmacy.longitude}';
    await _viewModel.openUrl(url);
  }

  void _toggleDetailsVisibility() {
    setState(() {
      _isDetailsVisible = !_isDetailsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies Near Me'),
      ),
      body: Consumer<PharmacyViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Weather Display Card
              Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _weatherError != null
                      ? Text(_weatherError!,
                          style: const TextStyle(color: Colors.red))
                      : _weatherData != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${_weatherData!['main']['temp']?.round()}°C',
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(_weatherData!['weather'][0]
                                        ['description']),
                                  ],
                                ),
                                Text(
                                    'Humidity: ${_weatherData!['main']['humidity']}%'),
                                Text(
                                    'Wind: ${_weatherData!['wind']['speed']} m/s'),
                              ],
                            )
                          : const CircularProgressIndicator(),
                ),
              ),

              // Pharmacy Dropdown (Hidden when details are not visible)
              if (_isDetailsVisible)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<Pharmacy>(
                    decoration: InputDecoration(
                      labelText: _usingMockData
                          ? 'Select a Pharmacy (Mock Data)'
                          : 'Select a Pharmacy',
                      border: const OutlineInputBorder(),
                    ),
                    value: _selectedPharmacy,
                    onChanged: (Pharmacy? newValue) {
                      if (newValue != null) {
                        _selectPharmacy(newValue);
                      }
                    },
                    items: viewModel.isLoading
                        ? [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Loading...'),
                            )
                          ]
                        : viewModel.pharmacies.isEmpty
                            ? [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('No pharmacies found'),
                                )
                              ]
                            : viewModel.pharmacies.map((pharmacy) {
                                return DropdownMenuItem<Pharmacy>(
                                  value: pharmacy,
                                  child: Text(pharmacy.name),
                                );
                              }).toList(),
                  ),
                ),

              // Distance and Drugs Display Card (Hidden when details are not visible)
              if (_selectedPharmacy != null && _isDetailsVisible)
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _distanceError != null
                        ? Text(_distanceError!,
                            style: const TextStyle(color: Colors.red))
                        : _distances != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Details for ${_selectedPharmacy!.name}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Distance Information
                                  Text(
                                    'Distance and Travel Time',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  _buildDistanceRow(
                                      'Walking', _distances!['walking']),
                                  _buildDistanceRow(
                                      'Driving (Car)', _distances!['driving']),
                                  _buildDistanceRow('Cycling (Motorcycle)',
                                      _distances!['cycling']),
                                  const SizedBox(height: 8),
                                  // Drugs Information
                                  Text(
                                    'Available Drugs',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  ..._selectedPharmacy!.drugs
                                      .map((drug) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                            child: Text('• $drug'),
                                          )),
                                ],
                              )
                            : const CircularProgressIndicator(),
                  ),
                ),

              // Map with Toggle Button
              Expanded(
                child: Stack(
                  children: [
                    _currentPosition == null
                        ? const Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            options: MapOptions(
                              initialCenter: latlong.LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              initialZoom: 13.0,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _selectedPharmacy = null;
                                  _distances = null;
                                  _distanceError = null;
                                  _isDetailsVisible =
                                      true; // Show details when map is tapped
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              CircleLayer(
                                circles: [
                                  if (_initialPosition != null)
                                    CircleMarker(
                                      point: _initialPosition!,
                                      radius: _geofenceRadius,
                                      color: Colors.blue.withOpacity(0.2),
                                      borderStrokeWidth: 2.0,
                                      borderColor: Colors.blue,
                                      useRadiusInMeter: true,
                                    ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: latlong.LatLng(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                    ),
                                    width: 80,
                                    height: 80,
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Colors.blue,
                                      size: 40,
                                    ),
                                  ),
                                  ...viewModel.pharmacies.map((pharmacy) {
                                    return Marker(
                                      point: latlong.LatLng(pharmacy.latitude,
                                          pharmacy.longitude),
                                      width: 80,
                                      height: 80,
                                      child: GestureDetector(
                                        onTap: () => _selectPharmacy(pharmacy),
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            _selectedPharmacy == pharmacy
                                                ? Colors.green
                                                : Colors.red,
                                            BlendMode.modulate,
                                          ),
                                          child: Image.asset(
                                            'assets/images/pharmacy_icon.png',
                                            width: 20,
                                            height: 20,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              PolylineLayer(
                                polylines: [
                                  if (_selectedPharmacy != null)
                                    Polyline(
                                      points: [
                                        latlong.LatLng(
                                          _currentPosition!.latitude,
                                          _currentPosition!.longitude,
                                        ),
                                        latlong.LatLng(
                                          _selectedPharmacy!.latitude,
                                          _selectedPharmacy!.longitude,
                                        ),
                                      ],
                                      strokeWidth: 4.0,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                            ],
                          ),
                    // Toggle Button in Bottom-Left Corner
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _toggleDetailsVisibility,
                        child: Icon(
                          _isDetailsVisible
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Button (Hidden when details are not visible)
              if (_selectedPharmacy != null && _isDetailsVisible)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _navigateToPharmacy(_selectedPharmacy!),
                    child: const Text('Navigate to Pharmacy'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDistanceRow(String mode, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(mode, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            data['error'] ?? '${data['distance']} (${data['duration']})',
            style: TextStyle(
              color: data['error'] != null ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
