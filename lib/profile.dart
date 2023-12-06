// ignore_for_file: library_private_types_in_public_api

import 'package:final_project/profile_my_meal.dart';
import 'package:final_project/view_routine.dart';

import 'log_database.dart';
import 'settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
import 'profile_goal.dart';
import 'profile_my_workout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String country = '';
  String avatarUrl = '';
  int totalWorkouts = 0; // New variable to store the total workout count

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadTotalWorkouts();
  }

  Future<void> _loadTotalWorkouts() async {
    try {
      // Get total workouts using DatabaseHelper function
      Map<int, int> workoutsPerLog = await DatabaseHelper().getTotalWorkoutsPerLog();

      // Calculate total workouts from the map values
      int total = workoutsPerLog.values.fold(0, (sum, count) => sum + count);

      setState(() {
        totalWorkouts = total;
      });
    } catch (e) {
      print('Error fetching total workouts: $e');
    }
  }
  // Load Profile Data - Loads information from Firebase for the current user
  Future<void> _loadProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('profiles').doc(user.uid).get();
      if (userProfile.exists) {
        Map<String, dynamic>? data = userProfile.data() as Map<String,
            dynamic>?;
        setState(() {
          name = data?['name'] ?? '';
          country = data?['country'] ?? '';
          avatarUrl = data?['avatarUrl'] ??
              '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(
                      avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        country,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),const SizedBox(height: 20),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const EditProfileScreen()),
                    ).then((_) {
                      _loadProfileData();
                    });
                  },
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
            StatisticsCard(totalWorkouts: totalWorkouts),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust this as needed
              children: <Widget>[
                MyGoalsCard(), // MyGoalsCard
                MyWorkoutsCard(), // MyWorkoutsCard
                MyMealsCard(), // MyMealsCard
              ],
            ),
            WeeklyGoalProgress(),
          ],
        ),
      ),
    );
  }
}
class StatisticsCard extends StatefulWidget {
  final int totalWorkouts;

  const StatisticsCard({Key? key, required this.totalWorkouts}) : super(key: key);

  @override
  _StatisticsCardState createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  int goalWorkout = 50;

  @override
  Widget build(BuildContext context) {
    int achievements = widget.totalWorkouts ~/ goalWorkout;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(Icons.directions_run),
                Text(
                  'Total Workouts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (widget.totalWorkouts % goalWorkout) / goalWorkout,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Workouts: ${widget.totalWorkouts}',
              style: const TextStyle(fontSize: 16),
            ),
            if (achievements > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Achievements: $achievements',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Goal Workout: $goalWorkout',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant StatisticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    int oldAchievements = oldWidget.totalWorkouts ~/ goalWorkout;
    int newAchievements = widget.totalWorkouts ~/ goalWorkout;

    if (oldAchievements < newAchievements) {
      setState(() {
        goalWorkout += 50;
      });
    }
  }
}
class GoalProgressIndicator extends StatelessWidget {
  final String goalName;
  final int currentValue;
  final int goalValue;

  const GoalProgressIndicator({
    Key? key,
    required this.goalName,
    required this.currentValue,
    required this.goalValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensuring goalValue is not zero or null
    int adjustedGoalValue = goalValue != 0 ? goalValue : 1;

    double progress = currentValue / adjustedGoalValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          goalName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Text(
          'Current: $currentValue',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Goal: $goalValue',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class WeeklyGoalProgress extends StatefulWidget {
  @override
  _WeeklyGoalProgressState createState() => _WeeklyGoalProgressState();
}

class _WeeklyGoalProgressState extends State<WeeklyGoalProgress> {
  Map<String, int> weeklyGoals = {
    'caloriesBurnedGoal': 0,
    'waterIntakeGoal': 0,
    'workoutsCompletedGoal': 0,
    'caloriesGoal': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadWeeklyGoals();
  }

  Future<void> _loadWeeklyGoals() async {
    try {
      Map<String, int> goals = await DatabaseHelper().getWeeklyGoals();
      setState(() {
        weeklyGoals = goals;
      });
    } catch (e) {
      print('Error fetching weekly goals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Weekly Goals Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 10), // Add bottom padding for space
                child: GoalProgressIndicator(
                  goalName: 'Calories Burned',
                  currentValue: 0,
                  goalValue: weeklyGoals['caloriesBurnedGoal'] != 0
                      ? weeklyGoals['caloriesBurnedGoal']!
                      : 1, // Ensuring goal value isn't zero
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10), // Add bottom padding for space
                child: GoalProgressIndicator(
                  goalName: 'Water Intake',
                  currentValue: 0,
                  goalValue: weeklyGoals['waterIntakeGoal'] != 0
                      ? weeklyGoals['waterIntakeGoal']!
                      : 1, // Ensuring goal value isn't zero
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10), // Add bottom padding for space
                child: GoalProgressIndicator(
                  goalName: 'Workouts Completed',
                  currentValue: 0,
                  goalValue: weeklyGoals['workoutsCompletedGoal'] != 0
                      ? weeklyGoals['workoutsCompletedGoal']!
                      : 1, // Ensuring goal value isn't zero
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10), // Add bottom padding for space
                child: GoalProgressIndicator(
                  goalName: 'Calories',
                  currentValue: 0,
                  goalValue: weeklyGoals['caloriesGoal'] != 0
                      ? weeklyGoals['caloriesGoal']!
                      : 1, // Ensuring goal value isn't zero
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



