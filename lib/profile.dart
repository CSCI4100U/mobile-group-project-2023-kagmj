import 'SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String birthday = '';
  // Add any other fields you collect on the ProfileSetupScreen

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Debug print statements to check the values retrieved from SharedPreferences
    print("Name from prefs: \${prefs.getString('name')}");
    print("Birthday from prefs: \${prefs.getString('birthday')}");
    setState(() {
      name = prefs.getString('name') ?? 'N/A';
      birthday = prefs.getString('birthday') ?? 'N/A';
      // Load other fields similarly
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Name: $name'),
            Text('Birthday: $birthday'),
            // Display other fields here
          ],
        ),
      ),
    );
  }
}

class SettingsScreenPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings page placeholder'),
      ),
    );
  }
}
