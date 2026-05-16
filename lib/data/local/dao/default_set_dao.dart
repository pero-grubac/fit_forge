import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:sqflite/sqflite.dart';


class DefaultSetDao {
  Database get _db => DatabaseHelper.instance.database;

  Future<List<DefaultSetModel>> getDefaultSets(String exerciseId) async {
    final rows = await _db.query(
      DefaultSetModel.tableName,
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'set_number ASC',
    );
    return rows.map(DefaultSetModel.fromMap).toList();
  }
}
