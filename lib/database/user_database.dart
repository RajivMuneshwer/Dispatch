import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

sealed class AppDatabase {
  ////this database stores the meta data on the users
  ///it is separated via roles : admin, dispatcher, requestee,
  ///
  DatabaseReference get ref;
  Future<Iterable<DataSnapshot>> getAll<T extends User>();
  Future<Iterable<DataSnapshot>> getOne<T extends User>(int id);
  Future<void> create<T extends User>(T user);
  Future<void> update<T extends User>(T user, Map<String, Object?> value);
  Future<void> delete<T extends User>(T user);
}

int getUniqueid() {
  return DateTime.now().millisecondsSinceEpoch;
}

class AdminDatabase extends AppDatabase {
  @override
  DatabaseReference ref = FirebaseDatabase.instance.ref('muneshwers/admin');

  String getpath<T extends User>() {
    return switch (T) {
      Requestee => 'requestees',
      Dispatcher => 'dispatchers',
      Admin => 'admin',
      _ => '',
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

  @override
  Future<void> delete<T extends User>(T user) async {
    String path = getpath<T>();
    path += "/${user.id}";
    switch (user) {
      case Requestee():
        {
          ref.child(path).remove();

          String dispatchRequesteePath = getpath<Dispatcher>();
          dispatchRequesteePath +=
              "/${user.dispatcherid}/requesteesid/${user.id}";

          await ref.child(dispatchRequesteePath).remove();
          return;
        }
      case Dispatcher():
        {
          var requesteesid_ = user.requesteesid;
          if (requesteesid_ == null) {
            await ref.child(path).remove();
            return;
          } else if (requesteesid_.isEmpty) {
            await ref.child(path).remove();
            return;
          }
          throw Exception("Cannot delete dispatcher with requeestes");
        }
      case Admin():
        {
          String adminsPath = getpath<Admin>();
          var adminSnapshots = (await ref.child(adminsPath).get()).children;
          if (adminSnapshots.length > 1) {
            await ref.child(path).remove();
            return;
          }
          throw Exception("Cannot delete the only admin");
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
    return switch (T) {
      Requestee => [await ref.child(path).get()],
      Dispatcher => [],
      Admin => [],
      _ => [],
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

  @override
  Future<void> delete<T extends User>(T user) async {
    switch (user) {
      case Requestee():
        {
          String path = "${user.id}";
          await ref.child(path).remove();
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
    return switch (T) {
      Dispatcher => (await ref.get()).children,
      Requestee => [],
      Admin => [],
      _ => [],
    };
  }

  @override
  Future<Iterable<DataSnapshot>> getOne<T extends User>(int id) async {
    String path = "$id";
    return switch (T) {
      Dispatcher => [await ref.child(path).get()],
      Requestee => [],
      Admin => [],
      _ => [],
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

  @override
  Future<void> delete<T extends User>(T user) async {
    switch (user) {
      case Requestee():
        {
          String requesteepath = "${user.dispatcherid}/requesteesid/${user.id}";
          ref.child(requesteepath).remove();
          return;
        }
      case Dispatcher():
        {
          String dispatcherpath = "${user.id}";
          var requesteesid_ = user.requesteesid;
          if (requesteesid_ == null) {
            ref.child(dispatcherpath).remove();
            return;
          } else if (requesteesid_.isEmpty) {
            ref.child(dispatcherpath).remove();
            return;
          }
          throw Exception("Cannot delete dispatcher with requeestes");
        }
      case Admin():
        {
          return;
        }
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

  @override
  Future<void> delete<T extends User>(T user) async {
    try {
      for (final database in databases) {
        await database.delete<T>(user);
      }
    } catch (e) {
      rethrow;
    }
  }
}

class AlertBox extends StatelessWidget {
  final String errorString;
  const AlertBox({super.key, required this.errorString});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cannot Delete'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(errorString),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}