import 'package:sqlite3/sqlite3.dart';

/// Wraps the SQLite connection and runs schema migrations on startup.
///
/// Uses simple `CREATE TABLE IF NOT EXISTS` migrations. For future
/// versioned migrations, replace the [migrate] body with a migration runner
/// that tracks schema version in a `schema_version` table.
class AppDatabase {
  AppDatabase(String path) : _db = sqlite3.open(path) {
    // Enforce FK constraints for every connection.
    _db.execute('PRAGMA foreign_keys = ON');
    // WAL mode gives better read/write concurrency.
    _db.execute('PRAGMA journal_mode = WAL');
  }

  final Database _db;

  /// Direct access to the underlying SQLite database for repositories.
  Database get db => _db;

  /// Creates all tables if they do not already exist.
  void migrate() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id            TEXT PRIMARY KEY,
        email         TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        date_of_birth TEXT,
        created_at    TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS exercises (
        id            TEXT PRIMARY KEY,
        user_id       TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title         TEXT NOT NULL,
        description   TEXT,
        external_link TEXT,
        image_url     TEXT,
        created_at    TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS workouts (
        id          TEXT PRIMARY KEY,
        user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title       TEXT NOT NULL,
        description TEXT,
        created_at  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
      )
    ''');

    // workout_exercises is an ordered join table (sort_order preserves list
    // position since SQL tables have no inherent order).
    _db.execute('''
      CREATE TABLE IF NOT EXISTS workout_exercises (
        workout_id  TEXT    NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
        exercise_id TEXT    NOT NULL REFERENCES exercises(id),
        repetitions INTEGER NOT NULL,
        series      INTEGER NOT NULL,
        sort_order  INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (workout_id, exercise_id)
      )
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id            TEXT PRIMARY KEY,
        user_id       TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        workout_title TEXT NOT NULL,
        date          TEXT NOT NULL,
        created_at    TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ', 'now'))
      )
    ''');

    // session_exercises stores a denormalised snapshot: exercise names are
    // copied at save time so history is stable even if exercises are renamed.
    _db.execute('''
      CREATE TABLE IF NOT EXISTS session_exercises (
        id            TEXT    PRIMARY KEY,
        session_id    TEXT    NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
        exercise_name TEXT    NOT NULL,
        repetitions   INTEGER NOT NULL,
        series        INTEGER NOT NULL,
        sort_order    INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  void close() => _db.dispose();
}
