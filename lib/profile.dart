// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:final_project/profile_my_meal.dart';
import 'package:final_project/view_routine.dart';
import 'package:geolocator/geolocator.dart';

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
  late Timer _timer;
  double userWeight=0;
  int caloriesBurned=0;
  static const double caloriesBurnedPerKm = 1.5;
  int totalWorkouts = 0; // New variable to store the total workout count

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  @override
  void dispose() {
    // Dispose the timer when the widget is removed
    _timer.cancel();
    super.dispose();
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
          avatarUrl = data?['avatarUrl'] ?? '';
          userWeight = double.parse(data?['weight']);
        });
      }
    }
    _loadAdditionalData();
  }

  Future<void> _loadAdditionalData() async {
    // Load workouts and calories after profile data is loaded
    await _loadTotalWorkouts();
    await _loadCaloriesBurned();
    _startTimer(); // Start the timer after loading data
  }
  Future<void> _loadCaloriesBurned() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .orderBy('timestamp')
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = querySnapshot.docs;

    double totalDistance = 0;

    if (documents.isNotEmpty) {
      for (int i = 0; i < documents.length - 1; i++) {
        GeoPoint point1 = documents[i]['position'] as GeoPoint;
        GeoPoint point2 = documents[i + 1]['position'] as GeoPoint;

        double lat1 = point1.latitude;
        double lon1 = point1.longitude;
        double lat2 = point2.latitude;
        double lon2 = point2.longitude;

        totalDistance += Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      }
    }
    int calculatedCalories = (caloriesBurnedPerKm * (totalDistance / 1000) * userWeight!).toInt();
    setState(() {
      caloriesBurned=calculatedCalories;
    });
  }
  void _startTimer() {
    // Execute _loadTotalCaloriesBurned() every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadCaloriesBurned();
    });
  }
  Future<void> _loadTotalWorkouts() async {
    try {
      // Get total workouts using DatabaseHelper function
      Map<int, int> workoutsPerLog = await DatabaseHelper().getTotalWorkoutsPerLog();

      // Calculate total workouts from the map values
      int total = workoutsPerLog.values.fold(0, (sum, count) => sum + count);

      if (mounted) {
        setState(() {
          totalWorkouts = total;
        });
      }
    } catch (e) {
      print('Error fetching total workouts: $e');
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
    child: SingleChildScrollView(
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
            StatisticsCard(totalWorkouts: totalWorkouts, caloriesBurned: caloriesBurned,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust this as needed
              children: <Widget>[
                MyGoalsCard(), // MyGoalsCard
                MyWorkoutsCard(), // MyWorkoutsCard
                MyMealsCard(), // MyMealsCard
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                WeeklyGoalProgress(),
              ]
            )

          ],
        ),
    ),
      ),
    );
  }
}
class StatisticsCard extends StatefulWidget {
  final int totalWorkouts;
  final int caloriesBurned;

  const StatisticsCard({
    Key? key,
    required this.totalWorkouts,
    required this.caloriesBurned,
  }) : super(key: key);

  @override
  _StatisticsCardState createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  int goalWorkout = 50; // Set your workout goal here
  int goalCaloriesBurned = 500; // Set your calorie burning goal here

  @override
  Widget build(BuildContext context) {
    int workoutAchievements = widget.totalWorkouts ~/ goalWorkout;
    int caloriesAchievements = widget.caloriesBurned ~/ goalCaloriesBurned;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Your Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProgressIndicator(
              value: (widget.totalWorkouts % goalWorkout) / goalWorkout,
              color: Colors.blue, // Workout progress color
              label: 'Workouts',
              currentValue: widget.totalWorkouts,
              goalValue: goalWorkout,
              achievements: workoutAchievements,
            ),
            const SizedBox(height: 20),
            _buildProgressIndicator(
              value: (widget.caloriesBurned % goalCaloriesBurned) / goalCaloriesBurned,
              color: Colors.red, // Calories burned progress color
              label: 'Calories Burned',
              currentValue: widget.caloriesBurned,
              goalValue: goalCaloriesBurned,
              achievements: caloriesAchievements,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required double value,
    required Color color,
    required String label,
    required int currentValue,
    required int goalValue,
    required int achievements,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '$currentValue / $goalValue',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        if (achievements > 0) ...[
          const SizedBox(height: 5),
          Text(
            'Achievements: $achievements',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ],
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
    int adjustedGoalValue = goalValue != 0 ? goalValue : 1;
    double progress = currentValue / adjustedGoalValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          goalName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          height: 24, // Set a fixed height for the CircularProgressIndicator
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(height: 4), // Adjusted spacing
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
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 82), //this is the padding above and sides of WeeklyGoalProgress
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Weekly Goals Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GoalProgressIndicator(
                  goalName: 'Calories Burned',
                  currentValue: 0,
                  goalValue: weeklyGoals['caloriesBurnedGoal'] != 0
                      ? weeklyGoals['caloriesBurnedGoal']!
                      : 2500,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GoalProgressIndicator(
                  goalName: 'Water Intake',
                  currentValue: 0,
                  goalValue: weeklyGoals['waterIntakeGoal'] != 0
                      ? weeklyGoals['waterIntakeGoal']!
                      : 28000,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GoalProgressIndicator(
                  goalName: 'Workouts Completed',
                  currentValue: 0,
                  goalValue: weeklyGoals['workoutsCompletedGoal'] != 0
                      ? weeklyGoals['workoutsCompletedGoal']!
                      : 15,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GoalProgressIndicator(
                  goalName: 'Calories',
                  currentValue: 0,
                  goalValue: weeklyGoals['caloriesGoal'] != 0
                      ? weeklyGoals['caloriesGoal']!
                      : 150000,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
