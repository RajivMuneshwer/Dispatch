import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dispatch/database/dispatcher_message_info_database.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

part 'msg_info_state.dart';

class MsgInfoCubit extends Cubit<MsgInfoState> {
  final DispatcherMessageInfoDatabase dispatcherMessageInfoDatabase;
  Map<int, User> userMap = {};
  MsgInfoCubit({required this.dispatcherMessageInfoDatabase})
      : super(MsgInfoInitial());

  Future<void> loadDrivers() async {
    await Future.delayed(duration, () async {
      List<Driver> drivers = (await dispatcherMessageInfoDatabase.getDrivers())
          .map((driverSnap) => UserAdaptor<Driver>().adaptSnapshot(driverSnap))
          .toList();

      drivers.sort((d1, d2) {
        var comparitor2 = d2.lastMessageTime ?? d2.id;
        var comparitor1 = d1.lastMessageTime ?? d1.id;
        return comparitor2.compareTo(comparitor1);
      });
      userMap = {for (final driver in drivers) driver.id: driver};

      emit(MsgInfoLoaded(users: drivers));
    });
  }

  Future<void> loadRequestees() async {
    await Future.delayed(duration, () async {
      List<Requestee> requestees =
          (await dispatcherMessageInfoDatabase.getRequestees())
              .map((requesteeSnap) =>
                  UserAdaptor<Requestee>().adaptSnapshot(requesteeSnap))
              .toList();

      requestees.sort((r1, r2) {
        var comparitor2 = r2.lastMessageTime ?? r2.id;
        var comparitor1 = r1.lastMessageTime ?? r1.id;
        return comparitor2.compareTo(comparitor1);
      });

      userMap = {for (final requestee in requestees) requestee.id: requestee};

      emit(MsgInfoLoaded(users: requestees));
    });
  }

  List<StreamSubscription<DatabaseEvent>> requesteeOnChangeSub() {
    var requesteeChangedStream =
        dispatcherMessageInfoDatabase.onRequesteesChanged();
    var requesteeChangedSub = requesteeChangedStream.listen((event) {
      Requestee requestee =
          UserAdaptor<Requestee>().adaptSnapshot(event.snapshot);

      var requestee_ = userMap[requestee.id];
      if (requestee_ == null) {
        userMap.addAll({requestee.id: requestee});
      } else {
        userMap[requestee.id] = requestee;
      }

      var requestees = userMap.values.map((u) => (u as Requestee)).toList();
      requestees.sort((r1, r2) {
        var comparitor2 = r2.lastMessageTime ?? r2.id;
        var comparitor1 = r1.lastMessageTime ?? r1.id;
        return comparitor2.compareTo(comparitor1);
      });

      emit(
        MsgInfoLoaded(users: requestees),
      );
    });
    return [requesteeChangedSub];
  }

  List<StreamSubscription<DatabaseEvent>> driverOnChangedSub() {
    var driverChangedStream = dispatcherMessageInfoDatabase.onDriversChanged();
    var driverChangedSub = driverChangedStream.listen((event) {
      Driver driver = UserAdaptor<Driver>().adaptSnapshot(event.snapshot);

      var driver_ = userMap[driver.id];
      if (driver_ == null) {
        userMap.addAll({driver.id: driver});
      } else {
        userMap[driver.id] = driver;
      }

      var drivers = userMap.values.map((u) => (u as Driver)).toList();
      drivers.sort((d1, d2) {
        var comparitor2 = d2.lastMessageTime ?? d2.id;
        var comparitor1 = d1.lastMessageTime ?? d1.id;
        return comparitor2.compareTo(comparitor1);
      });

      emit(
        MsgInfoLoaded(users: drivers),
      );
    });
    return [driverChangedSub];
  }
}

const duration = Duration(microseconds: 100);
