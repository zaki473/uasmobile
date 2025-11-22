import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'announcement_channel',
      'Pengumuman',
      channelDescription: 'Notifikasi untuk pengumuman baru',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      title,
      body,
      details,
    );
  }
}
