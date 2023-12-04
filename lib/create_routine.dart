import 'package:flutter/material.dart';
import 'log_database.dart';
import 'routine.dart';

class CreateRoutinePage extends StatefulWidget {
  const CreateRoutinePage({super.key});

  @override
  _CreateRoutinePageState createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  String routineName = '';
  String days = '';
  String equipment = '';
  List<String> workouts = [''];

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

      // Create a Routine object
      final Routine newRoutine = Routine(
        name: routineName,
        days: days,
        equipment: equipment,
        workouts: workouts,
      );

      // Save the routine in the database
      await _databaseHelper.insertRoutine(newRoutine);

      // Show a SnackBar upon successful save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Routine successfully saved!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the form
      _formKey.currentState!.reset();
      setState(() {
        routineName = '';
        days = '';
        equipment = '';
        workouts = [''];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Routine'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Routine Name'),
                onSaved: (value) {
                  routineName = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Days'),
                onSaved: (value) {
                  days = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Equipment'),
                onSaved: (value) {
                  equipment = value ?? '';
                },
              ),
              Column(
                children: workouts.asMap().map((index, workout) {
                  return MapEntry(
                    index,
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: workout,
                            decoration: InputDecoration(labelText: 'Workout'),
                            onChanged: (value) {
                              workouts[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteWorkout(index),
                        ),
                      ],
                    ),
                  );
                }).values.toList(),
              ),
              ElevatedButton(
                onPressed: addWorkout,
                child: Text('Add Workout'),
              ),
              ElevatedButton(
                onPressed: saveRoutine,
                child: Text('Save Routine'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
