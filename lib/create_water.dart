import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart';
import 'package:intl/intl.dart';

import 'home_screen.dart';

class CreateWaterScreen extends StatefulWidget {
  const CreateWaterScreen({Key? key}) : super(key: key);

  @override
  _CreateWaterScreenState createState() => _CreateWaterScreenState();
}

class _CreateWaterScreenState extends State<CreateWaterScreen> {
  final TextEditingController _waterIntakeController = TextEditingController();

  @override
  void dispose() {
    _waterIntakeController.dispose();
    super.dispose();
  }

  void _submitWaterIntake() async {
    // Check if the water intake value is not empty
    if (_waterIntakeController.text.isEmpty) {
      // Show an error message or handle the case where the input is empty
      return;
    }

    // Add new water intake to the existing value
    String newWaterIntake =_waterIntakeController.text;
    String todayFormatted = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    // Prepare the data for insertion
    final waterIntake = {
      'type': 'water',
      'waterIntake': newWaterIntake,
      'logDate': todayFormatted
    };

    // Insert the new water intake into the database
    await DatabaseHelper().insertLog(waterIntake);

    // Navigate back to the home screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Water Intake'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 16),
            const Text("Water Intake (mL)"),
            const SizedBox(height: 4),
            TextField(
              controller: _waterIntakeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter water intake in mL',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitWaterIntake,
              child: const Text('Log Water Intake'),
            ),
          ],
        ),
      ),
    );
  }
}
