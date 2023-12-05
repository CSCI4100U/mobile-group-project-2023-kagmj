// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/view_routine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'create_routine.dart';
import 'create_log.dart';
import 'create_meals.dart';
import 'list_routines.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _logs = [];
  String userName = '';
  String avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _loadProfileData();
  }

  Future<void> _fetchLogs() async {
    _logs = await DatabaseHelper().getLogs(); // Fetch logs from the database
    setState(() {});
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
    return RefreshIndicator(
      onRefresh: _fetchLogs,
      child: ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (BuildContext context, int index) {
          var log = _logs[index];
          String displayTitle;
          if (log['type'] == 'meal') {
            displayTitle = log['logTitle'] ?? 'No Title';
          } else if (log['type'] == 'workout') {
            displayTitle = "${log['logTitle'] ?? 'No Title'} - ${log['workoutType'] ?? 'No Workout Type'}";
          } else {
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
                            String routineIdAsString = log['routineId'].toString();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RoutineDetailsScreen(routineId: routineIdAsString)));
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
    );
  }

  List<Widget> _buildWidgetOptions() {
    return <Widget>[
      _buildHomeScreen(),
      const Scaffold(body: CreateMealScreen()),
      const Scaffold(body: CreateLogScreen()),
      const Scaffold(body: ListRoutinesScreen()),
      const Scaffold(body: ProfileScreen()),
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
