// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'log_database.dart';
import 'routine.dart';

class CreateRoutinePage extends StatefulWidget {
  final Function onRoutineCreated;
  const CreateRoutinePage({super.key, required this.onRoutineCreated});

  @override
  _CreateRoutinePageState createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  String routineName = '';
  String days = '';
  String equipment = '';
  List<String> workouts = [''];
  int workoutCount = 0;

  // Create an instance of DatabaseHelper
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void addWorkout() {
    setState(() {
      workouts.add('');
    });
  }

  void deleteWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
    });
  }
  Future<void> saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      workoutCount = workouts.length;
      // Create a Routine object
      final Routine newRoutine = Routine(
        name: routineName,
        days: days,
        equipment: equipment,
        workouts: workouts,
        workoutCount: workoutCount,
      );

      // Save the routine in the database
      await _databaseHelper.insertRoutine(newRoutine);

      // Show a SnackBar upon successful save
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Routine successfully saved!'),
          duration: Duration(seconds: 2),
        ),
      );

      widget.onRoutineCreated();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Routine'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Title"),
              ),
              const SizedBox(height: 4),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Routine Name',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSaved: (value) {
                  routineName = value ?? '';
                },
              ),

              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Days"),
              ),
              const SizedBox(height: 4),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Days',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),),
                onSaved: (value) {
                  days = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Gear"),
              ),
              const SizedBox(height: 4),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Equipment',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSaved: (value) {
                  equipment = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Workouts"),
              ),
              const SizedBox(height: 4),
              Column(
                children: workouts.asMap().entries.expand((entry) {
                  int index = entry.key;
                  String workout = entry.value;

                  return [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: workout,
                            decoration: InputDecoration(
                              labelText: 'Workout',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onChanged: (value) {
                              workouts[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteWorkout(index),
                        ),
                      ],
                    ),
                    if (index < workouts.length - 1) const SizedBox(height: 8), // Add spacing
                  ];
                }).toList(),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: addWorkout,
                child: const Text('Add Workout'),
              ),
              ElevatedButton(
                onPressed: saveRoutine,
                child: const Text('Save Routine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
