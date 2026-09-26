import 'package:fit_forge/core/services/rest_alerts.dart';

/// Records rest alerts instead of showing system notifications.
class FakeRestAlerts implements RestAlerts {
  final scheduled = <DateTime>[];
  int cancels = 0;

  @override
  Future<void> start(DateTime endsAt, RestAlertTexts texts) async =>
      scheduled.add(endsAt);

  @override
  Future<void> cancel() async => cancels++;
}
