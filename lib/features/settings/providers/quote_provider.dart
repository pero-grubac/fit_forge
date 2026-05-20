import 'package:fit_forge/data/models/quote_model.dart';
import 'package:fit_forge/data/repositories/quote_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuoteNotifier extends AsyncNotifier<List<QuoteModel>> {
  final _repo = QuoteRepository();

  @override
  Future<List<QuoteModel>> build() => _repo.getAll();

  Future<void> create(String text) async {
    await _repo.create(text);
    ref.invalidateSelf();
    ref.invalidate(randomActiveQuoteProvider);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _repo.toggleActive(id, isActive);
    ref.invalidateSelf();
    ref.invalidate(randomActiveQuoteProvider);
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
    ref.invalidate(randomActiveQuoteProvider);
  }
}

final quoteNotifierProvider =
    AsyncNotifierProvider<QuoteNotifier, List<QuoteModel>>(QuoteNotifier.new);

final activeQuotesProvider = FutureProvider<List<QuoteModel>>((ref) {
  return QuoteRepository().getActive();
});

final randomActiveQuoteProvider = FutureProvider<String?>((ref) async {
  final quotes = await QuoteRepository().getActive();
  if (quotes.isEmpty) return null;
  quotes.shuffle();
  return quotes.first.text;
});
