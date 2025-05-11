import 'package:flutter/material.dart';
import 'sudoku_screen.dart';
import 'horoscope_screen.dart';
import 'facts_screen.dart';
import 'trivia_screen.dart';
import 'hobbies_screen.dart';
import 'riddles_screen.dart';
import 'jokes_screen.dart';
import 'home_screen.dart'; // Import HomeScreen
import '../services/notification_service.dart'; // Import NotificationService for HomeScreen

class GamesScreen extends StatelessWidget {
  final String token;

  const GamesScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  token: token,
                  notificationService: NotificationService(),
                ),
              ),
            );
          },
          tooltip: 'Back to Home',
        ),
        title: const Text(
          'Games & Activities',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover fun and engaging activities!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              token: token,
                              notificationService: NotificationService(),
                            ),
                          ),
                        );
                      },
                      icon:
                          const Icon(Icons.home, color: Colors.white, size: 20),
                      label: const Text(
                        'Back to Home',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Grid of game cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildGameCard(
                      context,
                      title: 'Sudoku',
                      icon: Icons.grid_3x3,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SudokuScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildGameCard(
                      context,
                      title: 'Horoscope',
                      icon: Icons.star,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HoroscopeScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildGameCard(
                      context,
                      title: 'Facts',
                      icon: Icons.lightbulb,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FactsScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildGameCard(
                      context,
                      title: 'Trivia',
                      icon: Icons.quiz,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TriviaScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildGameCard(
                      context,
                      title: 'Hobbies',
                      icon: Icons.brush,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HobbiesScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildGameCard(
                      context,
                      title: 'Riddles',
                      icon: Icons.question_mark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiddlesScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildGameCard(
                      context,
                      title: 'Jokes',
                      icon: Icons.emoji_emotions,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JokesScreen(),
                          ),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: 1.0,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(icon, color: primaryColor, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
