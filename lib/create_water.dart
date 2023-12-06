import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart';

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

    // Retrieve existing water intake value or set a default value
    List<Map<String, dynamic>>? logs = await DatabaseHelper().getLogs();
    Map<String, dynamic> existingWaterIntakeLog =
        logs?.firstWhere((log) => log['type'] == 'water', orElse: () => {'waterIntake': '0'}) ?? {'waterIntake': '0'};

    int existingWaterIntake = int.tryParse(existingWaterIntakeLog['waterIntake'].toString()) ?? 0;

    // Add new water intake to the existing value
    int newWaterIntake = int.tryParse(_waterIntakeController.text) ?? 0;
    int totalWaterIntake = existingWaterIntake + newWaterIntake;

    // Prepare the data for insertion
    final waterIntake = {
      'type': 'water',
      'waterIntake': totalWaterIntake.toString(),
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
