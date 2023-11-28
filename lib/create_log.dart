import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart';
import 'package:final_project/food_list.dart';
import 'package:intl/intl.dart';
import 'create_exercise.dart';
import 'exercise.dart';
import 'home_screen.dart';

class CreateLogScreen extends StatefulWidget {
  @override
  _CreateLogScreenState createState() => _CreateLogScreenState();
}

class _CreateLogScreenState extends State<CreateLogScreen> {
  final TextEditingController _logTitleController = TextEditingController();
  final TextEditingController _logRoutineController = TextEditingController();
  final TextEditingController _logDateController = TextEditingController();
  final TextEditingController _logTimeController = TextEditingController();
  final TextEditingController _logDescriptionController = TextEditingController();
  final TextEditingController _logGearController = TextEditingController();
  final TextEditingController _logMealNameController = TextEditingController();
  final TextEditingController _logRecipesController = TextEditingController();
  final TextEditingController _logFoodItemsController = TextEditingController();
  final TextEditingController _workoutTypeController = TextEditingController(text: "Chest"); // Set the initial value to "Chest"
  String _logType = "Workout";
  List<Exercise> exercises = [];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a');
  String? _selectedGear;
  List<String> _gearItems = ['Dumbbells', 'Barbell', 'Add New Gear'];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _logTitleController.text= "Workout";
    _logDateController.text = DateFormat('MMMM dd, yyyy').format(now);
    _logTimeController.text = DateFormat('h:mm a').format(now);
  }

  void _submitLog() async {
    final log = {
      'logTitle': _logTitleController.text,
      'logRoutine': _logRoutineController.text,
      'logDate': _logDateController.text,
      'logTime': _logTimeController.text,
      'logDescription': _logDescriptionController.text,
      'logGear': _logGearController.text,
      'logMealName': _logMealNameController.text,
      'logRecipes': _logRecipesController.text,
      'logFoodItems': _logFoodItemsController.text,
      'workoutType': _workoutTypeController.text
    };
    await DatabaseHelper().insertLog(log);
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => HomeScreen()),
      );
  }

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

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        String formattedTime = DateFormat('h:mm a') // Format: 11:30 PM
            .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, picked.hour, picked.minute));
        _logTimeController.text = formattedTime;
      });
    }
  }

  void addExercise(Exercise exercise) {
    setState(() {
      exercises.add(exercise);
    });
  }

  void _addNewGear() async {
    String? newGearName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _newGearController = TextEditingController();
        return AlertDialog(
          title: const Text('Add New Gear'),
          content: TextField(
            controller: _newGearController,
            decoration: const InputDecoration(hintText: "Enter gear name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(_newGearController.text); // Return the new gear name
              },
            ),
          ],
        );
      },
    );

    if (newGearName != null && newGearName.isNotEmpty) {
      setState(() {
        _gearItems.insert(_gearItems.length - 1, newGearName); // Add new gear before 'Add New Gear...'
        _selectedGear = newGearName; // Update the selected gear to the new gear
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _logType = "Workout";
                      });
                    },
                    child: Text('Workout'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _logType = "Meal";
                      });
                    },
                    child: Text('Meal'),
                  ),
                ),
                if (_logType == "Workout")
                  Container(
                    margin: EdgeInsets.only(right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateExerciseScreen(addExercise: addExercise),
                          ),
                        );
                      },
                      child: Text('Create Exercise Routine'),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _logTitleController,
              decoration: InputDecoration(labelText: 'Log Title'),
            ),
            if (_logType == "Workout")
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(labelText: 'Workout Type'),
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
            if (_logType == "Workout")
              TextField(
                controller: _logRoutineController,
                decoration: InputDecoration(labelText: 'Routine Created'),
              ),
            ListTile(
              title: Text('Date: ${_dateFormat.format(_selectedDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              title: Text('Time: ${_timeFormat.format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute))}'),
              trailing: Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            TextField(
              controller: _logDescriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            if (_logType == "Workout")
              DropdownButtonFormField<String>(
                value: _selectedGear,
                hint: Text('Select Gear'),
                onChanged: (String? newValue) {
                  if (newValue == 'Add New Gear...') {
                    _addNewGear();
                  } else {
                    setState(() {
                      _selectedGear = newValue;
                    });
                  }
                },
                items: _gearItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            if (_logType == "Workout")
              ElevatedButton(
                onPressed: () {
                  // Handle image upload for workout
                },
                child: Text('Add Workout Image'),
              ),
            if (_logType == "Meal")
              TextField(
                controller: _logMealNameController,
                decoration: InputDecoration(labelText: 'Meal Name'),
              ),
            if (_logType == "Meal")
              TextField(
                controller: _logRecipesController,
                decoration: InputDecoration(labelText: 'Recipes'),
              ),
            if (_logType == "Meal")
              TextField(
                controller: _logFoodItemsController,
                decoration: InputDecoration(labelText: 'Food Items'),
              ),
            if(_logType == "Meal")
              ElevatedButton(onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => foodList(title: 'Food List'),
                  ),
                );
              }, child: Text('Food List')),
            if (_logType == "Meal")
              ElevatedButton(
                onPressed: () {
                  // Handle image upload for meal
                },
                child: Text('Add Meal Image'),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitLog,
              child: Text('Submit Log'),
            ),
            if (exercises.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created Exercises', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ListTile(
                        title: Text(exercise.title),
                        subtitle: Text(
                          'Type: ${exercise.type}, Gear: ${exercise.gear}, Schedule: ${exercise.schedule}\nSets: ${exercise.sets}, Reps: ${exercise.reps}, Weight: ${exercise.weight}',
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

