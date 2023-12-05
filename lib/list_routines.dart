import 'package:final_project/routine.dart';
import 'package:final_project/view_routine.dart';
import 'package:flutter/material.dart';
import 'create_routine.dart';
import 'edit_routine.dart';
import 'log_database.dart';

class ListRoutinesScreen extends StatefulWidget {
  const ListRoutinesScreen({super.key});

  @override
  _ListRoutinesScreenState createState() => _ListRoutinesScreenState();
}

class _ListRoutinesScreenState extends State<ListRoutinesScreen> {
  List<Routine> routines = [];

  @override
  void initState() {
    super.initState();
    loadRoutines();
  }

  void loadRoutines() async {
    DatabaseHelper helper = DatabaseHelper();
    List<Routine> loadedRoutines = await helper.getRoutines();
    setState(() {
      routines = loadedRoutines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routines'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateRoutinePage(
                onRoutineCreated: () {
                  loadRoutines();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: routines.isEmpty
          ? const Center(child: Text('No routines available'))
          : ListView.builder(
        itemCount: routines.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(routines[index].name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRoutinePage(routine: routines[index]),
                        ),
                      ).then((_) {
                        loadRoutines(); // Refresh list after editing
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      if (routines[index].id != null) {
                        await DatabaseHelper().deleteRoutine(routines[index].id!);
                        loadRoutines(); // Reload routines to reflect the deletion
                      } else {
                        // Handle the case where id is null
                        print("Error: Routine ID is null");
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutineDetailsScreen(routineId: routines[index].id.toString()),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

}
