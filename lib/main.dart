import 'package:dispatch/firebase_options.dart';
import 'package:dispatch/screens/app_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  Animate.restartOnHotReload = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: "dispatch-muneshwers",
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const App(),
  );
}
