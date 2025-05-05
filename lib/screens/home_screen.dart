import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../pages/home_bot.dart';
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
      token: widget.token,
      notificationService: widget.notificationService,
      motivationalQuote: motivationalQuote, // Pass quote to HomeContent
    ),
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
        // Update _screens to reflect new quote
        _screens[0] = HomeContent(
          token: widget.token,
          notificationService: widget.notificationService,
          motivationalQuote: motivationalQuote,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch quote: $e')),
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
    const primaryColor = Color(0xFF199A8E);
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        elevation: 8,
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
  final String? motivationalQuote;

  const HomeContent({
    Key? key,
    required this.token,
    required this.notificationService,
    this.motivationalQuote,
  }) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<DoctorViewModel>(context, listen: false);
      viewModel.fetchDoctors().then((_) {
        print('Fetched ${viewModel.doctors.length} doctors');
        setState(() {});
      }).catchError((e) {
        print('Error fetching doctors: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch doctors: $e')),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorViewModel = Provider.of<DoctorViewModel>(context);
    const primaryColor = Color(0xFF199A8E);
    const backgroundColor = Color(0xFFF5F5F5);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context, primaryColor),
                  const SizedBox(height: 24),
                  _buildSearchField(primaryColor),
                  const SizedBox(height: 24),
                  _buildCategoryRow(context, primaryColor),
                  const SizedBox(height: 24),
                  _buildMotivationalBanner(
                      context, primaryColor, widget.motivationalQuote),
                  const SizedBox(height: 24),
                  _buildDoctorSection(context, doctorViewModel, primaryColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Health Hub',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Find solutions tailored for you',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emergency, color: Colors.red, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmergencyButtonScreen()),
              ),
              tooltip: 'Emergency',
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: primaryColor, size: 28),
              onPressed: () {
                // Notification logic
              },
              tooltip: 'Notifications',
            ),
            IconButton(
              icon: Icon(LucideIcons.messageCircle,
                  color: primaryColor, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              ),
              tooltip: 'Chat',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField(Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search doctor, drugs, articles...',
          prefixIcon: Icon(Icons.search, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _categoryIcon(Icons.local_hospital, 'Doctor', primaryColor,
            onTap: () => Navigator.pushNamed(context, '/doctors')),
        _categoryIcon(Icons.shopping_bag, 'Marketplace', primaryColor,
            onTap: () {
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
        _categoryIcon(Icons.local_pharmacy, 'Pharmacy', primaryColor,
            onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PharmacyScreen()),
          );
        }),
        _categoryIcon(Icons.medical_services, 'Exercises', primaryColor,
            onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExercisesScreen()),
          );
        }),
        _categoryIcon(Icons.grid_3x3, 'Games', primaryColor, onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GamesScreen(token: widget.token)),
          );
        }),
      ],
    );
  }

  Widget _buildMotivationalBanner(
      BuildContext context, Color primaryColor, String? quote) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, const Color(0xFF157A6E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote ?? 'Your health is our priority',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Learn More',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Image.asset('assets/doctor.png', width: 100, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSection(
      BuildContext context, DoctorViewModel viewModel, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Your Doctors', primaryColor),
        const SizedBox(height: 16),
        Container(
          height: 200,
          child: _doctorList(context, viewModel, primaryColor),
        ),
      ],
    );
  }

  Widget _categoryIcon(IconData icon, String title, Color primaryColor,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: primaryColor),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                    fontSize: 10,
                    color: primaryColor,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/doctors');
          },
          child: Text(
            'See all',
            style: TextStyle(
                fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _doctorList(
      BuildContext context, DoctorViewModel viewModel, Color primaryColor) {
    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${viewModel.errorMessage}',
                style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => viewModel.fetchDoctors(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.doctors.isEmpty) {
      return const Center(child: Text('No doctors available'));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: viewModel.doctors.length > 5 ? 5 : viewModel.doctors.length,
      itemBuilder: (context, index) =>
          _doctorCard(context, viewModel.doctors[index], primaryColor),
    );
  }

  Widget _doctorCard(BuildContext context, Doctor doctor, Color primaryColor) {
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
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                backgroundImage: doctor.profilePictureUrl.isNotEmpty
                    ? NetworkImage(doctor.profilePictureUrl)
                    : const AssetImage('assets/doctor.png') as ImageProvider,
                onBackgroundImageError: (_, __) {
                  print('Error loading image for ${doctor.firstName}');
                },
              ),
              const SizedBox(height: 12),
              Text(
                '${doctor.firstName} ${doctor.lastName}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialization,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange[400], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    doctor.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${doctor.distance.toStringAsFixed(1)} ${doctor.distance < 1 ? 'm' : 'km'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
