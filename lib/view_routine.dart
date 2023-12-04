import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart'; // Import DatabaseHelper
import 'package:final_project/routine.dart'; // Import Routine model

class RoutineDetailsScreen extends StatelessWidget {
  final String routineId;

  RoutineDetailsScreen({Key? key, required this.routineId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Routine Details'),
      ),
      body: FutureBuilder<Routine>(
        future: DatabaseHelper().getRoutineById(int.parse(routineId)), // Fetch routine
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Routine not found'));
          }
          Routine routine = snapshot.data!;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Name: ${routine.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Days: ${routine.days}'),
                Text('Equipment: ${routine.equipment}'),
                Text('Workouts: ${routine.workouts.join(", ")}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
