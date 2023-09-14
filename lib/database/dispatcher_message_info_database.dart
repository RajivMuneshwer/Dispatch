import 'package:dispatch/models/settings_object.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';

class DispatcherMessageInfoDatabase {
  final Dispatcher dispatcher;
  DispatcherMessageInfoDatabase({
    required this.dispatcher,
  });
  DatabaseReference get ref => FirebaseDatabase.instance
      .ref("${Settings.companyid.toString()}/dispatchers/${dispatcher.id}");

  Stream<DatabaseEvent> onDriversChanged() {
    return ref.child("driversid").onChildChanged;
  }

  Stream<DatabaseEvent> onRequesteesChanged() {
    return ref.child("requesteesid").onChildChanged;
  }

  Future<Iterable<DataSnapshot>> getRequestees() async {
    var snapshots = (await ref.child("requesteesid").get()).children;
    return snapshots;
  }

  Future<Iterable<DataSnapshot>> getDrivers() async {
    var snapshots = (await ref.child("driversid").get()).children;
    return snapshots;
  }
}
