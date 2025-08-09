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
    WidgetsFlutterBinding.ensureInitialized();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // Inicijaliziraj timezone
    tz.initializeTimeZones();
    
    // Android postavke
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS postavke
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );
  }

  Future<bool> _checkPermissions() async {
    try {
      if (await Permission.notification.isRestricted) {
        return false;
      }
      
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Permission check error: $e');
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

      final dayBefore = reservationTime.subtract(const Duration(days: 1));
      final hourBefore = reservationTime.subtract(const Duration(hours: 1));

      if (dayBefore.isAfter(DateTime.now())) {
        await _scheduleSingleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: dayBefore,
        );
      }

      if (hourBefore.isAfter(DateTime.now())) {
        await _scheduleSingleNotification(
          id: id + 1,
          title: title,
          body: "Today you have a reservation at ${formatTime(reservationTime)}",
          scheduledDate: hourBefore,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
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
      largeIcon: null, // Eksplicitno postavite null za largeIcon
    );

    const iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  } catch (e) {
    debugPrint('Error scheduling single notification: $e');
    rethrow;
  }
}
}