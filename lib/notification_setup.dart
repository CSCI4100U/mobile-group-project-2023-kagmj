import 'package:final_project/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'push_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSetup extends StatefulWidget {
  const NotificationSetup({Key? key}) : super(key: key);

  @override
  _NotificationSetupState createState() => _NotificationSetupState();
}

class _NotificationSetupState extends State<NotificationSetup> {
  // Set default selections
  List<String> notificationDays = [];
  TimeOfDay notificationTime = TimeOfDay(hour: 8, minute: 0);
  final PushNotificationService _notificationService = PushNotificationService();

  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _getSavedNotificationData();
    _notificationService.initialize();
    _checkNotificationPermission();
  }

  // To show current notification days/time selected through firebase
  Future<void> _getSavedNotificationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedNotificationDays = prefs.getStringList('notificationDays');
    int? savedHour = prefs.getInt('hour');
    int? savedMinute = prefs.getInt('minute');

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('profiles').doc(user.uid);

      DocumentSnapshot userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        bool notificationSetup = userDocSnapshot['notificationSetup'];

        // To show default days and times upon new account creation
        if (notificationSetup == false || savedNotificationDays == null || savedHour == null || savedMinute == null) {
          setState(() {
            notificationDays = [];
            notificationTime = const TimeOfDay(hour: 8, minute: 0);
          });
        } else {
          setState(() {
            notificationDays = savedNotificationDays;
            notificationTime = TimeOfDay(hour: savedHour, minute: savedMinute);
          });
        }
      }
    }
  }

  Future<void> _checkNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      _showNotificationPermissionDialog();
    }
  }

  // If notifications are not enabled, do not proceed to notification setup page
  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notifications Not Enabled'),
          content: Text('Please enable notifications for this app in your device settings.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: notificationTime,
    );
    if (picked != null && picked != notificationTime) {
      setState(() {
        notificationTime = picked;
      });
    }
  }

  // Saving schedule and uploading to firebase
  void _saveNotificationSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notificationDays', notificationDays);
    prefs.setInt('hour', notificationTime.hour);
    prefs.setInt('minute', notificationTime.minute);

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('profiles').doc(userId);

      DocumentSnapshot userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        await userDocRef.update({
          'notificationDays': notificationDays,
          'notificationHour': notificationTime.hour,
          'notificationMinute': notificationTime.minute,
          'notificationSetup': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule saved')),
        );

        scheduleNotification(_notificationService);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ERROR: USER PROFILE NOT FOUND')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ERROR: USER PROFILE NOT FOUND')),
      );
    }
  }

  // Call for a notification one minute after saving schedule
  // Unable to run the actual days and time notification since it needs to be paid for on firebase
  // This is a placeholder for that
  Future<void> scheduleNotification(PushNotificationService notificationService) async {
    await Future.delayed(const Duration(minutes: 1));
    notificationService.sendNotification('Workout time!', 'Log your first workout!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Setup'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Days for Workout Reminders:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                buildDayCheckbox('Monday'),
                buildDayCheckbox('Tuesday'),
                buildDayCheckbox('Wednesday'),
                buildDayCheckbox('Thursday'),
                buildDayCheckbox('Friday'),
                buildDayCheckbox('Saturday'),
                buildDayCheckbox('Sunday'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Select Time: ${notificationTime.format(context)}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveNotificationSchedule();
              },
              child: const Text('Save Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDayCheckbox(String day) {
    return FilterChip(
      label: Text(day),
      selected: notificationDays.contains(day),
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            notificationDays.add(day);
          } else {
            notificationDays.remove(day);
          }
        });
      },
      backgroundColor: Colors.blue[100],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
    );
  }
}
