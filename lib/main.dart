import 'package:dispatch/firebase_options.dart';
import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/screens/app_screen.dart';
import 'package:dispatch/screens/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  Animate.restartOnHotReload = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "dispatch-muneshwers",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, sound: true);
  final SharedPreferences pref = await SharedPreferences.getInstance();
  //await pref.clear();
  final bool? doesUserExist = pref.getBool('exists');
  if (doesUserExist != true) {
    return runApp(const SignInScreen());
  }
  await Settings.initializeFromPref(pref);
  return runApp(const App());
}
