import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'marketplace_screen.dart'; // Import MarketplaceScreen
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeContent(),
      MarketplaceScreen('token', NotificationService()), // Ensure the token is correctly passed
      ProfileScreen(token: 'token'),
      SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _screens[_selectedIndex],
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMotivationalQuoteNotification();
    });
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

  Future<void> _showMotivationalQuoteNotification() async {
    final notificationService = NotificationService();
    await notificationService.showQuoteNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (motivationalQuote != null)
            Text(
              motivationalQuote!,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
