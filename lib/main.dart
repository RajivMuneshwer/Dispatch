import 'package:dispatch/firebase_options.dart';
import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/screens/app_screen.dart';
import 'package:dispatch/screens/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  Animate.restartOnHotReload = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "dispatch-muneshwers",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  await _initializeFirebaseMessaging();
  final SharedPreferences pref = await SharedPreferences.getInstance();
  //await pref.clear();
  final bool? doesUserExist = pref.getBool('exists');
  if (doesUserExist != true) {
    return runApp(const SignInScreen());
  }
  await Settings.initializeFromPref(pref);
  return runApp(const App());
}

Future<void> _initializeFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, sound: true);
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

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
          ),
        ),
      );
    }
  });
}
