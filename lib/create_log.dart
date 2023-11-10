import 'package:flutter/material.dart';

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

  void _submitLog() {
    final logTitle = _logTitleController.text;
    final logRoutine = _logRoutineController.text;
    final logDate = _logDateController.text;
    final logTime = _logTimeController.text;
    final logDescription = _logDescriptionController.text;
    final logGear = _logGearController.text;
    final logMealName = _logMealNameController.text;
    final logRecipes = _logRecipesController.text;
    final logFoodItems = _logFoodItemsController.text;

    final workoutType = _workoutTypeController.text; // Get the workout type

    // Handle the submission of the exercise log data
    // ...

    // Clear the text fields after submission
    _clearTextFields();
  }

  void _clearTextFields() {
    _logTitleController.clear();
    _logRoutineController.clear();
    _logDateController.clear();
    _logTimeController.clear();
    _logDescriptionController.clear();
    _logGearController.clear();
    _logMealNameController.clear();
    _logRecipesController.clear();
    _logFoodItemsController.clear();
  }

  void addExercise(Exercise exercise) {
    setState(() {
      exercises.add(exercise);
    });
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
            TextField(
              controller: _logDateController,
              decoration: InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: _logTimeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: _logDescriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            if (_logType == "Workout")
              TextField(
                controller: _logGearController,
                decoration: InputDecoration(labelText: 'Gear Used'),
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

class Exercise {
  String title;
  String type;
  String gear;
  String schedule;
  String sets;
  String reps;
  String weight;

  Exercise({
    required this.title,
    required this.type,
    required this.gear,
    required this.schedule,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  factory Exercise.fromMap(Map map){
    return Exercise(
      title: map['title'],
      type: map['type'],
      gear: map['gear'],
      schedule: map['schedule'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
    );
  }

  String toString(){
    return 'Exercise($title,$type,$gear,$schedule,$sets,$reps,$weight)';
  }

}
class CreateExerciseScreen extends StatefulWidget {
  final Function(Exercise) addExercise;

  CreateExerciseScreen({required this.addExercise});

  @override
  _CreateExerciseScreenState createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String type = '';
  String gear = '';
  String schedule = '';
  String sets = '';
  String reps = '';
  String weight = '';
  List<Exercise> addedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Exercise Routine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Exercise Title'),
                    onSaved: (value) => title = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Exercise Type'),
                    onSaved: (value) => type = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Gear Used'),
                    onSaved: (value) => gear = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Schedule'),
                    onSaved: (value) => schedule = value!,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Exercise:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Sets'),
                    onSaved: (value) => sets = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Reps'),
                    onSaved: (value) => reps = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Weight'),
                    onSaved: (value) => weight = value!,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final newExercise = Exercise(
                          title: title,
                          type: type,
                          gear: gear,
                          schedule: schedule,
                          sets: sets,
                          reps: reps,
                          weight: weight,
                        );
                        setState(() {
                          addedExercises.add(newExercise);
                        });
                      }
                    },
                    child: Text('Add Exercise'),
                  ),
                ],
              ),
            ),

            // Display the added exercises below the form
            if (addedExercises.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Added Exercises', //TODO: ADD POST functionality to this instead of just pulling from item
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: addedExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = addedExercises[index];
                      return ListTile(
                        title: Text(exercise.title),
                        subtitle: Text(
                            'Type: ${exercise.type}, Gear: ${exercise.gear}, Schedule: ${exercise.schedule}\nSets: ${exercise.sets}, Reps: ${exercise.reps}, Weight: ${exercise.weight}'),
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

