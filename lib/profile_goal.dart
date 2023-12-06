import 'package:flutter/material.dart';
class GoalsModel {
  final int caloriesBurnedGoal;
  final int waterIntakeGoal;
  final int workoutsCompletedGoal;
  final int caloriesGoal;

  GoalsModel({
    required this.caloriesBurnedGoal,
    required this.waterIntakeGoal,
    required this.workoutsCompletedGoal,
    required this.caloriesGoal,
  });
}
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

  @override
  Widget build(BuildContext context) {
    GoalsModel goalsModel = GoalsModel(
      caloriesBurnedGoal: 0,
      waterIntakeGoal: 0,
      workoutsCompletedGoal: 0,
      caloriesGoal: 0,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Set Your Weekly Goals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildGoalTextField(
              labelText: 'Calories Burned Goal',
              onChanged: (value) {
                setState(() {
                  caloriesBurnedGoal = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            buildGoalTextField(
              labelText: 'Water Intake Goal',
              onChanged: (value) {
                setState(() {
                  waterIntakeGoal = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            buildGoalTextField(
              labelText: 'Workouts Completed Goal',
              onChanged: (value) {
                setState(() {
                  workoutsCompletedGoal = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            buildGoalTextField(
              labelText: 'Calories Goal',
              onChanged: (value) {
                setState(() {
                  caloriesGoal = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Display the weekly goals
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Weekly Goals'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Calories Burned Goal: ${goalsModel.caloriesBurnedGoal}'),
                          Text('Water Intake Goal: ${goalsModel.waterIntakeGoal}'),
                          Text('Workouts Completed Goal: ${goalsModel.workoutsCompletedGoal}'),
                          Text('Calories Goal: ${goalsModel.caloriesGoal}'),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // Save the goals and pop the screen
                            Navigator.of(context).pop(goalsModel);
                          },
                          child: const Text('Save Goals'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Display Goals'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoalTextField({
    required String labelText,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
