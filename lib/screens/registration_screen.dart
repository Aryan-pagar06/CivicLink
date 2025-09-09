import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _aadhaarController = TextEditingController();
  String? _selectedGender;
  Position? _currentPosition;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      print("Location: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error getting location: $e");
      setState(() => _isLoading = false);
    }
  }

  void _registerUser() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      print("Registration data:");
      print("Name: ${_nameController.text}");
      print("Email: ${_emailController.text}");
      print("Age: ${_ageController.text}");
      print("Aadhaar: ${_aadhaarController.text}");
      print("Gender: $_selectedGender");
      print("Location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}");
      
      // Simulate registration process
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        Navigator.pop(context); // Go back to login screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Your Logo - ADDED HERE
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

              // App Name
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Join CivicLink to report issues in your community',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Aadhaar Number
              TextFormField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.credit_card, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.length != 12) {
                    return 'Please enter valid 12-digit Aadhaar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Age
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.cake, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.people, color: Colors.blue),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              ElevatedButton(
                onPressed: _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_currentPosition == null ? Icons.location_off : Icons.location_on),
                          const SizedBox(width: 10),
                          Text(_currentPosition == null ? 'Get Current Location' : 'Location Captured!'),
                        ],
                      ),
              ),
              if (_currentPosition != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
              const SizedBox(height: 30),

              // Register Button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}