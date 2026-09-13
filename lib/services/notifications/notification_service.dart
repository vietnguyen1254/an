import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// A single reminder to fire, as computed by [ReminderScheduler].
class PlannedReminder {
  final int id;
  final DateTime when; // local wall-clock time
  final String title;
  final String body;
  final String payload; // 'checkin' | 'meditate'
  const PlannedReminder({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
    required this.payload,
  });
}

/// Thin wrapper over flutter_local_notifications for the two daily reminders.
/// Everything is on-device — no push, no server. Safe to call before/without
/// permission (schedule calls just no-op if the OS denies).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _tzDataLoaded = false;

  /// Route a tapped notification back into the app. Set by main().
  void Function(String payload)? onTap;

  Future<void> init() async {
    // Re-reads the device's current timezone every call, not just the
    // first — the plugin setup below only needs to happen once, but a user
    // who travels while the app stays running/backgrounded (no cold
    // restart) needs `tz.local` refreshed too, or reminders rescheduled
    // after landing (rescheduleReminders() runs on every app resume) keep
    // firing at the old timezone's offset.
    await _refreshLocalTimeZone();
    if (_ready) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: darwin),
        onDidReceiveNotificationResponse: (r) {
          final p = r.payload;
          if (p != null) onTap?.call(p);
        },
      );
      _ready = true;
    } catch (e) {
      debugPrint('NotificationService: init failed: $e');
    }
  }

  Future<void> _refreshLocalTimeZone() async {
    try {
      if (!_tzDataLoaded) {
        tzdata.initializeTimeZones();
        _tzDataLoaded = true;
      }
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      debugPrint('NotificationService: tz refresh failed: $e');
    }
  }

  /// The payload of the notification the app was launched from, if any.
  Future<String?> launchPayload() async {
    try {
      final d = await _plugin.getNotificationAppLaunchDetails();
      if (d?.didNotificationLaunchApp ?? false) {
        return d!.notificationResponse?.payload;
      }
    } catch (_) {}
    return null;
  }

  /// Asks the OS for permission. Returns true if granted (or already on).
  Future<bool> requestPermission() async {
    await init();
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
      }
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
    } catch (e) {
      debugPrint('NotificationService: permission request failed: $e');
    }
    return false;
  }

  static const _channel = AndroidNotificationDetails(
    'an_reminders',
    'Nhắc nhở từ Mây',
    channelDescription: 'Nhắc ghi cảm xúc và thiền mỗi ngày',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  static const _details = NotificationDetails(
    android: _channel,
    iOS: DarwinNotificationDetails(),
  );

  /// Replaces every scheduled reminder with [reminders].
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    await init();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      final now = DateTime.now();
      for (final r in reminders) {
        if (r.when.isBefore(now)) continue;
        await _plugin.zonedSchedule(
          r.id,
          r.title,
          r.body,
          tz.TZDateTime.from(r.when, tz.local),
          _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: r.payload,
        );
      }
    } catch (e) {
      debugPrint('NotificationService: schedule failed: $e');
    }
  }

  Future<void> cancelAll() async {
    await init();
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
