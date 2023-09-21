import 'package:dispatch/firebase_options.dart';
import 'package:dispatch/objects/app_badge.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/screens/app_screen.dart';
import 'package:dispatch/screens/signin_screen.dart';
import 'package:dispatch/utils/initialFirebaseMessaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  await initializeFirebaseMessaging();
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      await signInUserAnonymously();
    } else {
      print("user is signed in");
    }
  });
  final SharedPreferences pref = await SharedPreferences.getInstance();
  //await pref.clear();
  (await AppBadge.getInstance()).initializeBadgeCount();
  final bool? doesUserExist = pref.getBool('exists');
  if (doesUserExist != true) {
    return runApp(const SignInScreen());
  }
  await Settings.initializeFromPref(pref);
  return runApp(const App());
}

Future<void> signInUserAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "operation-not-allowed":
        print("Anonymous auth hasn't been enabled for this project.");
        break;
      default:
        print("Unknown error.");
    }
  }
}
