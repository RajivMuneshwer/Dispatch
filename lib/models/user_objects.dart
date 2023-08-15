import 'package:firebase_database/firebase_database.dart';

abstract class SortableObject<T> {
  final T sortBy;
  const SortableObject({
    required this.sortBy,
  });
}

sealed class User extends SortableObject<String> {
  final int id;
  final String name;
  const User({
    required this.id,
    required this.name,
    required super.sortBy,
  });
  Map<String, dynamic> toMap();
}

class Requestee extends User {
  final int? dispatcherid;
  Requestee({
    required super.id,
    required super.name,
    required super.sortBy,
    this.dispatcherid,
  });

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "dispatcherid": dispatcherid,
      };
}

class Dispatcher extends User {
  final List<int>? requesteesid;
  Dispatcher({
    required super.id,
    required super.name,
    required super.sortBy,
    this.requesteesid,
  });

  @override
  Map<String, dynamic> toMap() {
    var requesteesid_ = requesteesid;
    return {
      "id": id,
      "name": name,
      "requesteesid": (requesteesid_ == null)
          ? {}
          : {
              for (final requesteeid in requesteesid_)
                "$requesteeid": requesteeid,
            },
    };
  }
}

class Admin extends User {
  Admin({
    required super.id,
    required super.name,
    required super.sortBy,
  });

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}

class UserAdaptor<T extends User> {
  T adaptSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> objectMap = snapshot.value as Map<dynamic, dynamic>;
    print(objectMap);
    int id = objectMap['id'] as int;
    String name = objectMap['name'] as String;

    return switch (T) {
      Requestee => Requestee(
          id: id,
          name: name,
          sortBy: name,
          dispatcherid: objectMap['dispatcherid'] as int?,
        ) as T,
      Dispatcher => Dispatcher(
          id: id,
          name: name,
          sortBy: name,
          requesteesid: () {
            var requesteesidmap = objectMap['requesteesid'];
            if (requesteesidmap == null) {
              return null;
            }
            return (requesteesidmap as Map<Object?, Object?>)
                .values
                .map((e) => e as int)
                .toList();
          }(),
        ) as T,
      Admin => Admin(
          id: id,
          name: name,
          sortBy: name,
        ) as T,
      _ => Requestee(
          id: id,
          name: name,
          sortBy: name,
        ) as T,
    };
  }
}
