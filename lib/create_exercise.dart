import 'package:flutter/material.dart';

import 'exercise.dart';

class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({super.key});

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Exercise Added.')),
                      );
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
                  Text('Added Exercises',
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