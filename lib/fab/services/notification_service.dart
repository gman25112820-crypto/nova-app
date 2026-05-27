import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// On native platforms only — conditional import avoids web compile errors.
import 'notification_service_native.dart'
    if (dart.library.html) 'notification_service_stub.dart' as notif_native;

// ─────────────────────────────────────────────────────────────
// NotificationService
//
// Schedules three daily reminders:
//   1. Check-in reminder   (default 19:00)
//   2. Bedtime sleep log   (default 20:30)
//   3. Morning mood check  (default 08:00)
//
// On web: local notifications are not supported. Calls that
// would schedule a notification are silently ignored at runtime;
// callers display a SnackBar instead (see webFallbackMessage).
// ─────────────────────────────────────────────────────────────

class NotificationPrefs {
  final TimeOfDay checkInTime;
  final bool checkInEnabled;
  final TimeOfDay bedtimeTime;
  final bool bedtimeEnabled;
  final TimeOfDay morningTime;
  final bool morningEnabled;

  const NotificationPrefs({
    this.checkInTime   = const TimeOfDay(hour: 19, minute: 0),
    this.checkInEnabled  = true,
    this.bedtimeTime   = const TimeOfDay(hour: 20, minute: 30),
    this.bedtimeEnabled  = true,
    this.morningTime   = const TimeOfDay(hour: 8, minute: 0),
    this.morningEnabled  = true,
  });

  factory NotificationPrefs.fromMap(Map<String, dynamic> m) =>
      NotificationPrefs(
        checkInTime: TimeOfDay(
            hour:   (m['checkInHour']   as num?)?.toInt() ?? 19,
            minute: (m['checkInMinute'] as num?)?.toInt() ?? 0),
        checkInEnabled:  (m['checkInEnabled']  as bool?) ?? true,
        bedtimeTime: TimeOfDay(
            hour:   (m['bedtimeHour']   as num?)?.toInt() ?? 20,
            minute: (m['bedtimeMinute'] as num?)?.toInt() ?? 30),
        bedtimeEnabled:  (m['bedtimeEnabled']  as bool?) ?? true,
        morningTime: TimeOfDay(
            hour:   (m['morningHour']   as num?)?.toInt() ?? 8,
            minute: (m['morningMinute'] as num?)?.toInt() ?? 0),
        morningEnabled:  (m['morningEnabled']  as bool?) ?? true,
      );

  Map<String, dynamic> toMap() => {
        'checkInHour':    checkInTime.hour,
        'checkInMinute':  checkInTime.minute,
        'checkInEnabled': checkInEnabled,
        'bedtimeHour':    bedtimeTime.hour,
        'bedtimeMinute':  bedtimeTime.minute,
        'bedtimeEnabled': bedtimeEnabled,
        'morningHour':    morningTime.hour,
        'morningMinute':  morningTime.minute,
        'morningEnabled': morningEnabled,
      };
}

class NotificationService {
  static const _settingsKey = 'notification_prefs';

  static NotificationPrefs _prefs = const NotificationPrefs();
  static NotificationPrefs get prefs => _prefs;

  // Notification IDs
  static const int _idCheckIn  = 1;
  static const int _idBedtime  = 2;
  static const int _idMorning  = 3;

  /// Call once at app startup (after Hive is open).
  static Future<void> init() async {
    await _loadPrefs();
    if (!kIsWeb) {
      await notif_native.initNative();
    }
  }

  static Future<void> _loadPrefs() async {
    final box = await _openBox();
    final raw = box.get(_settingsKey);
    if (raw != null) {
      _prefs = NotificationPrefs.fromMap(Map<String, dynamic>.from(raw));
    }
  }

  static Future<Box<Map>> _openBox() async {
    if (Hive.isBoxOpen('settings')) return Hive.box<Map>('settings');
    return Hive.openBox<Map>('settings');
  }

  /// Saves prefs and reschedules all notifications.
  /// Returns true on native, false on web (caller should show SnackBar).
  static Future<bool> saveAndReschedule(NotificationPrefs p) async {
    _prefs = p;
    final box = await _openBox();
    await box.put(_settingsKey, p.toMap());
    if (kIsWeb) return false;
    await notif_native.cancelAll();
    await _scheduleAll(p);
    return true;
  }

  /// Cancels all scheduled notifications.
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await notif_native.cancelAll();
  }

  static Future<void> _scheduleAll(NotificationPrefs p) async {
    if (p.checkInEnabled) {
      await notif_native.scheduleDailyNotification(
        id:    _idCheckIn,
        title: '⭐ Time to check in!',
        body:  'How are you feeling today? Open Fabulously Me to log your mood.',
        hour:  p.checkInTime.hour,
        minute: p.checkInTime.minute,
      );
    }
    if (p.bedtimeEnabled) {
      await notif_native.scheduleDailyNotification(
        id:    _idBedtime,
        title: '🌙 Bedtime log',
        body:  'Don\'t forget to log tonight\'s sleep before bed.',
        hour:  p.bedtimeTime.hour,
        minute: p.bedtimeTime.minute,
      );
    }
    if (p.morningEnabled) {
      await notif_native.scheduleDailyNotification(
        id:    _idMorning,
        title: '🌅 Good morning!',
        body:  'Start the day with a quick mood check-in.',
        hour:  p.morningTime.hour,
        minute: p.morningTime.minute,
      );
    }
  }

  /// Human-readable label for a TimeOfDay.
  static String fmtTime(TimeOfDay t) {
    final h      = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final m      = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  static const String webFallbackMessage =
      'Push notifications aren\'t supported in the browser. '
      'Your preferences are saved — install the app for real reminders.';
}
