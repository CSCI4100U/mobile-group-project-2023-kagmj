class Exercise {
  String title;
  String type;
  String gear;
  String schedule;
  String sets;
  String reps;
  String weight;

  Exercise({
    required this.title,
    required this.type,
    required this.gear,
    required this.schedule,
    required this.sets,
    required this.reps,
    required this.weight,
  });

  factory Exercise.fromMap(Map map){
    return Exercise(
      title: map['title'],
      type: map['type'],
      gear: map['gear'],
      schedule: map['schedule'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
    );
  }

  String toString(){
    return 'Exercise($title,$type,$gear,$schedule,$sets,$reps,$weight)';
  }

}