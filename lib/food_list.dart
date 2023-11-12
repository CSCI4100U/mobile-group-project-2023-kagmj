import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//below might not be necessary
class Food { //TODO swap this stuff to Food descriptors when finding a suitable JSON for now remains example from lectures
  int? id; //unique identifier for the object
  int? userId; //person who owns this object
  String? title;
  bool? completed;

  Food({this.title, this.completed, this.id, this.userId});

  factory Food.fromMap(Map map){
    return Food(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      completed: map['completed'],
    );
  }

  String toString(){
    return 'Todo($id, $userId, $title, $completed)';
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
  void initState(){
    super.initState();
    loadFoods();
  }

  List<dynamic> _foods = [];

  Future<void> loadFoods() async {
    var url = 'https://raw.githubusercontent.com/techjollof/USDA-Food-Database-Analyzing-Nutrient-Information/master/smallerDataSet.json';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _foods = json.decode(response.body);
      });
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food List'),
      ),
      body: ListView.builder(
        itemCount: _foods.length,
        itemBuilder: (context, index) {
          var food = _foods[index];
          return ListTile(
            title: Text(food['description']),
            subtitle: Text("ID: ${food['id']}"),
            onTap: () {
              print(food['nutrients']);
            },
          );
        },
      ),
    );
  }
}
