import 'package:firebase_database/firebase_database.dart';

abstract class SortableObject<T> {
  final T sortBy;
  const SortableObject({
    required this.sortBy,
  });
}

abstract class User extends SortableObject<String> {
  final int id;
  final String name;
  const User({
    required this.id,
    required this.name,
    required super.sortBy,
  });
}

class Requestee extends User {
  final int? dispatcherid;
  Requestee({
    required super.id,
    required super.name,
    required super.sortBy,
    this.dispatcherid,
  });
}

class Dispatcher extends User {
  final List<int>? requesteesid;
  Dispatcher({
    required super.id,
    required super.name,
    required super.sortBy,
    this.requesteesid,
  });
}

class Admin extends User {
  Admin({
    required super.id,
    required super.name,
    required super.sortBy,
  });
}

class UserAdaptor<T extends User> {
  T adaptSnapshot(DataSnapshot snapshot) {
    print(snapshot.value);
    Map<dynamic, dynamic> objectMap = snapshot.value as Map<dynamic, dynamic>;
    int id = objectMap['id'] as int;
    String name = objectMap['name'] as String;

    if (T == Requestee) {
      return Requestee(
        id: id,
        name: name,
        sortBy: name,
        dispatcherid: objectMap['dispatcherid'] as int?,
      ) as T;
    } else if (T == Dispatcher) {
      return Dispatcher(
        id: id,
        name: name,
        requesteesid: (objectMap['requesteesid'] as List<Object?>)
            .map((e) => e as int)
            .toList(),
        sortBy: name,
      ) as T;
    } else if (T == Admin) {
      return Admin(
        id: id,
        name: name,
        sortBy: name,
      ) as T;
    } else {
      return Requestee(
        id: id,
        name: name,
        sortBy: name,
        dispatcherid: objectMap['dispatcherid'] as int?,
      ) as T;
    }
  }
}
