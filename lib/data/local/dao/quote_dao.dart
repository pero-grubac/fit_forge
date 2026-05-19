import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/quote_model.dart';
import 'package:sqflite/sqflite.dart';

class QuoteDao {
  Database get _db => DatabaseHelper.instance.database;

  Future<List<QuoteModel>> getAll() async {
    final rows = await _db.query(
      QuoteModel.tableName,
      orderBy: 'created_at DESC',
    );
    return rows.map(QuoteModel.fromMap).toList();
  }

  Future<List<QuoteModel>> getActive() async {
    final rows = await _db.query(
      QuoteModel.tableName,
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
    return rows.map(QuoteModel.fromMap).toList();
  }

  Future<void> insert(QuoteModel quote) async {
    await _db.insert(
      QuoteModel.tableName,
      quote.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _db.update(
      QuoteModel.tableName,
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(
      QuoteModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
