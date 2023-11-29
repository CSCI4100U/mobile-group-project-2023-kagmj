// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'push_notification.dart';

PushNotificationService _notificationService = PushNotificationService();

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // Variables and Controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final List<String> _countries = ['USA', 'Canada', 'UK'];
  String? _selectedCountry;
  final TextEditingController _birthdayController = TextEditingController();
  final List<String> _genders = ['Man', 'Woman', 'Non-binary', 'Prefer not to say'];
  String? _selectedGender;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Profile Setup Function - Sets up profile information and saves to Firebase
  Future<void> _completeProfileSetup() async {
    if (_formKey.currentState!.validate()) {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Create a document in Firestore
        await FirebaseFirestore.instance.collection('profiles').doc(user.uid).set({
          'name': _nameController.text,
          'country': _selectedCountry ?? '',
          'birthday': _birthdayController.text,
          'gender': _selectedGender ?? '',
          'height': _heightController.text,
          'weight': _weightController.text,
          'profileSetupComplete': true,
        });

        // Send notification upon profile creation
        await _notificationService.sendNotification('Profile Setup Complete', 'Your profile setup is complete!');

        // Navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Handle the case where there is no current user logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is signed in.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Country'),
                    value: _selectedCountry,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                      });
                    },
                    items: _countries.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) => value == null ? 'Please select a country' : null,
                  ),
                  TextFormField(
                    controller: _birthdayController,
                    decoration: InputDecoration(
                        labelText: 'Birthday',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1990),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _birthdayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                        )
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your birthday';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    value: _selectedGender,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    items: _genders.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    validator: (value) => value == null ? 'Please select your gender' : null,
                  ),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _completeProfileSetup,
                    child: const Text('Complete Profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}