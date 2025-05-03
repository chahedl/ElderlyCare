import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:pharmacy/screens/pharmacy_screen.dart';
import 'package:pharmacy/viewmodels/pharmacy_viewmodel.dart';
import 'package:pharmacy/services/weather_service.dart';
import 'package:pharmacy/services/distance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
    if (dotenv.env['OPENWEATHERMAP_API_KEY'] == null || dotenv.env['ORS_API_KEY'] == null) {
      throw Exception('Required API keys not found in .env file');
    }
  } catch (e) {
    print('Error loading .env file: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PharmacyViewModel()),
        Provider(
          create: (_) => WeatherService(
            apiKey: dotenv.env['OPENWEATHERMAP_API_KEY'] ?? '7d23c8367ed283e7b686e448c9b4f905',
          ),
        ),
        Provider(
          create: (_) => DistanceService(
            apiKey: dotenv.env['ORS_API_KEY'] ?? '',
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy Locator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const PharmacyScreen(),
    );
  }
}