import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  List<Food> _foods = [];

  Future loadFoods() async{
    var response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
    if (response.statusCode == 200) {
      _foods = [];
      List food_items = jsonDecode(response.body);
      for(var item in food_items){
        _foods.add(Food.fromMap(item));
      }
    }
  }

  Widget _createFoodList(){
    if (_foods.length == 0){
      return CircularProgressIndicator();
    }
    return ListView.builder(
        itemCount: _foods.length,
        itemBuilder: (BuildContext context, int index){
          return ListTile(
            title: Text(_foods[index].title!),
              subtitle: Text(_foods[index].userId.toString()),
            leading: Checkbox(
              value: _foods[index].completed,
              onChanged: (value){
                setState(() {
                  _foods[index].completed = value;
                });
              },
            ),
          );
      }
    );
  }

  Future httppush() async{ //dont know if we'll need this in the future when changed to foods
    var response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/todos'),
      headers: <String,String> {
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String,dynamic> {
        'title': 'sample text',
        'userId': 420,
        'completed': true
      }),
    );
    setState(() {
      _foods.add(Food.fromMap(jsonDecode(response.body)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: [
          IconButton(
              onPressed: (){
                List<Food> newFood = [];
                for (var food in _foods){
                  if (!food.completed!){
                    newFood.add(food);
                  } else{
                    http.delete(
                        Uri.parse(
                            'https://jsonplaceholder.typicode.com/todos/${food.id}'
                        )
                    );
                  }
                  setState(() {
                    _foods = newFood;
                  });
                }
              },
              icon: Icon(Icons.delete)
          ),
        ],
      ),
      body: _createFoodList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: httppush,
      ),
    );
  }
}
