import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/api_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(token: 'YOUR_TOKEN_HERE'),
      },
    );
  }
}

void navigateToProfile(BuildContext context, String token) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileScreen(token: token),
    ),
  );
}

Future<void> handleLogin(
    BuildContext context, String email, String password) async {
  final apiService = ApiService(''); // Updated instantiation
  final loginViewModel = LoginViewModel(apiService);

  bool success = await loginViewModel.login(email, password);
  if (success) {
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');
    if (token != null) {
      navigateToProfile(context, token);
    }
  }
}
