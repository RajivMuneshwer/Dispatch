import 'package:firebase_database/firebase_database.dart';
import 'package:phone_form_field/phone_form_field.dart';

abstract class SortableObject<T> {
  final T sortBy;
  const SortableObject({
    required this.sortBy,
  });
}

sealed class User extends SortableObject<String> {
  final int id;
  final String name;
  final PhoneNumber? tel;
  const User({
    required this.id,
    required this.name,
    required super.sortBy,
    this.tel,
  });
  Map<String, dynamic> toMap();
}

class Requestee extends User {
  final int? dispatcherid;
  final int? numOfUnreadMessages;
  final int? lastMessageTime;
  Requestee({
    required super.id,
    required super.name,
    required super.sortBy,
    super.tel,
    this.dispatcherid,
    this.numOfUnreadMessages,
    this.lastMessageTime,
  });

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "dispatcherid": dispatcherid,
        "tel": tel?.toJson()
      };
}

class Dispatcher extends User {
  final List<int>? requesteesid;
  final List<int>? driversid;
  final List<int>? carsid;
  Dispatcher({
    required super.id,
    required super.name,
    required super.sortBy,
    super.tel,
    this.requesteesid,
    this.driversid,
    this.carsid,
  });

  @override
  Map<String, dynamic> toMap() {
    var requesteesid_ = requesteesid;
    var driversid_ = driversid;
    var carsid_ = carsid;
    return {
      "id": id,
      "name": name,
      "requesteesid": (requesteesid_ == null)
          ? {}
          : {
              for (final requesteeid in requesteesid_)
                "$requesteeid": requesteeid,
            },
      "tel": tel?.toJson(),
      "driversid": (driversid_ == null)
          ? {}
          : {
              for (final driverid in driversid_) "$driverid": driverid,
            },
      "carsid": (carsid_ == null)
          ? {}
          : {
              for (final carid in carsid_) "$carid": carsid,
            }
    };
  }
}

class Admin extends User {
  Admin({
    required super.id,
    required super.name,
    required super.sortBy,
    super.tel,
  });

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "tel": tel?.toJson(),
      };
}

class Driver extends User {
  final int? dispatcherid;
  final int? numOfUnreadMessages;
  final int? lastMessageTime;
  Driver({
    required super.id,
    required super.name,
    required super.sortBy,
    super.tel,
    this.dispatcherid,
    this.numOfUnreadMessages,
    this.lastMessageTime,
  });

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "dispatcherid": dispatcherid,
        "tel": tel?.toJson(),
      };
}

class BaseUser extends User {
  BaseUser({
    required super.id,
    required super.name,
    required super.sortBy,
    required super.tel,
  });

  @override
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "tel": tel?.toJson(),
      };
}

class UserAdaptor<T extends User> {
  T adaptMap(Map<dynamic, dynamic> map) {
    int id = map['id'] as int;
    String name = map['name'] as String;
    Map<dynamic, dynamic>? telMap = map['tel'] as Map<dynamic, dynamic>?;
    PhoneNumber? tel;
    if (telMap
        case {
          'isoCode': String isoCode,
          'nsn': String nsn,
        }) {
      tel = PhoneNumber.fromJson({
        'isoCode': isoCode,
        'nsn': nsn,
      });
    }
    return switch (T) {
      Requestee => Requestee(
          id: id,
          name: name,
          sortBy: name,
          tel: tel,
          dispatcherid: map['dispatcherid'] as int?,
          numOfUnreadMessages: map['numOfUnreadMessages'] as int?,
          lastMessageTime: map['lastMessageTime'] as int?,
        ) as T,
      Dispatcher => Dispatcher(
          id: id,
          name: name,
          sortBy: name,
          tel: tel,
          requesteesid: () {
            var requesteesidmap = map['requesteesid'];
            if (requesteesidmap == null) {
              return null;
            }
            return (requesteesidmap as Map<Object?, Object?>)
                .values
                .map((e) => e as int)
                .toList();
          }(),
          driversid: () {
            var driversidmap = map['driversid'];
            if (driversidmap == null) {
              return null;
            }
            return (driversidmap as Map<Object?, Object?>)
                .values
                .map((e) => e as int)
                .toList();
          }(),
          carsid: () {
            var carsidMap = map["carsid"];
            if (carsidMap == null) {
              return null;
            }
            return (carsidMap as Map<Object?, Object?>)
                .values
                .map((carid) => carid as int)
                .toList();
          }()) as T,
      Admin => Admin(
          id: id,
          name: name,
          sortBy: name,
          tel: tel,
        ) as T,
      Driver => Driver(
          id: id,
          name: name,
          sortBy: name,
          dispatcherid: map['dispatcherid'] as int?,
          tel: tel,
          numOfUnreadMessages: map['numOfUnreadMessages'] as int?,
          lastMessageTime: map['lastMessageTime'] as int?,
        ) as T,
      _ => BaseUser(
          id: id,
          name: name,
          sortBy: name,
          tel: tel,
        ) as T,
    };
  }

  T adaptSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
    return adaptMap(map);
  }
}
