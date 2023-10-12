import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DriverInfoDatabase {
  final Driver driver;
  DriverInfoDatabase({required this.driver});
  DatabaseReference ref =
      FirebaseDatabase.instance.ref("${Settings.companyid}/driverinfo");

  Future<void> update(Map<String, Map<String, String>> json) async {
    String? firstDriverTimeStr = json["0"]?["time"];
    if (firstDriverTimeStr != null) {
      DateTime firstDriverDate = DateTime.fromMillisecondsSinceEpoch(
        int.parse(firstDriverTimeStr),
      );
      String dateString = DateFormat('dd-MM-yyyy').format(firstDriverDate);
      await ref.child("${driver.id}/$dateString/object").set(json);
      await ref
          .child("${driver.id}/$dateString/lastupdate")
          .set(DateTime.now().millisecondsSinceEpoch);
      return;
    }
    throw Exception("json is invalid");
  }
}
