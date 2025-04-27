// lib/components/add_product_form.dart
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0.0;
  int _stock = 0;
  String _category = '';
  html.File? _imageFile;

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
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print('Sending request to POST /api/products with data:');
      print(
          'Name: $_name, Description: $_description, Price: $_price, Stock: $_stock, Category: $_category, Image: ${_imageFile!.name}');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:2000/api/products'),
      );
      request.fields['name'] = _name;
      request.fields['description'] = _description;
      request.fields['price'] = _price.toString();
      request.fields['stock'] = _stock.toString();
      request.fields['category'] = _category;

      // Read and attach image file
      final reader = html.FileReader();
      reader.readAsArrayBuffer(_imageFile!);
      await reader.onLoad.first;
      final bytes = reader.result as Uint8List; // Directly use as Uint8List
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Must match multer's field name
          bytes,
          filename: _imageFile!.name,
        ),
      );

      // Send request
      final response = await request.send();
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
        });
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $responseBody')),
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
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _name = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _description = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              if (double.tryParse(value) == null) return 'Invalid number';
              return null;
            },
            onSaved: (value) => _price = double.parse(value!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Stock'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Required';
              if (int.tryParse(value) == null) return 'Invalid number';
              return null;
            },
            onSaved: (value) => _stock = int.parse(value!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Category'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
            onSaved: (value) => _category = value!,
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
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }
}
