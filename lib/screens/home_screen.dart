import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../pages/home_bot.dart';
import 'doctor_detail_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../pages/chatscreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import 'marketplace_screen.dart';
import '../pages/pharmacy_screen.dart';
import '../pages/emergency_button_screen.dart';
import 'exercises_screen.dart';
import 'sudoku_screen.dart';
import 'games_screen.dart';
import '../viewmodels/doctor_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final NotificationService notificationService;

  HomeScreen({required this.token, required this.notificationService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  int _selectedIndex = 0;
  String? motivationalQuote;
  late NotificationService _notificationService;

  late final List<Widget> _screens = [
    HomeContent(
        token: widget.token, notificationService: widget.notificationService),
    HomeBot(),
    ProfileScreen(token: widget.token),
  ];

  @override
  void initState() {
    super.initState();
    _notificationService = widget.notificationService;
    _fetchInitialQuote();
    _setupNotifications();
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

  Future<void> _setupNotifications() async {
    await _notificationService.init();
    await _notificationService.showQuoteNotification();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_mosaic), label: 'HealthBot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String token;
  final NotificationService notificationService;

  const HomeContent({
    Key? key,
    required this.token,
    required this.notificationService,
  }) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    // Fetch doctors after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DoctorViewModel>(context, listen: false);
      viewModel.fetchDoctors().then((_) {
        print('Fetched ${viewModel.doctors.length} doctors');
        setState(() {});
      }).catchError((e) {
        print('Error fetching doctors: $e');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorViewModel = Provider.of<DoctorViewModel>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildCategoryRow(context),
            const SizedBox(height: 16),
            _buildMotivationalBanner(context),
            const SizedBox(height: 16),
            _buildDoctorSection(context, doctorViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Find your desire\nhealth solution",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emergency, color: Colors.red),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmergencyButtonScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // Notification logic
              },
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(LucideIcons.messageCircle),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search doctor, drugs, articles...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _categoryIcon(Icons.local_hospital, "Doctor",
            onTap: () => Navigator.pushNamed(context, '/doctors')),
        _categoryIcon(Icons.shopping_bag, "Marketplace", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MarketplaceScreen(
                token: widget.token,
                notificationService: widget.notificationService,
              ),
            ),
          );
        }),
        _categoryIcon(Icons.local_pharmacy, "Pharmacy", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PharmacyScreen()),
          );
        }),
        _categoryIcon(Icons.medical_services, "Exercises", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExercisesScreen()),
          );
        }),
        _categoryIcon(Icons.grid_3x3, "Games", onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GamesScreen(token: widget.token)),
          );
        }),
      ],
    );
  }

  Widget _buildMotivationalBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your health is our Priority",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Learn more"),
                ),
              ],
            ),
          ),
          Image.asset("assets/doctor.png", width: 80),
        ],
      ),
    );
  }

  Widget _buildDoctorSection(BuildContext context, DoctorViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Your Doctors"),
        const SizedBox(height: 8),
        Container(
          height: 180,
          child: _doctorList(context, viewModel),
        ),
      ],
    );
  }

  Widget _categoryIcon(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.teal),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Text(
          "See all",
          style: TextStyle(fontSize: 14, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _doctorList(BuildContext context, DoctorViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${viewModel.errorMessage}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => viewModel.fetchDoctors(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.doctors.isEmpty) {
      return const Center(child: Text('No doctors available'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: viewModel.doctors
            .take(5) // Limit to 5 doctors for display
            .map((doctor) => _doctorCard(context, doctor))
            .toList(),
      ),
    );
  }

  Widget _doctorCard(BuildContext context, Doctor doctor) {
    return GestureDetector(
      onTap: () {
        print(
            'Navigating to DoctorDetailScreen for ${doctor.firstName} ${doctor.lastName}');
        Navigator.pushNamed(
          context,
          '/doctor_detail',
          arguments: doctor,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, top: 8),
        padding: const EdgeInsets.all(12),
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: doctor.profilePictureUrl.isNotEmpty
                  ? NetworkImage(doctor.profilePictureUrl)
                  : const AssetImage('assets/doctor.png') as ImageProvider,
              radius: 30,
              onBackgroundImageError: (_, __) {
                print('Error loading image for ${doctor.firstName}');
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${doctor.firstName} ${doctor.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              doctor.specialization,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                Text(
                  doctor.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${doctor.distance.toStringAsFixed(1)} ${doctor.distance < 1 ? 'm' : 'km'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
