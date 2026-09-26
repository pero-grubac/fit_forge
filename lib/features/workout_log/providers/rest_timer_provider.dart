import 'dart:async';

import 'package:fit_forge/core/services/rest_alerts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current time; overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class RestTimerState {
  const RestTimerState({
    required this.endsAt,
    required this.total,
    required this.remaining,
  });

  final DateTime endsAt;
  final Duration total;
  final Duration remaining;

  /// 1.0 at the start, 0.0 when the rest is over.
  double get fraction => total.inMilliseconds == 0
      ? 0
      : remaining.inMilliseconds / total.inMilliseconds;
}

/// Rest countdown between sets. Null when no rest is running. It keeps
/// running when the log page is closed; system notifications cover the time
/// the app is in the background.
class RestTimerNotifier extends Notifier<RestTimerState?> {
  static const _tick = Duration(seconds: 1);

  Timer? _ticker;
  RestAlertTexts? _texts;

  DateTime _now() => ref.read(clockProvider)();

  RestAlerts get _alerts => ref.read(restAlertsProvider);

  @override
  RestTimerState? build() {
    ref.onDispose(() => _ticker?.cancel());
    return null;
  }

  void start(Duration duration, RestAlertTexts texts) {
    if (duration <= Duration.zero) return;
    _texts = texts;
    final endsAt = _now().add(duration);
    state =
        RestTimerState(endsAt: endsAt, total: duration, remaining: duration);
    _ticker?.cancel();
    _ticker = Timer.periodic(_tick, (_) => tick());
    _alerts.start(endsAt, texts);
  }

  void addTime(Duration extra) {
    final current = state;
    if (current == null) return;
    final endsAt = current.endsAt.add(extra);
    state = RestTimerState(
      endsAt: endsAt,
      total: current.total + extra,
      remaining: _remaining(endsAt),
    );
    _alerts.start(endsAt, _texts!);
  }

  void skip() {
    _stop();
    _alerts.cancel();
  }

  /// Updates the countdown; called every second.
  void tick() {
    final current = state;
    if (current == null) return;
    final remaining = _remaining(current.endsAt);
    if (remaining == Duration.zero) {
      // The scheduled notification alerts too; it is left to fire.
      _stop();
      HapticFeedback.heavyImpact();
      return;
    }
    state = RestTimerState(
      endsAt: current.endsAt,
      total: current.total,
      remaining: remaining,
    );
  }

  Duration _remaining(DateTime endsAt) {
    final left = endsAt.difference(_now());
    if (left <= Duration.zero) return Duration.zero;
    // Round up so the display shows 1:30 right after starting a 90 s rest.
    return Duration(seconds: (left.inMilliseconds / 1000).ceil());
  }

  void _stop() {
    _ticker?.cancel();
    _ticker = null;
    state = null;
  }
}

final restTimerProvider =
    NotifierProvider<RestTimerNotifier, RestTimerState?>(RestTimerNotifier.new);
