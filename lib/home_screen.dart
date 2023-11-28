import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/log_database.dart'; // Import your DatabaseHelper class
import 'create_log.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _logs = []; // List to hold logs
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
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile and name row
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(
                                avatarUrl) : null,
                            child: avatarUrl.isEmpty
                                ? Icon(Icons.person, size: 30)
                                : null,
                            radius: 20,
                          ),
                          SizedBox(width: 8),
                          Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Log title, date, and description
                      Text(log['logTitle'] ?? 'Untitled Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                          '${log['logDate'] ?? 'No Date'} at ${log['logTime'] ?? 'No Time'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey)
                      ),
                      SizedBox(height: 8),
                      Text(log['logDescription'] ?? 'No Description', style: TextStyle(fontSize: 16)),
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
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Log'),
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
      Scaffold(body: CreateLogScreen()),
      Scaffold(body: ProfileScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final _widgetOptions = _buildWidgetOptions();

    return Scaffold(
      appBar: _selectedIndex == 0 ? AppBar(title: Text("Home")) : null,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
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
