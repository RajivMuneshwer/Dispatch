import 'package:dispatch/objects/app_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  final appBadge = await AppBadge.getInstance();
  //increase badge counter in background
  await appBadge.increaseBadgeCountBy(1);
}

Future<void> initializeFirebaseMessaging() async {
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  //foreground messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    sound: true,
    announcement: true,
    badge: true,
  );
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel)
      .catchError((err) => print("error: $err"));

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final pref = await SharedPreferences.getInstance();
    await pref.reload();
    //increase badge counter in foreground
    final appbadge = AppBadge(prefs: pref);
    await appBadgeQueue.add<void>(() => appbadge.increaseBadgeCountBy(1));

    final notification = message.notification;
    final androidNotification = message.notification?.android;
    if (notification != null && androidNotification != null) {
      FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: "app_icon",
              priority: Priority.max,
              importance: Importance.max,
              enableVibration: true,
              channelShowBadge: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            )),
      );
    }
  });
}
