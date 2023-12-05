import 'package:flutter/material.dart';
import 'log_database.dart';
import 'routine.dart';

class EditRoutinePage extends StatefulWidget {
  final Routine routine;
  const EditRoutinePage({super.key, required this.routine});

  @override
  _EditRoutinePageState createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends State<EditRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  late String routineName;
  late String days;
  late String equipment;
  late List<String> workouts;

  // Create an instance of DatabaseHelper
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // Initialize form fields with routine data
    routineName = widget.routine.name;
    days = widget.routine.days;
    equipment = widget.routine.equipment;
    workouts = widget.routine.workouts;
  }

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

      // Update routine object
      Routine updatedRoutine = Routine(
        id: widget.routine.id,
        name: routineName,
        days: days,
        equipment: equipment,
        workouts: workouts,
      );

      // Update the routine in the database
      await _databaseHelper.updateRoutine(updatedRoutine);

      // Navigate back or show a confirmation message
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Routine'),
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
                initialValue: routineName,
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
                initialValue: days,
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
                initialValue: equipment,
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
