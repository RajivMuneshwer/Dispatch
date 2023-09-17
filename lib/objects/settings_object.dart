import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static int userid = 0;
  static int companyid = 0;
  static String token = "";
  static User user = Requestee(id: 0, name: "", sortBy: "");
  static Color primaryColor = const Color(0xff2D569B);
  static Color onPrimary = Colors.white70;
  static Color secondaryColor = Colors.grey;
  static Color onSecondary = Colors.black87;

  static Future<Settings> initializeFromPref(SharedPreferences prefs) async {
    Map<String, dynamic> storedValues = {
      "token": prefs.getString('token'),
      "role": prefs.getString('role'),
      "userid": prefs.getInt('userid'),
      "companyid": prefs.getInt('companyid'),
    };
    switch (storedValues) {
      case {
          "token": String token,
          "role": String role,
          "userid": int uid,
          "companyid": int cid
        }:
        {
          print(storedValues);
          companyid = cid;
          userid = uid;
          token = token;

          AdminDatabase adminDatabase = AdminDatabase();

          user = switch (role) {
            "admin" => UserAdaptor<Admin>().adaptSnapshot(
                (await (adminDatabase.getOne<Admin>(uid))).first,
              ),
            "dispatcher" => UserAdaptor<Dispatcher>().adaptSnapshot(
                (await (adminDatabase.getOne<Dispatcher>(uid))).first,
              ),
            "requestee" => UserAdaptor<Requestee>().adaptSnapshot(
                (await (adminDatabase.getOne<Requestee>(uid))).first,
              ),
            "driver" => UserAdaptor<Driver>().adaptSnapshot(
                (await (adminDatabase.getOne<Driver>(uid))).first,
              ),
            _ => throw Exception("invalid role"),
          };
          return Settings();
        }
    }
    return throw Exception("Some stored values are null");
  }
}
