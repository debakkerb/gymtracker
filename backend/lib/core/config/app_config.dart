import 'dart:io';

/// Runtime configuration loaded from environment variables.
///
/// Set [jwtSecret] via the `JWT_SECRET` env var before starting the server.
/// All other variables have sensible defaults for local development.
class AppConfig {
  const AppConfig({
    required this.port,
    required this.dbPath,
    required this.jwtSecret,
    required this.jwtExpiryHours,
    required this.uploadsDir,
  });

  final int port;
  final String dbPath;
  final String jwtSecret;
  final int jwtExpiryHours;

  /// Directory where uploaded exercise images are stored.
  final String uploadsDir;

  /// Reads config from environment variables, throwing if required values
  /// are absent.
  factory AppConfig.fromEnvironment() {
    final jwtSecret = Platform.environment['JWT_SECRET'];
    if (jwtSecret == null || jwtSecret.isEmpty) {
      throw StateError(
        'JWT_SECRET environment variable is required. '
        'Generate one with: openssl rand -hex 32',
      );
    }

    return AppConfig(
      port: int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080,
      dbPath: Platform.environment['DB_PATH'] ?? 'gymtracker.db',
      jwtSecret: jwtSecret,
      jwtExpiryHours:
          int.tryParse(Platform.environment['JWT_EXPIRY_HOURS'] ?? '') ?? 72,
      uploadsDir: Platform.environment['UPLOADS_DIR'] ?? 'uploads',
    );
  }
}
