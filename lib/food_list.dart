import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'create_meals.dart';
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
      measurement: csvData[1],
      grams: double.tryParse(csvData[2].toString()) ?? 0.0,
      calories: double.tryParse(csvData[3].toString()) ?? 0.0,
      protein: double.tryParse(csvData[4].toString()) ?? 0.0,
      fat: double.tryParse(csvData[5].toString()) ?? 0.0,
      satfat: double.tryParse(csvData[6].toString()) ?? 0.0,
      fiber: double.tryParse(csvData[7].toString()) ?? 0.0,
      carbs: double.tryParse(csvData[8].toString()) ?? 0.0,
      category: double.tryParse(csvData[9].toString()) ?? 0.0,
    );
  }

  String toString() {
    return 'Food($name, $protein, $calories, $measurement)';
  }
}

class foodList extends StatefulWidget {
  foodList({Key? key, this.title}):super(key: key);

  String? title;

  @override
  State<foodList> createState() => _foodListState();

}

class _foodListState extends State<foodList> {


  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  List<dynamic> _foods = [];
  List<dynamic> _filteredFoods = [];
  List<dynamic> meal = [];


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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
      ),
      body: Column(
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
    );
  }
}