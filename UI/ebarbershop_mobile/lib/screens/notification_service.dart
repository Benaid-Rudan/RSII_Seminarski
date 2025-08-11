import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  Future<void> init() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Init timezone
    tz.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped: ${response.payload}");
      },
    );

    // Kreiraj Android kanal
    await _createAndroidNotificationChannel();
  }

  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'reservation_channel_id',
      'Reservation Reminders',
      description: 'Channel for reservation reminders',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> _checkPermissions() async {
    try {
      if (await Permission.notification.isRestricted) return false;

      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint("Permission check error: $e");
      return false;
    }
  }

  Future<void> scheduleReservationReminder({
  required int id,
  required String title,
  required String body,
  required DateTime reservationTime,
}) async {
  try {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      debugPrint('Notification permissions not granted');
      return;
    }

    final now = DateTime.now();
    final timeUntilReservation = reservationTime.difference(now);

    // Ako je rezervacija za manje od 1h ili sljedeći dan, pošalji odmah notifikaciju
    if (timeUntilReservation <= const Duration(hours: 1) || 
        reservationTime.day > now.day) {
      await _showImmediateNotification(
        id: id,
        title: title,
        body: "Imate rezervaciju za ${formatTime(reservationTime)}",
      );
    }

    // Zakazi obavijest dan prije ako je rezervacija za sutra ili kasnije
    final dayBefore = reservationTime.subtract(const Duration(days: 1));
    if (dayBefore.isAfter(now)) {
      await _scheduleSingleNotification(
        id: id + 1,
        title: title,
        body: "Sutra imate rezervaciju u ${formatTime(reservationTime)}",
        scheduledDate: dayBefore,
      );
    }

    // Zakazi obavijest sat prije ako je rezervacija za više od sata
    final hourBefore = reservationTime.subtract(const Duration(hours: 1));
    if (hourBefore.isAfter(now) && timeUntilReservation > const Duration(hours: 1)) {
      await _scheduleSingleNotification(
        id: id + 2,
        title: title,
        body: "Za sat vremena imate rezervaciju u ${formatTime(reservationTime)}",
        scheduledDate: hourBefore,
      );
    }
  } catch (e) {
    debugPrint("Error scheduling notifications: $e");
  }
}

Future<void> _showImmediateNotification({
  required int id,
  required String title,
  required String body,
}) async {
  try {
    final androidDetails = AndroidNotificationDetails(
      'reservation_channel_id',
      'Reservation Reminders',
      channelDescription: 'Channel for reservation reminders',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );

    debugPrint("✅ Immediate notification shown");
  } catch (e) {
    debugPrint("Error showing immediate notification: $e");
  }
}

  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'reservation_channel_id',
        'Reservation Reminders',
        channelDescription: 'Channel for reservation reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails();

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("✅ Notification scheduled for $scheduledDate");
    } catch (e) {
      debugPrint("Error scheduling single notification: $e");
    }
  }
}
