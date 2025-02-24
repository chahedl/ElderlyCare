import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    _HomeContent(),
    ProfileScreen(token: 'token'),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

void _showMotivationalQuoteNotification(BuildContext context) async {
  final notificationService = NotificationService();
  await notificationService.showQuoteNotification();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String? motivationalQuote;

  @override
  void initState() {
    super.initState();
    _fetchInitialQuote();
    _showMotivationalQuoteNotification(context);
  }

  Future<void> _fetchInitialQuote() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final quote = await apiService.fetchMotivationalQuote();
      setState(() {
        motivationalQuote = quote;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch motivational quote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          if (motivationalQuote != null)
            Text(
              motivationalQuote!,
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

void _showMotivationalQuoteNotification(BuildContext context) async {
  final notificationService = NotificationService();
  await notificationService.showQuoteNotification();
}
