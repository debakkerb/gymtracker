import 'dart:io';

import 'package:gymtracker_backend/core/config/app_config.dart';
import 'package:gymtracker_backend/core/database/database.dart';
import 'package:gymtracker_backend/router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main() async {
  final config = AppConfig.fromEnvironment();

  // Ensure the uploads directory exists before accepting requests.
  await Directory(config.uploadsDir).create(recursive: true);

  final db = AppDatabase(config.dbPath);
  db.migrate();

  final handler = buildRouter(config, db);
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    config.port,
  );

  print('GymTracker backend listening on http://0.0.0.0:${server.port}');

  // Graceful shutdown on SIGTERM (sent by Docker / orchestrators).
  ProcessSignal.sigterm.watch().listen((_) async {
    print('SIGTERM received — shutting down...');
    await server.close(force: false);
    db.close();
    exit(0);
  });
}
