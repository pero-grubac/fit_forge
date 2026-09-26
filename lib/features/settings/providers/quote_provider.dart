import 'dart:math';

import 'package:fit_forge/data/models/quote_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/data/repositories/quote_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuoteNotifier extends AsyncNotifier<List<QuoteModel>> {
  QuoteRepository get _repo => ref.read(quoteRepositoryProvider);

  @override
  Future<List<QuoteModel>> build() => _repo.getAll();

  Future<void> create(String text) async {
    await _repo.create(text);
    ref.invalidateSelf();
    ref.invalidate(activeQuotesProvider);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _repo.toggleActive(id, isActive);
    ref.invalidateSelf();
    ref.invalidate(activeQuotesProvider);
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
    ref.invalidate(activeQuotesProvider);
  }
}

final quoteNotifierProvider =
    AsyncNotifierProvider<QuoteNotifier, List<QuoteModel>>(QuoteNotifier.new);

final activeQuotesProvider = FutureProvider<List<QuoteModel>>((ref) {
  return ref.watch(quoteRepositoryProvider).getActive();
});

/// Number of built-in quotes (`motivation_1` ... `motivation_5` in the ARB
/// files), shown when the user has no active quotes of their own.
const builtInQuoteCount = 5;

/// Source of randomness for the quote rotation; overridable in tests.
final quoteRandomProvider = Provider<Random>((ref) => Random());

/// Position in the quote rotation. The home screen shows quote
/// `state % poolSize`; [next] moves to a different quote.
class QuoteRotation extends Notifier<int> {
  @override
  int build() => ref.read(quoteRandomProvider).nextInt(1 << 16);

  /// Moves to a quote other than the current one (when there is more than
  /// one to choose from).
  Future<void> next() async {
    final custom = await ref.read(activeQuotesProvider.future);
    final poolSize = custom.isEmpty ? builtInQuoteCount : custom.length;
    if (poolSize < 2) return;
    // A step of 1 .. poolSize-1 never lands on the same quote.
    state += 1 + ref.read(quoteRandomProvider).nextInt(poolSize - 1);
  }
}

final quoteRotationProvider =
    NotifierProvider<QuoteRotation, int>(QuoteRotation.new);
