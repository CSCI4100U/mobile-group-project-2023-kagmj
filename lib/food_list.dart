import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'create_meals.dart';
import 'dart:convert';

//Food,Measure,Grams,Calories,Protein,Fat,Sat.Fat,Fiber,Carbs,Category
class Food {
  String? name;
  String? measurement;
  double? grams;
  double? calories;
  double? protein;
  double? fat;
  double? satfat;
  double? fiber;
  double? carbs;
  double? category;

  Food({
    this.name,
    this.measurement,
    this.grams,
    this.calories,
    this.protein,
    this.fat,
    this.satfat,
    this.fiber,
    this.carbs,
    this.category,
  });

  factory Food.fromCsv(List<dynamic> csvData) {
    return Food(
      name: csvData[0],
      measurement: csvData[1].toString(),
      grams: double.tryParse(csvData[2].toString()) ?? 0.0,
      calories: double.tryParse(csvData[3].toString()) ?? 0.0,
      protein: double.tryParse(csvData[4].toString()) ?? 0.0,
      fat: double.tryParse(csvData[5].toString()) ?? 0.0,
      satfat: double.tryParse(csvData[6].toString()) ?? 0.0,
      fiber: double.tryParse(csvData[7].toString()) ?? 0.0,
      carbs: double.tryParse(csvData[8].toString()) ?? 0.0,
      category: (int.tryParse(csvData[9].toString()) ?? 0).toDouble(),
    );
  }

  String toString() {
    return '$name, protein: $protein, calories: $calories, per $measurement)';
  }
}

class foodList extends StatefulWidget {
  //foodList({Key? key, this.title}):super(key: key);
  final void Function(List<dynamic>) onMealUpdated;

  String? title;

  final List<dynamic> initialMeals;

  foodList({super.key, this.title, required this.onMealUpdated, required this.initialMeals});

  @override
  State<foodList> createState() => _foodListState(initialMeals: initialMeals);

}

class _foodListState extends State<foodList> {


  _foodListState({required this.initialMeals});

  final List<dynamic> initialMeals;
  List<dynamic> meal = [];

  @override
  void initState() {
    super.initState();
    meal = List.from(initialMeals);
    loadFoods();
  }

  List<dynamic> _foods = [];
  List<dynamic> _filteredFoods = [];
  //List<dynamic> meal = [];

  List<dynamic> getMeal(){
    return meal;
  }

  Future<void> loadFoods() async {
    //var url = 'https://raw.githubusercontent.com/techjollof/USDA-Food-Database-Analyzing-Nutrient-Information/master/smallerDataSet.csv';
    var url = 'https://raw.githubusercontent.com/prasertcbs/basic-dataset/master/nutrients.csv';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<List<dynamic>> csvTable = CsvToListConverter().convert(
          response.body);

      setState(() {
        // Assuming your CSV has headers, you can skip the first row (index 0)
        _foods = csvTable.sublist(1);
      });
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  void filterFoods(String query) {
    setState(() {
      _filteredFoods = _foods
          .where((food) => food[0].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void addToMeal(List<dynamic> foodData) {
    try {
      Food food = Food.fromCsv(foodData);
      setState(() {
        meal.add(food);
      });

      // Call the callback to notify the parent
      widget.onMealUpdated(meal);

      // Display a success Snackbar
      const snackBar = SnackBar(
        content: Text('Food added successfully!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      // Display an error Snackbar
      const snackBar = SnackBar(
        content: Text('Failed to add food. Please try again.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print('Error $e');
    }
  }

  void deleteFood(int index) {
    setState(() {
      meal.removeAt(index);
    });

    // Display a success Snackbar
    const snackBar = SnackBar(
      content: Text('Food removed successfully!'),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      filterFoods(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Food',
                      hintText: 'Enter food name',
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredFoods.length,
                    itemBuilder: (context, index) {
                      var food = _filteredFoods[index];
                      return ListTile(
                        title: Text(food[0]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Calories: ${food[3]}"),
                            Text("Protein: ${food[4]}g"),
                            Text("per ${food[1]}"),
                          ],
                        ),
                        onTap: () {
                          addToMeal(food);
                          print(meal);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Divider between the two ListViews
          VerticalDivider(width: 1, color: Colors.black),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the title
              children: [
                SizedBox(height: 20),
                Text(
                  'Meal List',
                  style: TextStyle(
                    fontSize: 20, // Adjust the font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: meal.length,
                    itemBuilder: (context, index) {
                      var food = meal[index];
                      return ListTile(
                        title: Text(food.name ?? ""),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Calories: ${food.calories}"),
                            Text("Protein: ${food.protein}g"),
                            // Add more details as needed
                          ],
                        ),
                        onLongPress: () => deleteFood(index),                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}