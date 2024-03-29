import 'package:flutter/material.dart';
import 'log_database.dart'; // Import your DatabaseHelper

class MyGoalsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth / 3.5,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SetGoalsScreen(),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.assistant_photo),
                  iconSize: 40, // Set the size of the icon
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SetGoalsScreen(),
                      ),
                    );
                  },
                ),
                const Text(
                  'My Goals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetGoalsScreen extends StatefulWidget {
  @override
  _SetGoalsScreenState createState() => _SetGoalsScreenState();
}

class _SetGoalsScreenState extends State<SetGoalsScreen> {
  int caloriesBurnedGoal = 0;
  int waterIntakeGoal = 0;
  int workoutsCompletedGoal = 0;
  int caloriesGoal = 0;

  DatabaseHelper databaseHelper = DatabaseHelper(); // Instance of DatabaseHelper

  @override
  void initState() {
    super.initState();
    loadWeeklyGoalsFromDatabase();
  }

  void loadWeeklyGoalsFromDatabase() async {
    Map<String, int> lastGoals = await databaseHelper.getWeeklyGoals();

    setState(() {
      caloriesBurnedGoal = lastGoals['caloriesBurnedGoal'] ?? 0;
      waterIntakeGoal = lastGoals['waterIntakeGoal'] ?? 0;
      workoutsCompletedGoal = lastGoals['workoutsCompletedGoal'] ?? 0;
      caloriesGoal = lastGoals['caloriesGoal'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Goals'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Set Your Weekly Goals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              buildGoalTextFormField(
                labelText: 'Calories Burned Goal',
                initialValue: caloriesBurnedGoal.toString(),
                onChanged: (value) {
                  setState(() {
                    caloriesBurnedGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              buildGoalTextFormField(
                labelText: 'Water Intake Goal',
                initialValue: waterIntakeGoal.toString(),
                onChanged: (value) {
                  setState(() {
                    waterIntakeGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              buildGoalTextFormField(
                labelText: 'Workouts Completed Goal',
                initialValue: workoutsCompletedGoal.toString(),
                onChanged: (value) {
                  setState(() {
                    workoutsCompletedGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 10),
              buildGoalTextFormField(
                labelText: 'Calories Goal',
                initialValue: caloriesGoal.toString(),
                onChanged: (value) {
                  setState(() {
                    caloriesGoal = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  storeWeeklyGoals();
                  Navigator.pop(context);
                },
                child: const Text('Save Goals'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGoalTextFormField({
    required String labelText,
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid value';
        }
        return null;
      },
    );
  }

  void storeWeeklyGoals() async {
    Map<String, int> goals = {
      'caloriesBurnedGoal': caloriesBurnedGoal,
      'waterIntakeGoal': waterIntakeGoal,
      'workoutsCompletedGoal': workoutsCompletedGoal,
      'caloriesGoal': caloriesGoal,
    };

    await databaseHelper.insertWeeklyGoals(goals);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Weekly goals saved to the database'),
      ),
    );
  }
}

