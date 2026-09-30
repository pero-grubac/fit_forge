import 'dart:convert';
import 'dart:io';

import 'package:fit_forge/data/local/database_helper.dart';

/// Thrown when a file is not a valid FitForge backup.
class BackupFormatException implements Exception {
  const BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// Exports the whole database to JSON and restores it again.
///
/// Exercise images are not included (only their paths); on import, paths to
/// files that don't exist on this device are cleared.
class BackupRepository {
  BackupRepository(this._helper);

  final DatabaseHelper _helper;

  static const format = 'fitforge_backup';

  /// Tables in insert order (parents before children).
  static const tables = [
    'workout_plans',
    'exercises',
    'plan_exercises',
    'default_sets',
    'workout_logs',
    'workout_sets',
    'motivational_quotes',
  ];

  Future<String> exportJson() async {
    final db = _helper.database;
    final data = <String, Object?>{
      'format': format,
      'schema_version': DatabaseHelper.version,
      'exported_at': DateTime.now().toIso8601String(),
      'tables': {
        for (final table in tables) table: await db.query(table),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Replaces all data with the backup. Nothing changes if the backup is
  /// invalid.
  Future<void> importJson(String json) async {
    final (version, tablesData) = _parse(json);

    try {
      await _helper.database.transaction((txn) async {
        for (final table in tables.reversed) {
          await txn.delete(table);
        }
        for (final table in tables) {
          for (final row in tablesData[table]!) {
            await txn.insert(table, _fixImagePath(table, row));
          }
        }
        if (version < 4) {
          // v3 backups kept the increment per set; move it to the exercise.
          await DatabaseHelper.fillExerciseIncrements(txn);
        }
        final violations = await txn.rawQuery('PRAGMA foreign_key_check');
        if (violations.isNotEmpty) {
          throw const BackupFormatException('Backup has broken references');
        }
      });
    } on BackupFormatException {
      rethrow;
    } catch (e) {
      // Unknown columns, constraint violations, ... — the transaction has
      // been rolled back.
      throw BackupFormatException('Backup could not be restored: $e');
    }
  }

  /// Oldest backup format that can still be imported (v1.3.0).
  static const oldestSupportedVersion = 3;

  (int, Map<String, List<Map<String, Object?>>>) _parse(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const BackupFormatException('Not a JSON file');
    }
    if (decoded is! Map<String, Object?> || decoded['format'] != format) {
      throw const BackupFormatException('Not a FitForge backup');
    }
    final version = decoded['schema_version'];
    if (version is! int || version > DatabaseHelper.version) {
      throw const BackupFormatException(
          'Backup is from a newer version of the app');
    }
    if (version < oldestSupportedVersion) {
      throw const BackupFormatException(
          'Backup is from an older version of the app');
    }
    final tablesData = decoded['tables'];
    if (tablesData is! Map<String, Object?>) {
      throw const BackupFormatException('Backup has no data');
    }
    return (
      version,
      {
        for (final table in tables)
          table: [
            for (final row in (tablesData[table] as List<Object?>?) ?? const [])
              if (row is Map<String, Object?>)
                row
              else
                throw BackupFormatException('Invalid row in $table'),
          ],
      }
    );
  }

  Map<String, Object?> _fixImagePath(String table, Map<String, Object?> row) {
    final path = row['image_path'];
    if (table != 'exercises' || path is! String) return row;
    return File(path).existsSync() ? row : {...row, 'image_path': null};
  }
}
