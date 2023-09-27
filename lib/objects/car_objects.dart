import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';

class Car {
  final int id;
  final String licensePlate;
  final String name;
  final Dispatcher dispatcher;
  Car({
    required this.id,
    required this.licensePlate,
    required this.name,
    required this.dispatcher,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "licensePlate": licensePlate,
        "name": name,
        "dispatcher": dispatcher.toMap(),
      };
}

class CarAdaptor {
  Car adaptMap(Map<Object?, Object?> map) {
    if (map
        case {
          "id": int id,
          "licensePlate": String licensePlate,
          "name": String name,
          "dispatcher": Map<Object?, Object?> dispatcherMap,
        }) {
      return Car(
        id: id,
        licensePlate: licensePlate,
        name: name,
        dispatcher: UserAdaptor<Dispatcher>().adaptMap(dispatcherMap),
      );
    }
    throw Exception("car cannot be properly parsed");
  }

  Car adaptSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
    return adaptMap(map);
  }
}
