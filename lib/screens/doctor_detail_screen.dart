import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../viewmodels/login_viewmodel.dart'; // To access token

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String _selectedMeetingType = 'In-Person';
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '07:00 PM',
  ];

  final List<String> _meetingTypes = ['In-Person', 'Call'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService =
          Provider.of<LoginViewModel>(context, listen: false).apiService;

      final response = await apiService.bookAppointment(
        doctorId: widget.doctor.id,
        date: _selectedDate!,
        time: _selectedTime!,
        meetingType: _selectedMeetingType,
      );

      if (_selectedMeetingType == 'Call') {
        // Initialize Stripe payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: response['clientSecret'],
            merchantDisplayName: 'Elderly Care App',
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();

        // Payment successful, show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment and appointment booked successfully!')),
        );
      } else {
        // In-Person appointment, no payment required
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment booked successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.doctor.profilePictureUrl.isNotEmpty
                        ? NetworkImage(widget.doctor.profilePictureUrl)
                        : null,
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.doctor.firstName} ${widget.doctor.lastName}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.doctor.specialization,
                          style: TextStyle(fontSize: 16),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Text(
                              widget.doctor.rating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${widget.doctor.distance.toStringAsFixed(1)}km away',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Email: ${widget.doctor.email}',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // About Section
              Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Dr. ${widget.doctor.lastName} is a highly experienced ${widget.doctor.specialization} with over 10 years of practice. Specializing in patient-centered care, they are dedicated to providing comprehensive and compassionate medical services.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),

              // Date Selection
              Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? 'Pick a Date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                ),
              ),
              SizedBox(height: 16),

              // Time Slot Selection
              Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _timeSlots.map((time) {
                  return ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          _selectedTime == time ? Colors.white : Colors.black,
                      backgroundColor: _selectedTime == time
                          ? Colors.teal
                          : Colors.grey[200],
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(time),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Meeting Type Selection
              Text(
                'Meeting Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedMeetingType,
                isExpanded: true,
                items: _meetingTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedMeetingType = newValue!;
                        });
                      },
              ),
              SizedBox(height: 24),

              // Book Appointment Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Book Appointment',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
