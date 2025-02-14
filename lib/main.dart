import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Find your desire\nhealth solution",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.notifications_outlined),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search doctor, drugs, articles...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _categoryIcon(Icons.local_hospital, "Doctor"),
                  _categoryIcon(Icons.local_pharmacy, "Pharmacy"),
                  _categoryIcon(Icons.local_hotel, "Hospital"),
                  _categoryIcon(Icons.local_taxi, "Ambulance"),
                ],
              ),
              const SizedBox(height: 16),
              _bannerCard(),
              const SizedBox(height: 16),
              _sectionHeader("Your Doctors"),
              _doctorList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryIcon(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.teal),
        Text(title, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _bannerCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
                Text(
                  "Your health is our Priority",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text("Learn more"),
                ),
              ],
            ),
          ),
          Image.asset("assets/doctor.png", width: 80),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "See all",
          style: TextStyle(fontSize: 14, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _doctorList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _doctorCard("Dr. Marcus Horiz", "Cardiologist", "4.7", "800m away"),
          _doctorCard("Dr. Maria Elena", "Psychologist", "4.8", "1.5km away"),
          _doctorCard("Dr. Stevi Jes", "Orthopedist", "4.6", "2km away"),
        ],
      ),
    );
  }

  Widget _doctorCard(
      String name, String specialty, String rating, String distance) {
    return Container(
      margin: EdgeInsets.only(right: 12, top: 8),
      padding: EdgeInsets.all(12),
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
            backgroundColor: Colors.grey[200],
            radius: 30,
            child: Icon(Icons.person, size: 40, color: Colors.teal),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            specialty,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 14),
              Text(rating, style: TextStyle(fontSize: 12)),
              Spacer(),
              Text(distance,
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
