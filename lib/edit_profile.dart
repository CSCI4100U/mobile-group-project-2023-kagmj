// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:final_project/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Initialize profile options
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final List<String> _countries = ['USA', 'Canada', 'UK'];
  String? _selectedCountry;
  final TextEditingController _birthdayController = TextEditingController();
  final List<String> _genders = ['Man', 'Woman', 'Non-binary', 'Prefer not to say'];
  String? _selectedGender;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingProfileData();
  }

  // _loadExistingProfileData Function - Loads in current user's data from Firestore database
  void _loadExistingProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();
      if (userProfile.exists) {
        Map<String, dynamic>? data = userProfile.data() as Map<String, dynamic>?;
        setState(() {
          // Populates controllers with user data
          _nameController.text = data?['name'] ?? '';
          _selectedCountry = data?['country'] ?? '';
          _birthdayController.text = data?['birthday'] ?? '';
          _selectedGender = data?['gender'] ?? '';
          _heightController.text = data?['height'] ?? '';
          _weightController.text = data?['weight'] ?? '';
        });
      }
    }
  }

  // _saveProfile Function - Saves updated information to the Firestore database
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('profiles').doc(user.uid).set({
          'name': _nameController.text,
          'country': _selectedCountry ?? '',
          'birthday': _birthdayController.text,
          'gender': _selectedGender ?? '',
          'height': _heightController.text,
          'weight': _weightController.text,
        }, SetOptions(merge: true));
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const ProfileScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
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
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
