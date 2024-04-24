import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:next_cloud_plans/main.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:app_settings/app_settings.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flip =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    try {
      await _flip
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings();
      const InitializationSettings settings =
          InitializationSettings(android: androidSettings, iOS: iOSSettings);

      await _flip.initialize(settings);
    } catch (error) {
      if (kDebugMode) {
        print('Error initializing notifications: $error');
      }
    }
  }

  Future<void> showNotificationWithDefaultSound() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'next_vertretung_channel_id',
      'NextVertretung Updates',
      channelDescription: 'Important updates and alerts from NextVertretung.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flip.show(
      const Uuid().v4().hashCode,
      'NextVertretung Update Available',
      'New updates are available for your substitution plan.',
      platformChannelSpecifics,
      payload: 'default_sound',
    );
  }

  Future<void> toggleNotificationStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isNotificationEnabled =
        prefs.getBool('isNotificationEnabled') ?? false;

    if (!isNotificationEnabled) {
      await prefs.setBool('isNotificationEnabled', true);
      await initWorkManager();
    } else {
      if (context.mounted) {
        bool result = await _showDisableNotificationDialog(context);
        if (result) {
          await prefs.setBool('isNotificationEnabled', false);
          await cancelWorkManagerTasks();
        }
      }
    }
  }

  Future<bool> _showDisableNotificationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disable Notifications'),
          content: const Text(
              'Would you like to disable notifications entirely? You can do so in the app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                AppSettings.openAppSettings();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
