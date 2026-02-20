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

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Serialises for API create requests.
  ///
  /// The [id] field is intentionally omitted — it is assigned by the server.
  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}
