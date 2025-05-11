// lib/screens/appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:pim/models/appointment.dart';
import 'package:pim/viewmodels/appointment_viewmodel.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AppointmentsScreen extends StatefulWidget {
  final String token;
  final NotificationService notificationService;

  const AppointmentsScreen({
    Key? key,
    required this.token,
    required this.notificationService,
  }) : super(key: key);

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          Provider.of<AppointmentViewModel>(context, listen: false);
      viewModel.fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AppointmentViewModel>(context);
    const primaryColor = Color(0xFF199A8E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: viewModel.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryColor))
              : viewModel.errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${viewModel.errorMessage}',
                              style: TextStyle(color: Colors.red[700])),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => viewModel.fetchAppointments(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : viewModel.appointments.isEmpty
                      ? const Center(child: Text('No appointments booked'))
                      : ListView.builder(
                          itemCount: viewModel.appointments.length,
                          itemBuilder: (context, index) {
                            return _appointmentCard(context,
                                viewModel.appointments[index], primaryColor);
                          },
                        ),
        ),
      ),
    );
  }

  Widget _appointmentCard(
      BuildContext context, Appointment appointment, Color primaryColor) {
    final doctor = appointment.doctor;
    final formattedDate =
        '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  doctor != null && doctor.profilePictureUrl.isNotEmpty
                      ? NetworkImage(doctor.profilePictureUrl)
                      : const AssetImage('assets/doctor.png') as ImageProvider,
              onBackgroundImageError: (_, __) {
                print('Error loading image for ${doctor?.firstName}');
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor != null
                        ? '${doctor.firstName} ${doctor.lastName}'
                        : 'Unknown Doctor',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor?.specialization ?? 'Unknown Specialization',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: $formattedDate',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    'Time: ${appointment.time}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    'Type: ${appointment.meetingType}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    'Payment Status: ${appointment.paymentStatus}',
                    style: TextStyle(
                      color: appointment.paymentStatus == 'pending'
                          ? Colors.orange
                          : Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.info, color: primaryColor),
              onPressed: () {
                if (doctor != null) {
                  Navigator.pushNamed(
                    context,
                    '/doctor_detail',
                    arguments: doctor,
                  );
                }
              },
              tooltip: 'View Doctor Details',
            ),
          ],
        ),
      ),
    );
  }
}
