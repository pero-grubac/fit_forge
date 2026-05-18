import 'package:fit_forge/data/local/dao/quote_dao.dart';
import 'package:fit_forge/data/models/quote_model.dart';
import 'package:uuid/uuid.dart';

class QuoteRepository {
  final _dao = QuoteDao();

  Future<List<QuoteModel>> getAll()    => _dao.getAll();
  Future<List<QuoteModel>> getActive() => _dao.getActive();

  Future<QuoteModel> create(String text) async {
    final quote = QuoteModel(
      id:        const Uuid().v4(),
      text:      text,
      isActive:  true,
      createdAt: DateTime.now(),
    );
    await _dao.insert(quote);
    return quote;
  }

  Future<void> toggleActive(String id, bool isActive) =>
      _dao.toggleActive(id, isActive);

  Future<void> delete(String id) => _dao.delete(id);
}