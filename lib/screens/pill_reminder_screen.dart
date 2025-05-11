// lib/screens/pill_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class PillReminderScreen extends StatefulWidget {
  const PillReminderScreen({Key? key}) : super(key: key);

  @override
  _PillReminderScreenState createState() => _PillReminderScreenState();
}

class _PillReminderScreenState extends State<PillReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  DateTime? _selectedTime;
  String _frequency = 'Daily';
  final List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final medications = await DatabaseHelper.instance.getMedications();
      setState(() {
        _medications.clear();
        _medications.addAll(medications);
      });
    } catch (e) {
      print('Error loading medications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading medications: $e')),
      );
    }
  }

  Future<void> _addMedication() async {
    if (_formKey.currentState!.validate() && _selectedTime != null) {
      final medication = Medication(
        name: _nameController.text,
        dosage: _dosageController.text,
        time: _selectedTime!,
        frequency: _frequency,
      );

      try {
        // Save to local database
        int id = await DatabaseHelper.instance.insertMedication(medication);
        final savedMedication = medication.copyWith(id: id);

        // Ensure NotificationService is initialized
        print('Ensuring NotificationService is initialized');
        await NotificationService().init();
        await Future.delayed(Duration(milliseconds: 500));

        // Adjust scheduled time based on frequency
        DateTime scheduledTime = _selectedTime!;
        if (scheduledTime.isBefore(DateTime.now())) {
          if (_frequency == 'Daily') {
            scheduledTime = scheduledTime.add(Duration(days: 1));
          } else if (_frequency == 'Weekly') {
            scheduledTime = scheduledTime.add(Duration(days: 7));
          }
        }

        // Schedule notification
        await NotificationService().schedulePillReminder(
          id: savedMedication.hashCode,
          title: 'Pill Reminder',
          body:
              'Time to take ${savedMedication.name} (${savedMedication.dosage})',
          scheduledTime: scheduledTime,
        );

        _nameController.clear();
        _dosageController.clear();
        _selectedTime = null;
        await _loadMedications();
      } catch (e) {
        print('Error adding medication: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding medication: $e')),
        );
      }
    }
  }

  Future<void> _markAsTaken(Medication medication) async {
    final updatedMedication = medication.copyWith(isTaken: true);

    try {
      await DatabaseHelper.instance.updateMedication(updatedMedication);
      await NotificationService().cancelPillReminder(medication.hashCode);
      await _loadMedications();
    } catch (e) {
      print('Error updating medication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating medication: $e')),
      );
    }
  }

  Future<void> _deleteMedication(Medication medication) async {
    try {
      await DatabaseHelper.instance.deleteMedication(medication.id!);
      await NotificationService().cancelPillReminder(medication.hashCode);
      await _loadMedications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${medication.name} removed')),
      );
    } catch (e) {
      print('Error deleting medication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting medication: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Pill Reminders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Your Medications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Medication Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage (e.g., 1 tablet)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(
                            _selectedTime == null
                                ? 'Select Time'
                                : DateFormat('hh:mm a').format(_selectedTime!),
                            style: const TextStyle(fontSize: 18),
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _selectedTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _frequency,
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Daily', 'Weekly', 'As Needed']
                              .map((freq) => DropdownMenuItem(
                                    value: freq,
                                    child: Text(freq),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _frequency = value!),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _addMedication,
                          child: const Text('Add Medication'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Upcoming Reminders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _medications.isEmpty
                  ? const Center(
                      child: Text('No medications added.',
                          style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final medication = _medications[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            title: Text(
                              '${medication.name} (${medication.dosage})',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${DateFormat('hh:mm a').format(medication.time)} - ${medication.frequency}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!medication.isTaken)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                    onPressed: () => _markAsTaken(medication),
                                    child: const Text('Taken'),
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red[700], size: 28),
                                  onPressed: () =>
                                      _deleteMedication(medication),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            leading: medication.isTaken
                                ? Icon(Icons.check_circle,
                                    color: primaryColor, size: 30)
                                : null,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to support copyWith for Medication
extension MedicationExtension on Medication {
  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    DateTime? time,
    String? frequency,
    bool? isTaken,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
