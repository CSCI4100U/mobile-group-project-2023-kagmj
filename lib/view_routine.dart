import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart'; // Import DatabaseHelper
import 'package:final_project/routine.dart'; // Import Routine model

class RoutineDetailsScreen extends StatelessWidget {
  final String routineId;

  const RoutineDetailsScreen({super.key, required this.routineId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Details'),
        centerTitle: true,
      ),
      body: FutureBuilder<Routine>(
        future: DatabaseHelper().getRoutineById(int.parse(routineId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Routine not found'));
          }
          Routine routine = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(routine.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Days: ${routine.days}'),
                Text('Equipment: ${routine.equipment}'),
                const SizedBox(height: 10),
                const Text('Workouts:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...routine.workouts.map((workout) => Text(workout, style: const TextStyle(fontSize: 20))),
              ],
            ),
          );
        },
      ),
    );
  }
}


