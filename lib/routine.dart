class Routine {
  int? id;
  final String name;
  final String days;
  final String equipment;
  final List<String> workouts;

  Routine({this.id, required this.name, required this.days, required this.equipment, required this.workouts});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'days': days,
      'equipment': equipment,
      'workouts': workouts.join(', '), // Store workouts as a comma-separated string
    };
  }

// Implement a method to create a Routine object from a Map object
}
