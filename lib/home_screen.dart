// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'dart:async';
import 'package:final_project/log_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/view_routine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'create_routine.dart';
import 'create_water.dart';
import 'create_log.dart';
import 'create_meals.dart';
import 'list_routines.dart';
import 'profile.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _lastPosition;
  bool _isLocationAdded = false;

  int _selectedIndex = 0;
  int _dailyCaloriesBurned=0;
  final Duration _cooldownDuration = Duration(seconds: 20);
  List<Map<String, dynamic>> _logs = [];
  String userName = '';
  String avatarUrl = '';
  String _waterIntakeValue = 'XX ml'; // Initialize _waterIntakeValue here
  int _totalWorkouts = 0;
  static const double caloriesBurnedPerKm = 1.5;
  double userWeight = 70.0;
  bool isLoggedIn=false;
  Timer? caloriesTimer;
  Timer? distanceTimer;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _loadProfileData();
    _loadUserWeight();
    _getPosition();
    _startPeriodicFunctions();
  }
  @override
  void dispose() {
    caloriesTimer?.cancel();
    distanceTimer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
  void _startPeriodicFunctions() {
    if (mounted) {
      caloriesTimer = Timer.periodic(const Duration(seconds: 35), (timer) {
        _loadUserWeight().then((_) {
          calculateCaloriesBurned();
        });
      });

      distanceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _getPosition();
      });
    }
  }

  Future<void> _getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle denied permission scenario here
        return;
      }
    }
    _positionStreamSubscription = Geolocator.getPositionStream().listen(
          (Position position) async {
            // Store location data in Firestore
            GeoPoint geoPoint = GeoPoint(position.latitude, position.longitude);
            if (FirebaseAuth.instance.currentUser != null) {
              print('Added');
              String? userId = FirebaseAuth.instance.currentUser?.uid;
              await FirebaseFirestore.instance.collection('locations').add({
                'userId': userId,
                'position': geoPoint,
                'timestamp': DateTime
                    .now()
                    .millisecondsSinceEpoch,
              });
              _isLocationAdded = true;
            }
            _lastPosition = position;

            // Start cooldown period before allowing next addition
            Future.delayed(_cooldownDuration, () {
              _isLocationAdded = false;
            });
          },
      onError: (dynamic error) {
        if (error is PermissionDeniedException) {
          // Handle permission denied error here
        }
      },
    );
  }

  Future<double> getDailyDistance(String userId) async {
    DateTime now = DateTime.now();
    int todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    int todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: todayStart)
        .where('timestamp', isLessThanOrEqualTo: todayEnd)
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


    return totalDistance;
  }

  void calculateCaloriesBurned() async {
    // Ensure user weight is available before calculations
    if (userWeight != null) {
      if (FirebaseAuth.instance.currentUser != null) {
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        try {
          double distance = await getDailyDistance(userId!) as double;
          int calculatedCalories = (caloriesBurnedPerKm * (distance / 1000) * userWeight!).toInt();
          setState(() {
            _dailyCaloriesBurned = calculatedCalories;
          });
        } catch (e) {
          print('Error calculating daily distance: $e');
        }
      }
    }
  }

  Future<void> _loadUserWeight() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('profiles').doc(user.uid).get();
      if (userProfile.exists) {
        Map<String, dynamic>? data = userProfile.data() as Map<String,
            dynamic>?;
          userWeight =  double.parse(data?['weight']);
          isLoggedIn =  data?['profileSetupComplete'];
      }
    }
  }
  Future<void> _fetchLogs() async {
    _logs = await DatabaseHelper().getLogs(); // Fetch logs from the database

    // Fetch water intake specifically
    Map<String, dynamic>? waterIntakeLog = _logs.firstWhere((log) => log['type'] == 'water', orElse: () => {'waterIntake': null});

    // Extract and update the water intake value
    String waterIntakeValue = waterIntakeLog['waterIntake'] != null ? '${waterIntakeLog['waterIntake']} ml' : 'XX ml';

    // Fetch workout logs
    try {
      // Get total workouts using DatabaseHelper function
      Map<int, int> workoutsPerLog = await DatabaseHelper().getTotalWorkoutsPerLog();

      // Calculate total workouts from the map values
      int total = workoutsPerLog.values.fold(0, (sum, count) => sum + count);

      setState(() {
        _waterIntakeValue=waterIntakeValue;
        _totalWorkouts = total;
      });
    } catch (e) {
      print('Error fetching total workouts: $e');
    }
  }
  void _deleteLog(int id) async {
    await DatabaseHelper().deleteLog(id); // Delete from database
    setState(() {
      _logs.removeWhere((log) => log['id'] == id); // Remove from UI
    });
  }

  Future<void> _loadProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('profiles').doc(user.uid).get();
      if (userProfile.exists) {
        Map<String, dynamic>? data = userProfile.data() as Map<String,
            dynamic>?;
        setState(() {
          userName = data?['name'] ?? '';
          avatarUrl = data?['avatarUrl'] ??
              '';
        });
      }
    }
  }

  Widget _buildHomeScreen() {
    return  RefreshIndicator(
            onRefresh: _fetchLogs,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
      // Daily Goals Tracker Card
      Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Daily Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            // 2x2 layout for the goal details
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the Row
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildGoalDetail('Calories Burned', '$_dailyCaloriesBurned', Icons.local_fire_department),
                        _buildSpacer(),
                        _buildGoalDetail('Number of Workouts', '$_totalWorkouts', Icons.fitness_center),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildGoalDetail('Water Intake', _waterIntakeValue, Icons.local_drink),
                        _buildSpacer(),
                        _buildGoalDetail('Calories Intake', 'XXXX', Icons.fastfood),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Expanded(
      child: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (BuildContext context, int index) {
          var log = _logs[index];
          String displayTitle;
          if (log['type'] == 'meal') {
            displayTitle = log['logTitle'] ?? 'No Title';
          } else if (log['type'] == 'workout') {
            displayTitle = "${log['logTitle'] ?? 'No Title'} - ${log['workoutType'] ?? 'No Workout Type'}";
          }
          else if (log['type'] == 'water') {
            return Container();
          }
          else {
            displayTitle = log['logTitle'] ?? 'No Title';
          }
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile and name row
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(
                                avatarUrl) : null,
                            radius: 20,
                            child: avatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 30)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Log title, date, and description
                      Text(displayTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          '${log['logDate'] ?? 'No Date'} at ${log['logTime'] ?? 'No Time'}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey)
                      ),
                      const SizedBox(height: 8),
                      Text(log['logDescription'] ?? 'No Description', style: const TextStyle(fontSize: 16)),
                      if (log['type'] == 'workout') ...[
                        const SizedBox(height: 15),
                        const Text(
                            "Time",
                            style: TextStyle(fontSize: 14)
                        ),
                        Text('${log['logDuration'] ?? 'N/A'}', style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Convert routineId to String if RoutineDetailsScreen expects a String
                            dynamic routineId = log['routineId'];
                            if (routineId != null) {
                              String routineIdAsString = '$routineId';
                              if (routineIdAsString.isNotEmpty && int.tryParse(routineIdAsString) != null) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RoutineDetailsScreen(routineId: routineIdAsString)));
                              } else {
                                // Handle the case where routineId is not a valid number
                                print('Invalid routineId: $routineIdAsString');
                              }
                            } else {
                              // Handle the case where routineId is null
                              print('RoutineId is null');
                            }
                          },
                          child: Text('View Routine'),
                        ),
                      ],
                      if (log['type'] == 'meal') ...[
                        const SizedBox(height: 15),
                        const Text(
                            "Food Items:",
                            style: TextStyle(fontSize: 18)
                        ),
                        Text(log['foodItems'] ?? 'No Food Items'),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              children: _buildTextSpans(log['recipes']),
                              style: DefaultTextStyle.of(context).style,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'delete') {
                        _deleteLog(log['id']);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => super.widget));
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    )]));
  }
  Widget _buildSpacer() {
    return SizedBox(height: 16);
  }

  Widget _buildGoalDetail(String title, String value, IconData iconData) {
    return Row(
      children: [
        Icon(iconData),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildWidgetOptions() {
    return <Widget>[
      WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: _buildHomeScreen(),
      ),
      WillPopScope(
        onWillPop: () async {
          caloriesTimer?.cancel();
          distanceTimer?.cancel();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return true;
        },
        child: const Scaffold(body: CreateMealScreen()),
      ),
      WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: const Scaffold(body: CreateLogScreen()),
      ),
      WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: const Scaffold(body: CreateWaterScreen()),
      ),
      WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: const Scaffold(body: ListRoutinesScreen()),
      ),
      WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: const Scaffold(body: ProfileScreen()),
      ),
    ];
  }


  List<TextSpan> _buildTextSpans(String text) {
    final RegExp linkRegExp = RegExp(r'\bhttps?:\/\/\S+\b', caseSensitive: false);
    final Iterable<RegExpMatch> matches = linkRegExp.allMatches(text);

    if (matches.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    int start = 0;

    for (final RegExpMatch match in matches) {
      final String linkText = match.group(0)!;
      final int startIndex = match.start;
      final int endIndex = match.end;

      if (startIndex > start) {
        spans.add(TextSpan(text: text.substring(start, startIndex)));
      }

      spans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(linkText)) {
                await launch(linkText);
              }
            },
        ),
      );

      start = endIndex;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final widgetOptions = _buildWidgetOptions();
    return Scaffold(
      appBar: _selectedIndex == 0 ? AppBar(title: const Text("Home"), automaticallyImplyLeading: false, centerTitle: true,) : null,
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Log Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Log Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined),
            label: 'Log Water',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_rounded),
            label: 'Routines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),

    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
