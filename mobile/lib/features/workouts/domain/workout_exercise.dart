/// An exercise entry within a workout, specifying reps and series.
class WorkoutExercise {
  const WorkoutExercise({
    required this.exerciseId,
    required this.repetitions,
    required this.series,
  });

  final String exerciseId;
  final int repetitions;
  final int series;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      WorkoutExercise(
        exerciseId: json['exercise_id'] as String,
        repetitions: json['repetitions'] as int,
        series: json['series'] as int,
      );

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'repetitions': repetitions,
    'series': series,
  };
}
