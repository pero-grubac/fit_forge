import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Localized texts for the rest notifications (the service has no context).
typedef RestAlertTexts = ({
  String restingTitle,
  String doneTitle,
  String doneBody,
});

/// System notifications for the rest timer, so it is visible and alerts even
/// when the app is in the background or the screen is off.
abstract class RestAlerts {
  /// Shows a live countdown until [endsAt] and schedules an alert for then.
  /// Calling it again replaces the previous timer.
  Future<void> start(DateTime endsAt, RestAlertTexts texts);

  /// Removes the countdown and the scheduled alert.
  Future<void> cancel();
}

final restAlertsProvider =
    Provider<RestAlerts>((ref) => LocalNotificationRestAlerts());

class LocalNotificationRestAlerts implements RestAlerts {
  static const _countdownId = 1001;
  static const _doneId = 1002;

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  Future<void> _init() async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _android?.requestNotificationsPermission();
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> start(DateTime endsAt, RestAlertTexts texts) async {
    try {
      await (_ready ??= _init());
      await cancel();

      final remaining = endsAt.difference(DateTime.now());
      if (remaining <= Duration.zero) return;

      await _plugin.show(
        id: _countdownId,
        title: texts.restingTitle,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'rest_countdown',
            texts.restingTitle,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            silent: true,
            onlyAlertOnce: true,
            showWhen: true,
            when: endsAt.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
            timeoutAfter: remaining.inMilliseconds,
            category: AndroidNotificationCategory.stopwatch,
          ),
        ),
      );

      final exact = await _android?.canScheduleExactNotifications() ?? false;
      await _plugin.zonedSchedule(
        id: _doneId,
        title: texts.doneTitle,
        body: texts.doneBody,
        scheduledDate: tz.TZDateTime.from(endsAt, tz.UTC),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'rest_done',
            texts.doneTitle,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      // Notifications are a nice-to-have; the in-app timer still works.
      debugPrint('Rest notifications unavailable: $e');
    }
  }

  @override
  Future<void> cancel() async {
    if (_ready == null) return;
    try {
      await _plugin.cancel(id: _countdownId);
      await _plugin.cancel(id: _doneId);
    } catch (e) {
      debugPrint('Rest notifications unavailable: $e');
    }
  }
}
