// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/log_database.dart';
import 'home_screen.dart';
import 'food_list.dart';
import 'dart:convert';

class CreateMealScreen extends StatefulWidget {
  const CreateMealScreen({super.key});

  @override
  _CreateMealScreenState createState() => _CreateMealScreenState();
}

class _CreateMealScreenState extends State<CreateMealScreen> {
  final TextEditingController _logTitleController = TextEditingController();
  final TextEditingController _logRoutineController = TextEditingController();
  final TextEditingController _logDateController = TextEditingController();
  final TextEditingController _logTimeController = TextEditingController();
  final TextEditingController _logDescriptionController = TextEditingController();
  final TextEditingController _recipesController = TextEditingController();
  final TextEditingController _foodItemsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DateFormat _dateFormat = DateFormat('MMMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a');

  List<dynamic> meals = [];

  void handleMealUpdated(List<dynamic> updatedMeal) {
    meals = updatedMeal;
  }

  @override
  void initState() {
    super.initState();
    // Initialize Starting Values
    DateTime now = DateTime.now();
    _logTitleController.text= "Breakfast";
    _logDateController.text = DateFormat('MMMM dd, yyyy').format(now);
    _logTimeController.text = DateFormat('h:mm a').format(now);
  }

  @override
  void dispose() {
    _logTitleController.dispose();
    _logRoutineController.dispose();
    _logDateController.dispose();
    _logTimeController.dispose();
    _logDescriptionController.dispose();
    _recipesController.dispose();
    _foodItemsController.dispose();
    super.dispose();
  }

  // SubmitLog Function - Saves values from input fields and submits to local database
  void _submitLog() async {
    final log = {
      'type': 'meal',
      'logTitle': _logTitleController.text,
      'logDate': _logDateController.text,
      'logTime': _logTimeController.text,
      'logDescription': _logDescriptionController.text,
      'foodItems': /*_foodItemsController.text,*/jsonEncode(meals.map((meal) => meal.toString()).toList()),
      'recipes': _recipesController.text,
      //'meals': jsonEncode(meals.map((meal) => meal.toString()).toList()), // Convert meals to JSON string
    };

    await DatabaseHelper().insertLog(log);

    // Clear the _foodItemsController
    _foodItemsController.clear();

    // Reset the meals list
    setState(() {
      meals.clear();
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  // Pick Date Function - Implements date picker functionality
  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _logDateController.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
  }

  // Pick Time Function - Implements time picker functionality
  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        String formattedTime = DateFormat('h:mm a')
            .format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, picked.hour, picked.minute));
        _logTimeController.text = formattedTime;
      });
    }
  }

  double getCalories(List<dynamic> meals){
    double totalCals = 0.0;
    for (int i = 0; i < meals.length; i++){
      List<String> parts = meals[i].split('calories: ');
      if(parts.length == 2){
        String calStr = parts[1].split(',')[0].trim();
        double calInt = double.parse(calStr);
        totalCals += calInt;
      }else{
        print('Error');
      }
    }
    return totalCals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 16),
            const Text("Title"),
            const SizedBox(height: 4),
            TextField(
              controller: _logTitleController,
              decoration: InputDecoration(
                labelText: 'Title',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Description"),
            const SizedBox(height: 4),
            TextField(
              controller: _logDescriptionController,
              decoration: InputDecoration(
                labelText: 'Share more about your meal',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Recipes"),
            const SizedBox(height: 4),
            TextField(
              controller: _recipesController,
              decoration: InputDecoration(
                labelText: 'Add link to recipes',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("Food Items"),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => foodList(
                      title: 'Food List',
                      onMealUpdated: handleMealUpdated,
                      initialMeals: meals,
                    ),
                  ),
                );
              },
              child: Text('Food List'),
            ),
            const SizedBox(height: 16),
            const Text("Date"),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(_dateFormat.format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Time"),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(_timeFormat.format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute))),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
            ),
            const SizedBox(height: 16),
            // Submit Log Button
            ElevatedButton(
              onPressed: _submitLog,
              child: const Text('Submit Log'),
            ),
          ],
        ),
      ),
    );
  }
}
