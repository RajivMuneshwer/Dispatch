import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dispatch/database/car_database.dart';
import 'package:dispatch/database/driver_info_database.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/objects/car_objects.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'driver_info_state.dart';

class DriverInfoCubit extends Cubit<DriverInfoState> {
  DriverInfoCubit({
    required this.driver,
  }) : super(DriverInfoInitial());
  final Driver driver;
  AdminDatabase adminDatabase = AdminDatabase();
  CarDatabase carDatabase = CarDatabase();

  Future<void> initialize() async {
    Future.delayed(duration, () async {
      Map<String, Map<String, String>> json = await _getInfoJson();
      Dispatcher dispatcher = await _getDispatcher(driver);
      List<Requestee> requestees = await _getRequestees(dispatcher);
      List<Car> cars = await _getCars(dispatcher);
      List<String> carNames = cars.map((c) => c.name).toList();
      List<String> requesteesNames = requestees.map((r) => r.name).toList();
      requesteesNames.add("Errand");
      emit(DriverInfoWithData(
        pickups: requesteesNames,
        cars: carNames,
        json: json,
      ));
    });
  }

  Future<Map<String, Map<String, String>>> _getInfoJson() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var tempJsonString = preferences.getString("driverJson");
    if (tempJsonString != null) {
      Map<String, dynamic> tempJson = jsonDecode(tempJsonString);
      Map<String, Map<String, String>> tempJsonMap =
          _convertJsonToMap(tempJson);
      var currDay = DateTime.now().day;
      var timeInMilli = int.tryParse(tempJsonMap["0"]?["time"] ?? "");
      if (timeInMilli == null) {
        throw Exception("Json did not same time correctly");
      }
      var jsonDay = DateTime.fromMillisecondsSinceEpoch(timeInMilli).day;

      if (currDay == jsonDay) return tempJsonMap;
      await preferences.remove("driverJson");
      return {};
    }
    return {};
  }

  Future<Dispatcher> _getDispatcher(Driver driver) async {
    var dispatcherid = driver.dispatcherid;
    if (dispatcherid == null) {
      throw Exception("Dispatcher is null. Cannot continue");
    }
    Dispatcher dispatcher = UserAdaptor<Dispatcher>().adaptSnapshot(
      (await adminDatabase.getOne<Dispatcher>(dispatcherid)).first,
    );
    return dispatcher;
  }

  Future<List<Requestee>> _getRequestees(Dispatcher dispatcher) async {
    print("pickup");
    var requesteesids = dispatcher.requesteesid;
    if (requesteesids == null) return [];
    List<Iterable<DataSnapshot>> snapshots = await Future.wait(requesteesids
        .map((requesteeid) => adminDatabase.getOne<Requestee>(requesteeid)));
    UserAdaptor<Requestee> userAdaptor = UserAdaptor<Requestee>();
    List<Requestee> requestees = snapshots
        .map((snapshotI) => userAdaptor.adaptSnapshot(snapshotI.first))
        .toList();
    return requestees;
  }

  Future<List<Car>> _getCars(Dispatcher dispatcher) async {
    print("cars");
    var carsids = dispatcher.carsid;
    if (carsids == null) return [];
    List<DataSnapshot> snapshots =
        await Future.wait(carsids.map((carid) => carDatabase.getOne(carid)));
    CarAdaptor carAdaptor = CarAdaptor();
    List<Car> carsTemp = snapshots
        .map((snapshot) => carAdaptor.adaptSnapshot(snapshot))
        .toList();
    return carsTemp;
  }

  void updateValue({
    required int index,
    required String value,
    required String key,
  }) {
    var state_ = state;
    if (state_ is! DriverInfoWithData) return;
    var json_ = state_.json;
    json_[index.toString()]?[key] = value;
    emit(
      DriverInfoWithData(
        pickups: state_.pickups,
        cars: state_.cars,
        json: json_,
      ),
    );
    _handleSideEffects(json_);
  }

  void updateJson({
    required Map<String, Map<String, String>> json,
  }) {
    var state_ = state;
    if (state_ is! DriverInfoWithData) return;
    emit(DriverInfoWithData(
      pickups: state_.pickups,
      cars: state_.cars,
      json: json,
    ));
    _handleSideEffects(json);
  }

  Future<void> _handleSideEffects(Map<String, Map<String, String>> json) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DriverInfoDatabase driverInfoDatabase = DriverInfoDatabase(driver: driver);
    await Future.wait([
      prefs.setString("driverJson", jsonEncode(json)),
      driverInfoDatabase.update(json),
      driverInfoDatabase.ref.keepSynced(true),
    ]);
  }

  Map<String, Map<String, String>> _convertJsonToMap(
      Map<String, dynamic> tempJson) {
    int jsonLength = tempJson.length;
    if (jsonLength <= 0) {
      throw Exception("improper length of json saved");
    }
    print(tempJson);
    return tempJson.map<String, Map<String, String>>((key, value) {
      if (value
          case {
            "time": String time,
            "driver": String driverName,
            "pickup": String pickup,
            "purpose": String purpose,
            "vehicle": String vehicle,
            "odometer": String odometer,
          }) {
        return MapEntry(key, {
          "time": time,
          "driver": driverName,
          "pickup": pickup,
          "purpose": purpose,
          "vehicle": vehicle,
          "odometer": odometer,
        });
      } else {
        throw Exception(
          "improper parsing for json temp. Values not correctly stored",
        );
      }
    });
  }
}

const duration = Duration(microseconds: 100);

Map<String, String> Function(String) emptyMap = (String driverName) => {
      "time": DateTime.now().millisecondsSinceEpoch.toString(),
      "driver": driverName,
      "vehicle": "",
      "pickup": "",
      "purpose": "",
      "odometer": "",
    };
