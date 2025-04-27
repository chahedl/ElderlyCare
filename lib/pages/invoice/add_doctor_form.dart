import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddDoctorForm extends StatefulWidget {
  const AddDoctorForm({super.key});

  @override
  _AddDoctorFormState createState() => _AddDoctorFormState();
}

class _AddDoctorFormState extends State<AddDoctorForm> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _specialization = 'General'; // Default value
  double _longitude = 0.0;
  double _latitude = 0.0;
  bool _availability = true;
  double _rating = 0.0;
  html.File? _imageFile;

  final List<String> _specializations = [
    'General',
    'Lungs Specialist',
    'Dentist',
    'Psychiatrist',
    'Covid-19',
    'Surgeon',
    'Cardiologist',
    'Pediatrician',
    'Dermatologist',
    'Neurologist',
    'Orthopedist',
    'Gynecologist',
    'Urologist',
    'Ophthalmologist',
    'Endocrinologist',
    'Radiologist',
  ];

  // Function to select an image file
  Future<void> _selectImage() async {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();
    await uploadInput.onChange.first;
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      setState(() {
        _imageFile = files[0];
      });
    }
  }

  // Function to submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print('Sending request to POST /api/doctors/createD with data:');
      print(
          'First Name: $_firstName, Last Name: $_lastName, Email: $_email, Specialization: $_specialization, '
          'Location: [$_longitude, $_latitude], Availability: $_availability, Rating: $_rating, '
          'Image: ${_imageFile?.name ?? "No image"}');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:2000/api/doctors/createD'),
      );
      request.fields['firstName'] = _firstName;
      request.fields['lastName'] = _lastName;
      request.fields['email'] = _email;
      request.fields['specialization'] = _specialization;
      request.fields['location[type]'] = 'Point';
      request.fields['location[coordinates][0]'] = _longitude.toString();
      request.fields['location[coordinates][1]'] = _latitude.toString();
      request.fields['availability'] = _availability.toString();
      request.fields['rating'] = _rating.toString();

      // Read and attach image file if selected
      if (_imageFile != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_imageFile!);
        await reader.onLoad.first;
        final bytes = reader.result as Uint8List;
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', // Must match multer's field name in doctorRoutes.js
            bytes,
            filename: _imageFile!.name,
          ),
        );
      }

      // Send request
      final response = await request.send();
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor added successfully')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
          _specialization = 'General';
          _availability = true;
          _rating = 0.0;
        });
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add doctor: $responseBody')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Doctor',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(labelText: 'First Name'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _firstName = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _lastName = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              if (!RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$')
                  .hasMatch(value)) {
                return 'Invalid email format';
              }
              return null;
            },
            onSaved: (value) => _email = value!,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Specialization'),
            value: _specialization,
            items: _specializations.map((specialization) {
              return DropdownMenuItem<String>(
                value: specialization,
                child: Text(specialization),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _specialization = value!;
              });
            },
            validator: (value) => value == null ? 'Required' : null,
            onSaved: (value) => _specialization = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Longitude'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              final longitude = double.tryParse(value);
              if (longitude == null) return 'Invalid number';
              if (longitude < -180 || longitude > 180) {
                return 'Longitude must be between -180 and 180';
              }
              return null;
            },
            onSaved: (value) => _longitude = double.parse(value!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Latitude'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              final latitude = double.tryParse(value);
              if (latitude == null) return 'Invalid number';
              if (latitude < -90 || latitude > 90) {
                return 'Latitude must be between -90 and 90';
              }
              return null;
            },
            onSaved: (value) => _latitude = double.parse(value!),
          ),
          SwitchListTile(
            title: const Text('Availability'),
            value: _availability,
            onChanged: (value) {
              setState(() {
                _availability = value;
              });
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Rating (0-5)'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              final rating = double.tryParse(value);
              if (rating == null) return 'Invalid number';
              if (rating < 0 || rating > 5) {
                return 'Rating must be between 0 and 5';
              }
              return null;
            },
            onSaved: (value) => _rating = double.parse(value!),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: _selectImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(width: 10),
              Text(_imageFile == null
                  ? 'No image selected'
                  : 'Image: ${_imageFile!.name}'),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Add Doctor'),
          ),
        ],
      ),
    );
  }
}
