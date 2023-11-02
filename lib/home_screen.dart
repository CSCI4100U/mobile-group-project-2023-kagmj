import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'create_log.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    _checkProfileSetup();
  }

  Future<void> _checkProfileSetup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool profileSetupComplete = prefs.getBool('profileSetupComplete') ?? false;
    if (!profileSetupComplete) {
      // If the profile setup is not complete, navigate to the ProfileSetupScreen
      // Assuming you have a named route set up for the ProfileSetupScreen
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/profileSetup');
      });
    }
  }

  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    Text('Home Screen Placeholder'), // This will be your actual Home screen body
    CreateLogScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Social Media Platform'),
      ),
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
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
