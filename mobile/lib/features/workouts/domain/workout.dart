import 'workout_exercise.dart';

/// A workout with a title and one or more exercises.
class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.exercises,
    this.description,
    this.restSeconds = 120,
  });

  final String id;
  final String title;
  final String? description;
  final List<WorkoutExercise> exercises;

  /// Rest duration between sets, in seconds.
  final int restSeconds;

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    restSeconds: (json['rest_seconds'] as int?) ?? 120,
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
    'rest_seconds': restSeconds,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}
