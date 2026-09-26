import 'dart:math';

import 'package:fit_forge/data/models/quote_model.dart';
import 'package:fit_forge/features/settings/providers/quote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

QuoteModel _quote(String text) => QuoteModel(
      id: text,
      text: text,
      isActive: true,
      createdAt: DateTime(2026, 9, 26),
    );

void main() {
  ProviderContainer containerWith(List<QuoteModel> custom, {int seed = 1}) {
    final container = ProviderContainer(overrides: [
      activeQuotesProvider.overrideWith((ref) async => custom),
      quoteRandomProvider.overrideWithValue(Random(seed)),
    ]);
    addTearDown(container.dispose);
    return container;
  }

  test('built-in quotes: every rotation shows a different quote', () async {
    for (var seed = 0; seed < 20; seed++) {
      final container = containerWith(const [], seed: seed);
      var shown = container.read(quoteRotationProvider) % builtInQuoteCount;
      for (var i = 0; i < 30; i++) {
        await container.read(quoteRotationProvider.notifier).next();
        final now = container.read(quoteRotationProvider) % builtInQuoteCount;
        expect(now, isNot(shown));
        shown = now;
      }
    }
  });

  test('own quotes: rotates within the user\'s quotes', () async {
    final container = containerWith([_quote('a'), _quote('b')]);
    final before = container.read(quoteRotationProvider) % 2;
    await container.read(quoteRotationProvider.notifier).next();
    expect(container.read(quoteRotationProvider) % 2, isNot(before));
  });

  test('a single quote stays', () async {
    final container = containerWith([_quote('only')]);
    final before = container.read(quoteRotationProvider);
    await container.read(quoteRotationProvider.notifier).next();
    expect(container.read(quoteRotationProvider), before);
  });
}
