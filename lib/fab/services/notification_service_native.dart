import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

bool _initialised = false;

Future<void> initNative() async {
  if (_initialised) return;

  tz.initializeTimeZones();
  final tzName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(tzName));

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwin  = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const settings = InitializationSettings(android: android, iOS: darwin, macOS: darwin);
  await _plugin.initialize(settings);
  _initialised = true;
}

Future<void> cancelAll() => _plugin.cancelAll();

Future<void> cancelById(int id) => _plugin.cancel(id);

Future<void> scheduleDailyNotification({
  required int id,
  required String title,
  required String body,
  required int hour,
  required int minute,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'fab_reminders',
    'Fabulously Me Reminders',
    channelDescription: 'Daily check-in and sleep reminders',
    importance: Importance.high,
    priority: Priority.high,
  );
  const darwinDetails = DarwinNotificationDetails();
  const details = NotificationDetails(android: androidDetails, iOS: darwinDetails, macOS: darwinDetails);

  final now    = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  await _plugin.zonedSchedule(
    id,
    title,
    body,
    scheduled,
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
