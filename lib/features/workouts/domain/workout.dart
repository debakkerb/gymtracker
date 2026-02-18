import 'workout_exercise.dart';

/// A workout with a title and one or more exercises.
class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.exercises,
    this.description,
  });

  final String id;
  final String title;
  final String? description;
  final List<WorkoutExercise> exercises;
}
