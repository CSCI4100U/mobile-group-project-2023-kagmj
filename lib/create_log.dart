// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart';
import 'package:intl/intl.dart';
import 'exercise.dart';
import 'home_screen.dart';

class CreateLogScreen extends StatefulWidget {
  const CreateLogScreen({super.key});

  @override
  _CreateLogScreenState createState() => _CreateLogScreenState();
}

class _CreateLogScreenState extends State<CreateLogScreen> {
  // Variables and Controller
  final TextEditingController _logTitleController = TextEditingController();
  final TextEditingController _logRoutineController = TextEditingController();
  final TextEditingController _logDateController = TextEditingController();
  final TextEditingController _logTimeController = TextEditingController();
  final TextEditingController _logDescriptionController = TextEditingController();
  final TextEditingController _workoutTypeController = TextEditingController(text: "Chest"); // Set the initial value to "Chest"

  List<Exercise> exercises = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    // Initialize Starting Values
    DateTime now = DateTime.now();
    _logTitleController.text= "Morning Workout";
    _logDateController.text = DateFormat('MMMM dd, yyyy').format(now);
    _logTimeController.text = DateFormat('h:mm a').format(now);
  }

  // SubmitLog Function - Saves values from input fields and submits to local database
  void _submitLog() async {
    final log = {
      'logTitle': _logTitleController.text,
      'logRoutine': _logRoutineController.text,
      'logDate': _logDateController.text,
      'logTime': _logTimeController.text,
      'logDescription': _logDescriptionController.text,
      'workoutType': _workoutTypeController.text
    };
    await DatabaseHelper().insertLog(log);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const HomeScreen()),
      );
  }

  // Pick Date Function - Implements date picker functionality
  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _logDateController.text = DateFormat('MMMM dd, yyyy').format(picked); // Format: November 23, 2023
      });
    }
  }

  // Pick Time Function - Implements time picker functionality
  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        String formattedTime = DateFormat('h:mm a')
            .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, picked.hour, picked.minute));
        _logTimeController.text = formattedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Log'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 16),
            const Text("Title"),
            const SizedBox(height: 4),
            TextField(
              controller: _logTitleController,
              decoration: InputDecoration(
                labelText: 'Title',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Description"),
            const SizedBox(height: 4),
            TextField(
              controller: _logDescriptionController,
              decoration: const InputDecoration(
                  labelText: 'Share more about your activity',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Type"),
            const SizedBox(height: 4),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: const InputDecoration(labelText: 'Workout Type',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _workoutTypeController.text,
                        isDense: true,
                        onChanged: (newValue) {
                          _workoutTypeController.text = newValue!; // Update the workout type
                          state.didChange(newValue);
                        },
                        items: [
                          "Chest",
                          "Back",
                          "Legs",
                          "Core",
                          "Cardio",
                          "Arms",
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            const Text("Date"),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(_dateFormat.format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Time"),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(_timeFormat.format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute))),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
            ),
            const SizedBox(height: 16),
            // Submit Log Button
            ElevatedButton(
              onPressed: _submitLog,
              child: const Text('Submit Log'),
            ),
          ],
        ),
      ),
    );
  }
}

