import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/doctor_viewmodel.dart';
import '../models/doctor.dart';
import '/screens/doctor_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({Key? key}) : super(key: key);

  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorViewModel>(context, listen: false)
          .fetchDoctors()
          .then((_) {
        setState(() {});
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load doctors: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorViewModel = Provider.of<DoctorViewModel>(context);
    const primaryColor = Color(0xFF199A8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Doctors',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Find a doctor...',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  // Implement search functionality later
                },
              ),
            ),
            const SizedBox(height: 24),
            // Categories Section
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildCategory("General", Icons.medical_services, primaryColor),
                _buildCategory(
                    "Lungs Specialist", Icons.vaccines_rounded, primaryColor),
                _buildCategory(
                    "Dentist", Icons.health_and_safety, primaryColor),
                _buildCategory("Psychiatrist", Icons.psychology, primaryColor),
                _buildCategory("Covid-19", Icons.coronavirus, primaryColor),
                _buildCategory("Surgeon", Icons.vaccines, primaryColor),
                _buildCategory("Cardiologist", Icons.favorite, primaryColor),
                _buildCategory("Pediatrician", Icons.child_care, primaryColor),
                _buildCategory(
                    "Dermatologist", Icons.local_hospital, primaryColor),
                _buildCategory(
                    "Neurologist", Icons.health_and_safety, primaryColor),
                _buildCategory(
                    "Orthopedist", Icons.sports_handball, primaryColor),
                _buildCategory("Gynecologist", Icons.female, primaryColor),
                _buildCategory("Urologist", Icons.accessibility, primaryColor),
                _buildCategory(
                    "Ophthalmologist", Icons.visibility, primaryColor),
                _buildCategory(
                    "Endocrinologist", Icons.local_hospital, primaryColor),
                _buildCategory("Radiologist", Icons.scanner, primaryColor),
              ],
            ),
            const SizedBox(height: 24),
            // Recommended Doctors Section
            Text(
              'Recommended Doctors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildDoctorList(doctorViewModel, primaryColor),
            const SizedBox(height: 24),
            // Recent Doctors Section
            Text(
              'Your Recent Doctors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentDoctors(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        // Implement category filter later
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filtering by $title (coming soon)'),
            backgroundColor: primaryColor,
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(icon, color: primaryColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(DoctorViewModel viewModel, Color primaryColor) {
    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryColor));
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 48),
            const SizedBox(height: 8),
            Text(
              'Error: ${viewModel.errorMessage}',
              style: TextStyle(color: Colors.red[700], fontSize: 16),
            ),
            const SizedBox(height: 8),
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.doctors.length,
      itemBuilder: (context, index) {
        final doctor = viewModel.doctors[index];
        return DoctorCard(doctor: doctor, primaryColor: primaryColor);
      },
    );
  }

  Widget _buildRecentDoctors(Color primaryColor) {
    // Placeholder data; replace with dynamic data later
    final recentDoctors = [
      {'name': 'Dr. Marcus', 'image': 'assets/doctor.png'},
      {'name': 'Dr. Maria', 'image': 'assets/doctor.png'},
      {'name': 'Dr. Stevi', 'image': 'assets/doctor.png'},
      {'name': 'Dr. Luke', 'image': 'assets/doctor.png'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentDoctors.length,
        itemBuilder: (context, index) {
          final doctor = recentDoctors[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                // Implement navigation to doctor details later
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing ${doctor['name']} (coming soon)'),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: AssetImage(doctor['image']!),
                    child: doctor['image'] == null
                        ? Icon(Icons.person, color: primaryColor, size: 36)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor['name']!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final Color primaryColor;

  const DoctorCard({required this.doctor, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctor: doctor),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Profile Picture
              ClipOval(
                child: doctor.profilePictureUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: doctor.profilePictureUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(
                          color: primaryColor,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child:
                              Icon(Icons.person, color: primaryColor, size: 30),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child:
                            Icon(Icons.person, color: primaryColor, size: 30),
                      ),
              ),
              const SizedBox(width: 12),
              // Doctor Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${doctor.firstName} ${doctor.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialization,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.location_on, color: primaryColor, size: 16),
                        Text(
                          '800m away', // Update dynamically later
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(Icons.chevron_right, color: primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
