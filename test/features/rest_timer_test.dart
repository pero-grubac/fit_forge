import 'package:fit_forge/core/services/rest_alerts.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
import 'package:fit_forge/features/workout_log/widgets/rest_timer_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_rest_alerts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const texts = (restingTitle: 'Resting', doneTitle: 'Done', doneBody: 'Go');
  final start = DateTime(2026, 9, 25, 18);
  late DateTime now;
  late FakeRestAlerts alerts;
  late ProviderContainer container;

  RestTimerNotifier timer() => container.read(restTimerProvider.notifier);
  RestTimerState? state() => container.read(restTimerProvider);

  setUp(() {
    now = start;
    alerts = FakeRestAlerts();
    container = ProviderContainer(overrides: [
      clockProvider.overrideWithValue(() => now),
      restAlertsProvider.overrideWithValue(alerts),
    ]);
  });

  tearDown(() => container.dispose());

  test('starts a countdown and schedules the alert', () {
    timer().start(const Duration(seconds: 90), texts);

    expect(state()!.remaining, const Duration(seconds: 90));
    expect(state()!.fraction, 1);
    expect(alerts.scheduled, [start.add(const Duration(seconds: 90))]);
  });

  test('counts down with the clock', () {
    timer().start(const Duration(seconds: 90), texts);
    now = start.add(const Duration(seconds: 30));
    timer().tick();

    expect(state()!.remaining, const Duration(seconds: 60));
    expect(state()!.fraction, closeTo(2 / 3, 0.001));
  });

  test('adding time moves the end and reschedules the alert', () {
    timer().start(const Duration(seconds: 90), texts);
    timer().addTime(const Duration(seconds: 15));

    expect(state()!.remaining, const Duration(seconds: 105));
    expect(alerts.scheduled.last, start.add(const Duration(seconds: 105)));
  });

  test('stops by itself when the rest is over', () {
    timer().start(const Duration(seconds: 90), texts);
    now = start.add(const Duration(seconds: 91));
    timer().tick();

    expect(state(), isNull);
  });

  test('skipping stops the timer and cancels the alert', () {
    timer().start(const Duration(seconds: 90), texts);
    timer().skip();

    expect(state(), isNull);
    expect(alerts.cancels, 1);
  });

  test('a zero duration does nothing', () {
    timer().start(Duration.zero, texts);

    expect(state(), isNull);
    expect(alerts.scheduled, isEmpty);
  });

  test('formats the remaining time as m:ss', () {
    expect(formatDuration(const Duration(seconds: 90)), '1:30');
    expect(formatDuration(const Duration(seconds: 5)), '0:05');
    expect(formatDuration(const Duration(minutes: 3)), '3:00');
  });
}
