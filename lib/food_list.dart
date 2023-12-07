import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';


class Food {
  String? name;
  double? protein;
  double? calories;
  String? measurement;

  Food({this.name,this.protein,this.calories,this.measurement});

  factory Food.fromCsv(List<dynamic> csvData) {
    return Food(
      name: csvData[0],
      calories: double.tryParse(csvData[3]),
      protein: double.tryParse(csvData[4]),
      measurement: csvData[1],
    );
  }

  String toString(){
    return 'Todo($name, $protein, $calories, $measurement)';
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
  List<Food> meal = [];


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
    Food food = Food.fromCsv(foodData);
    setState(() {
      meal.add(food);
    });
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