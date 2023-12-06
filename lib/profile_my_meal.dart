import 'package:final_project/view_routine.dart';

import 'log_database.dart';
import 'package:flutter/material.dart';
class MyMealsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth / 3.5,
      child: Card(

        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.restaurant),
                    iconSize: 40, // Set the size of the icon
                    onPressed: () {
                      // Navigate to the SetGoalsScreen when the icon is pressed
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SetMealScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Text(
                'My Meals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
class SetMealScreen extends StatefulWidget {
  @override
  _SetMealScreenState createState() => _SetMealScreenState();
}

class _SetMealScreenState extends State<SetMealScreen> {
  List<Map<String, dynamic>> _workoutLogs = []; // Replace this with your workout log data
  @override
  void initState() {
    super.initState();
    _fetchMealLogs();
  }
  Future<void> _fetchMealLogs() async {
    _workoutLogs = await DatabaseHelper().getLogs(); // Fetch logs from the database
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Meals'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMealLogs,
        child: ListView.builder(
          itemCount: _workoutLogs.length,
          itemBuilder: (BuildContext context, int index) {
            var log = _workoutLogs[index];
            if (log['type'] != 'meal') {
              // Return an empty container if logTitle is not 'workout'
              return Container();
            }
            String displayTitle =
                log['logTitle'] ?? 'No Title';

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(displayTitle,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            '${log['logDate'] ?? 'No Date'} at ${log['logTime'] ?? 'No Time'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(log['logDescription'] ?? 'No Description',
                            style: const TextStyle(fontSize: 16)),
                        if (log['type'] == 'workout') ...[
                          const SizedBox(height: 15),
                          const Text(
                              "Time",
                              style: TextStyle(fontSize: 14)
                          ),
                          Text('${log['logDuration'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              String routineIdAsString =
                              log['routineId'].toString();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RoutineDetailsScreen(
                                              routineId:
                                              routineIdAsString)));
                            },
                            child: Text('View Routine'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}