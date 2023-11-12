import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:final_project/create_log.dart';

class exerciseList extends StatefulWidget {
  const exerciseList({super.key});

  @override
  State<exerciseList> createState() => _exerciseListState();
}

class _exerciseListState extends State<exerciseList> {

  List<Exercise> _exercises = [];

  @override
  void initState(){
    super.initState();
    loadExercises();
  }

  Future loadExercises() async{
    var response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
    if (response.statusCode == 200) {
      _exercises = [];
      List exercise_items = jsonDecode(response.body);
      for(var item in exercise_items){
        _exercises.add(Exercise.fromMap(item));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }


  //example one in lecture fit to use our exercises class
  // use this in the added exercises section
  // still needs to be edited
  //TODO
  Widget _createExercises(){
    if(_exercises.isEmpty){
      return CircularProgressIndicator();
    }else{
      return ListView.builder(
          itemCount: _exercises.length,
          itemBuilder: (BuildContext context, int index){
            return ListTile(
              title: Text(_exercises[index].title!),
            );
          }
      );
    }
  }

}
