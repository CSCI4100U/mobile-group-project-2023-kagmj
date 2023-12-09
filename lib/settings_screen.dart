// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'notification_setup.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key});

  // Logout Function - Logs the user out from Firebase and brings them back to the login screen
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      ModalRoute.withName('/'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You\'ve Been Logged Out')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Log Out'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationSetup()),
                );
              },
              child: const Text('Edit Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
