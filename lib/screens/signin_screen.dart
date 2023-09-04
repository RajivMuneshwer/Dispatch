import 'package:cloud_functions/cloud_functions.dart';
import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/screens/app_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterLogin(
          title: "Dispatch",
          theme: LoginTheme(
            primaryColor: Colors.blue.shade700,
            accentColor: Colors.blue.shade100,
          ),
          hideForgotPasswordButton: true,
          onLogin: (LoginData loginData) async {
            var fcmToken = await FirebaseMessaging.instance.getToken();
            if (fcmToken == null) {
              return throw Exception("null token");
            }
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: loginData.name,
              password: loginData.password,
            );
            final result = await FirebaseFunctions.instance
                .httpsCallable('loginUser')
                .call(
              {
                "token": fcmToken,
                "id": loginData.password,
              },
            );
            print(result.data);
            String status = result.data["status"] as String;
            Map<dynamic, dynamic> info =
                result.data["info"] as Map<dynamic, dynamic>;
            if (status != "success") {
              return "Login failed. Check with admin";
            }
            int userid = info["userid"] as int;
            int companyid = info["companyid"] as int;
            String role = info["role"] as String;

            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.setBool("exists", true);
            prefs.setInt("userid", userid);
            prefs.setInt("companyid", companyid);
            prefs.setString("role", role);
            prefs.setString("token", fcmToken);

            Settings.initializeFromPref(prefs);

            return null;
          },
          onSubmitAnimationCompleted: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const App(),
              )),
          onRecoverPassword: (p) => null,
        ),
      ),
    );
  }
}

////admin creates the user XX
///this updates the realtime database XX
///and sends an http request (with the companyid, userid, role, and phone number) to the backend
///the backend generates a code -> BMC XX
///the companyid, userid, and role are saved under the firestore database with BMC being the unique id XX
///the backend then generates a twilio message that sends to that phone number the BMC XX
///in the login screen the user enters the BMC and sends it up along with it's generated FMC token and http request XX
///the http request will call a function to check the firestore database 
///if the user with the BMC exists then it will push the token in, 
///collect all the other info (companyid, userid, and role) and send it back to the user waiting to login
///save all of that information locally, update the settings XX
///send the user to the app screen to be delt with XX