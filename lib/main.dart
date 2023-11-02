import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'ProfileSetupScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define named routes
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/profileSetup': (context) => ProfileSetupScreen(),
      },
      // Set the initial route
      initialRoute: '/',
    );
  }
}
