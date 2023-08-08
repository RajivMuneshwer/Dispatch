import 'package:dispatch/database/database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminDatabase extends Database {
  @override
  DatabaseReference ref = FirebaseDatabase.instance.ref('muneshwers/admin');

  String getpath<T>() {
    String path = '';
    if (T == Requestee) {
      path = 'requestees';
    } else if (T == Dispatcher) {
      path = 'dispatchers';
    } else if (T == Admin) {
      path = 'admin';
    }
    return path;
  }

  @override
  Future<Iterable<DataSnapshot>> getAll<T>() async {
    String path = getpath<T>();
    return (await ref.child(path).get()).children;
  }

  @override
  Future<Iterable<DataSnapshot>> getOne<T>(int id) async {
    String path = getpath<T>();
    path += "/$id";
    DataSnapshot snapshot = (await ref.child(path).get());
    return [snapshot];
  }
}
