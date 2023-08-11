import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';

sealed class AppDatabase {
  ////this database stores the meta data on the users
  ///it is separated via roles : admin, dispatcher, requestee,
  ///
  DatabaseReference get ref;
  Future<Iterable<DataSnapshot>> getAll<T extends User>();
  Future<Iterable<DataSnapshot>> getOne<T extends User>(int id);
  Future<void> create<T extends User>(T user);
  Future<void> update<T extends User>(T user, Map<String, Object?> value);
}

int getUniqueid() {
  return DateTime.now().millisecondsSinceEpoch;
}

class AdminDatabase extends AppDatabase {
  @override
  DatabaseReference ref = FirebaseDatabase.instance.ref('muneshwers/admin');

  String getpath<T>() {
    return switch (T as User) {
      Requestee() => 'requestees',
      Dispatcher() => 'dispatcher',
      Admin() => 'admin',
    };
  }

  @override
  Future<Iterable<DataSnapshot>> getAll<T extends User>() async {
    String path = getpath<T>();
    return (await ref.child(path).get()).children;
  }

  @override
  Future<Iterable<DataSnapshot>> getOne<T extends User>(int id) async {
    String path = getpath<T>();
    path += "/$id";
    DataSnapshot snapshot = (await ref.child(path).get());
    return [snapshot];
  }

  @override
  Future<void> create<T extends User>(T user) async {
    String path = getpath<T>();
    path += "/${user.id}";
    await ref.child(path).set(user.toMap());
    switch (user) {
      case Requestee():
        {
          String dispatchPath = getpath<Dispatcher>();
          dispatchPath += "/${user.dispatcherid}/requesteesid/${user.id}";
          await ref.child(dispatchPath).set(user.id);
          return;
        }
      case Dispatcher():
        {
          return;
        }
      case Admin():
        {
          return;
        }
    }
  }

  @override
  Future<void> update<T extends User>(
      T user, Map<String, Object?> value) async {
    String path = getpath<T>();
    path += "/${user.id}";
    await ref.child(path).update(value);

    switch (user) {
      case Requestee():
        {
          if (user.dispatcherid == value["dispatcherid"]) {
            return;
          }
          String dispatchpath = getpath<Dispatcher>();
          String newdispatchpath =
              "$dispatchpath/${value["dispatcherid"]}/requesteesid/${user.id}";
          String olddispatchpath =
              "$dispatchpath/${user.dispatcherid}/requesteesid/${user.id}";

          await ref.child(newdispatchpath).set(user.id);
          await ref.child(olddispatchpath).remove();
        }
      case Dispatcher():
        {
          return;
        }
      case Admin():
        {
          return;
        }
    }
  }
}

class RequesteeDatabase extends AppDatabase {
  @override
  DatabaseReference get ref =>
      FirebaseDatabase.instance.ref('muneshwers/requestees');

  @override
  Future<Iterable<DataSnapshot>> getAll<T extends User>() {
    // should not be called on this database
    throw UnimplementedError();
  }

  @override
  Future<Iterable<DataSnapshot>> getOne<T extends User>(int id) async {
    String path = '$id';
    return switch (T as User) {
      Requestee() => [await ref.child(path).get()],
      Dispatcher() => [],
      Admin() => []
    };
  }

  @override
  Future<void> create<T extends User>(T user) async {
    String path = '${user.id}';
    switch (user) {
      case Requestee():
        {
          await ref.child(path).set(user.toMap());
          return;
        }
      case Dispatcher():
        {
          return;
        }
      case Admin():
        {
          return;
        }
    }
  }

  @override
  Future<void> update<T extends User>(
      T user, Map<String, Object?> value) async {
    String path = '${user.id}';
    switch (user) {
      case Requestee():
        {
          await ref.child(path).update(value);
          return;
        }
      case Dispatcher():
        {
          return;
        }
      case Admin():
        {
          return;
        }
    }
  }
}

class DispatcherDatabase extends AppDatabase {
  @override
  DatabaseReference get ref =>
      FirebaseDatabase.instance.ref('muneshwers/dispatchers');

  @override
  Future<Iterable<DataSnapshot>> getAll<T extends User>() async {
    return switch (T as User) {
      Dispatcher() => (await ref.get()).children,
      Requestee() => [],
      Admin() => [],
    };
  }

  @override
  Future<Iterable<DataSnapshot>> getOne<T extends User>(int id) async {
    String path = "$id";
    return switch (T as User) {
      Dispatcher() => [await ref.child(path).get()],
      Requestee() => [],
      Admin() => [],
    };
  }

  @override
  Future<void> create<T extends User>(T user) async {
    switch (user) {
      case Requestee():
        {
          String path = "${user.dispatcherid}/requesteesid/${user.id}";
          ref.child(path).set({"id": user.id});
          return;
        }
      case Dispatcher():
        {
          String path = "${user.id}";
          ref.child(path).set({"id": user.id});
          return;
        }
      case Admin():
        {
          return;
        }
    }
  }

  @override
  Future<void> update<T extends User>(
      T user, Map<String, Object?> value) async {
    switch (user) {
      case Requestee():
        {
          if (user.dispatcherid == value['dispatcherid']) {
            return;
          }
          String prevdispatchpath =
              "${user.dispatcherid}/requesteesid/${user.id}";
          await ref.child(prevdispatchpath).remove();
          String newdispatchpath =
              "${value['dispatcherid']}/requesteesid/${user.id}";
          await ref.child(newdispatchpath).set({"id": user.id});
        }
      case Dispatcher():
        {}
      case Admin():
        {}
    }
  }
}

class AllDatabase extends AppDatabase {
  List<AppDatabase> get databases => [
        AdminDatabase(),
        DispatcherDatabase(),
        RequesteeDatabase(),
      ];

  @override
  Future<Iterable<DataSnapshot>> getAll<T extends User>() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<Iterable<DataSnapshot>> getOne<T extends User>(int id) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  DatabaseReference get ref => FirebaseDatabase.instance.ref('muneshwers');

  @override
  Future<void> create<T extends User>(T user) async {
    for (final database in databases) {
      await database.create<T>(user);
    }
  }

  @override
  Future<void> update<T extends User>(
      T user, Map<String, Object?> value) async {
    for (final database in databases) {
      await database.update<T>(user, value);
    }
  }
}
