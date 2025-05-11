import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart'; // Added for sharing horoscopes

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({Key? key}) : super(key: key);

  @override
  _HoroscopeScreenState createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  String? horoscope;
  String? date;
  String? zodiac;
  bool isLoading = true;
  String? errorMessage;
  String selectedSign = 'aries';
  List<Map<String, String>> horoscopeHistory = []; // Store recent horoscopes

  final List<String> zodiacSigns = [
    'aries',
    'taurus',
    'gemini',
    'cancer',
    'leo',
    'virgo',
    'libra',
    'scorpio',
    'sagittarius',
    'capricorn',
    'aquarius',
    'pisces'
  ];

  // Map zodiac signs to icons
  IconData getZodiacIcon(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
        return Icons.whatshot;
      case 'taurus':
        return Icons.pets;
      case 'gemini':
        return Icons.chat;
      case 'cancer':
        return Icons.waves;
      case 'leo':
        return Icons.star;
      case 'virgo':
        return Icons.grass;
      case 'libra':
        return Icons.balance;
      case 'scorpio':
        return Icons.bug_report;
      case 'sagittarius':
        return Icons.explore;
      case 'capricorn':
        return Icons.terrain;
      case 'aquarius':
        return Icons.water;
      case 'pisces':
        return Icons.bubble_chart;
      default:
        return Icons.star;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHoroscope();
  }

  Future<void> _fetchHoroscope() async {
    const apiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
    final apiUrl =
        'https://api.api-ninjas.com/v1/horoscope?zodiac=$selectedSign';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      print('Horoscope API Response Status: ${response.statusCode}');
      print('Horoscope API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          horoscope = data['horoscope'] ?? 'No horoscope available';
          date = data['date'] ?? 'N/A';
          zodiac = data['zodiac'] ?? selectedSign;
          isLoading = false;
          if (horoscope != 'No horoscope available') {
            horoscopeHistory.add({
              'horoscope': horoscope!,
              'date': date!,
              'zodiac': zodiac!,
            });
            if (horoscopeHistory.length > 5) {
              horoscopeHistory.removeAt(0); // Limit to 5 recent horoscopes
            }
          }
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to fetch horoscope: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Horoscope API Error: $e');
      setState(() {
        errorMessage = 'Error fetching horoscope: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Horoscope',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: primaryColor, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Your Daily Horoscope',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedSign,
                        hint: Row(
                          children: [
                            Icon(Icons.star, color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text('Select Zodiac Sign',
                                style: TextStyle(color: primaryColor)),
                          ],
                        ),
                        items: zodiacSigns.map((sign) {
                          return DropdownMenuItem(
                            value: sign,
                            child: Row(
                              children: [
                                Icon(getZodiacIcon(sign),
                                    color: primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(sign.capitalize(),
                                    style:
                                        const TextStyle(color: Colors.black87)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedSign = value;
                              isLoading = true;
                              horoscope = null;
                              date = null;
                              zodiac = null;
                              errorMessage = null;
                            });
                            _fetchHoroscope();
                          }
                        },
                        underline: const SizedBox(),
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 16),
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity:
                        isLoading || errorMessage != null || horoscope != null
                            ? 1.0
                            : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Container(
                        width: constraints.maxWidth,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              primaryColor.withOpacity(0.05)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 4,
                                ),
                              )
                            : errorMessage != null
                                ? Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.red[200]!),
                                    ),
                                    child: Text(
                                      errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: primaryColor, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Date: ${date ?? 'N/A'}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                              getZodiacIcon(
                                                  zodiac ?? selectedSign),
                                              color: primaryColor,
                                              size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Zodiac: ${zodiac?.capitalize() ?? selectedSign.capitalize()}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.star,
                                              color: primaryColor, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              horoscope ??
                                                  'No horoscope available',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.favorite_border,
                                              color: primaryColor,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              // TODO: Implement favorite functionality
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Favorite feature coming soon!'),
                                                ),
                                              );
                                            },
                                            tooltip: 'Save Horoscope',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.share,
                                              color: primaryColor,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              if (horoscope != null) {
                                                Share.share(
                                                  'Your ${zodiac?.capitalize() ?? selectedSign.capitalize()} horoscope for ${date ?? 'today'}: $horoscope',
                                                );
                                              }
                                            },
                                            tooltip: 'Share Horoscope',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  if (horoscopeHistory.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Recent Horoscopes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: horoscopeHistory.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recentHoroscope = horoscopeHistory[
                            horoscopeHistory.length - 1 - index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${recentHoroscope['zodiac']!.capitalize()} - ${recentHoroscope['date']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  recentHoroscope['horoscope']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
