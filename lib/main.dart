import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pim/models/doctor.dart';
import 'package:pim/screens/doctor_detail_screen.dart';
import 'package:pim/screens/login_screen.dart';
import 'package:pim/screens/signup_screen.dart';
import 'package:pim/screens/doctors_screen.dart';
import 'package:pim/screens/bottom_tab_bar.dart';
import 'package:pim/services/notification_service.dart';
import 'package:pim/viewmodels/login_viewmodel.dart';
import 'package:pim/viewmodels/doctor_viewmodel.dart';
import 'package:pim/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:pim/pages/pharmacy_screen.dart';
import 'package:pim/viewmodels/pharmacy_viewmodel.dart';
import 'package:pim/services/weather_service.dart';
import 'package:pim/services/distance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  try {
    Stripe.publishableKey =
        'pk_test_51RHrcTGd1mOBLMSWZADSUzayt44Zg3JFdp345WK8BFIjTuki6OUj3iU5zCeKT0K8zmfWgMoGX4rBTE24EoCt2in200XMkaiB71';
    await Stripe.instance.applySettings();
  } catch (e) {
    print('Stripe initialization failed: $e');
  }

  // Initialize .env for pharmacy-related API keys
  try {
    await dotenv.load(fileName: "assets/.env");
    if (dotenv.env['OPENWEATHERMAP_API_KEY'] == null ||
        dotenv.env['ORS_API_KEY'] == null) {
      throw Exception('Required API keys not found in .env file');
    }
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize token
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token') ?? '';

  runApp(MyApp(initialToken: token));
}

class MyApp extends StatelessWidget {
  final String initialToken;
  final NotificationService notificationService = NotificationService();

  MyApp({required this.initialToken, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Existing providers for your app
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(
          create: (context) => LoginViewModel(
            ApiService(initialToken, notificationService),
          ),
        ),
        ChangeNotifierProxyProvider<LoginViewModel, DoctorViewModel>(
          create: (context) => DoctorViewModel(
            apiService: ApiService(initialToken, notificationService),
            token: initialToken,
          ),
          update: (context, loginViewModel, doctorViewModel) {
            doctorViewModel?.updateToken(loginViewModel.token);
            return doctorViewModel ??
                DoctorViewModel(
                  apiService:
                      ApiService(loginViewModel.token, notificationService),
                  token: loginViewModel.token,
                );
          },
        ),
        // New providers for pharmacy feature
        ChangeNotifierProvider(create: (_) => PharmacyViewModel()),
        Provider(
          create: (_) => WeatherService(
            apiKey: dotenv.env['OPENWEATHERMAP_API_KEY'] ??
                '7d23c8367ed283e7b686e448c9b4f905',
          ),
        ),
        Provider(
          create: (_) => DistanceService(
            apiKey: dotenv.env['ORS_API_KEY'] ?? '',
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Elderly Care App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: false, // Consistent with your original theme
        ),
        darkTheme: ThemeData.dark(), // Added from friend's main.dart
        themeMode: ThemeMode.system, // Added from friend's main.dart
        initialRoute: '/login',
        routes: {
          '/home': (context) => BottomTabBar(
                token: initialToken,
                notificationService: notificationService,
              ),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/doctors': (context) => DoctorsScreen(),
          '/doctor_detail': (context) => DoctorDetailScreen(
                doctor: ModalRoute.of(context)!.settings.arguments as Doctor,
              ),
          '/pharmacies': (context) =>
              const PharmacyScreen(), 
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
