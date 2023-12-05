import 'log_database.dart';
import 'settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
class MyGoalsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SetGoalsScreen(),
          ),
        );
      },
      child: SizedBox(
        width: screenWidth / 3.5,
        child: const Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.assistant_photo, size: 40),
                SizedBox(height: 6),
                Text(
                  'My Goals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
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
  int weeklyGoal = 0; // Example: Initialize with default value

  @override
  Widget build(BuildContext context) {
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
              'Set Your Weekly Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Add widgets to set the weekly goal (e.g., text field, sliders, etc.)
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Weekly Goal',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  weeklyGoal = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Display the weekly goal
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Weekly Goal'),
                      content: Text('Your weekly goal is: $weeklyGoal'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Display Goal'),
            ),
          ],
        ),
      ),
    );
  }
}