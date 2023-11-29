import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'profile_setup.dart';
import 'push_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Main Method
// Stars the application
Future<void> main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Error Logging
    if (kDebugMode) {
      print('Firebase initialized successfully');
    }

  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }

  // Initialize push notifications
  PushNotificationService().initialize();

  // Run App
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

// MyApp Method
// Sets up the user interface
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define routes to different screens
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profileSetup': (context) => const ProfileSetupScreen(),
      },
      // If user is already logged in, go to home page, if not, go to login
      initialRoute: isLoggedIn ? '/home' : '/',
    );
  }
}
