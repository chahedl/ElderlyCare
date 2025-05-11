import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart'; // Added for sharing jokes

class JokesScreen extends StatefulWidget {
  const JokesScreen({Key? key}) : super(key: key);

  @override
  _JokesScreenState createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  String? joke;
  bool isLoading = true;
  String? errorMessage;
  List<String> jokeHistory = []; // Store recent jokes

  @override
  void initState() {
    super.initState();
    _fetchJoke();
  }

  Future<void> _fetchJoke() async {
    const apiKey = 'FpnDy/bcnuw9mosfJl/fwA==VBIoTqAgRRt8RL8f';
    const apiUrl = 'https://api.api-ninjas.com/v1/jokes';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'X-Api-Key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          joke = data.isNotEmpty ? data[0]['joke'] : 'No joke available';
          if (joke != null && joke != 'No joke available') {
            jokeHistory.add(joke!);
            if (jokeHistory.length > 5) {
              jokeHistory.removeAt(0); // Limit to 5 recent jokes
            }
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch joke: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching joke: $e';
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
          'Jokes',
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
                      Icon(Icons.emoji_emotions, color: primaryColor, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Have a Laugh',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity: isLoading || errorMessage != null || joke != null
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
                                          Icon(Icons.tag_faces,
                                              color: primaryColor, size: 24),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              joke ?? 'No joke available',
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
                                            tooltip: 'Save Joke',
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.share,
                                              color: primaryColor,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              if (joke != null) {
                                                Share.share(
                                                    'Check out this joke: $joke');
                                              }
                                            },
                                            tooltip: 'Share Joke',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          joke = null;
                          errorMessage = null;
                        });
                        _fetchJoke();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Get Another Joke',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  if (jokeHistory.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Recent Jokes',
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
                      itemCount: jokeHistory.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final recentJoke =
                            jokeHistory[jokeHistory.length - 1 - index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              recentJoke,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
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
