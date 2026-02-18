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
}
