class Routine {
  int? id;
  final String name;
  final String days;
  final String equipment;
  final List<String> workouts;
  final int workoutCount;

  Routine({this.id, required this.name, required this.days, required this.equipment, required this.workouts, required this.workoutCount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'days': days,
      'equipment': equipment,
      'workouts': workouts.join(', '), // Store workouts as a comma-separated string
      'workoutCount': workoutCount,
    };
  }
  // Implement a method to create a Routine object from a Map object
  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      name: map['name'],
      days: map['days'],
      equipment: map['equipment'],
      workouts: map['workouts'].split(', '), // Convert string to list of workouts
      workoutCount: map['workoutCount'] ?? 0, // Assign workout count from the map
    );
  }
}
