import 'dart:convert';
import 'package:dispatch/database/car_database.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/objects/car_objects.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:dispatch/screens/car_screens.dart';
import 'package:dispatch/screens/user_screens.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverFormScreen extends StatefulWidget {
  final Driver driver;
  const DriverFormScreen({
    super.key,
    required this.driver,
  });

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  Map<String, Map<String, String>> infoJson = {};
  List<Requestee> pickups = [];
  List<Car> cars = [];
  AdminDatabase adminDatabase = AdminDatabase();
  CarDatabase carDatabase = CarDatabase();

  Future<Map<String, Map<String, String>>> getInfoJson() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var tempJsonString = preferences.getString("driverJson");
    if (tempJsonString == null) {
      return {
        "0": emptyMap(
          widget.driver.name,
          DateTime.now().millisecondsSinceEpoch.toString(),
        )
      };
    }
    return jsonDecode(tempJsonString);
  }

  Future<Dispatcher> getDispatcher(Driver driver) async {
    var dispatcherid = driver.dispatcherid;
    if (dispatcherid == null) {
      throw Exception("Dispatcher is null. Cannot continue");
    }
    Dispatcher dispatcher = UserAdaptor<Dispatcher>().adaptSnapshot(
      (await adminDatabase.getOne<Dispatcher>(dispatcherid)).first,
    );
    return dispatcher;
  }

  Future<List<Requestee>> getRequestees(Dispatcher dispatcher) async {
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

  Future<List<Car>> getCars(Dispatcher dispatcher) async {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(future: () async {
      var tempJson = await getInfoJson();
      Dispatcher dispatcher = await getDispatcher(widget.driver);
      List<Requestee> tempRequestee = await getRequestees(dispatcher);
      List<Car> tempCars = await getCars(dispatcher);
      setState(() {
        infoJson = tempJson;
        pickups = tempRequestee;
        cars = tempCars;
      });
    }(), builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {}
      return ListView.builder(
          itemCount: infoJson.length,
          itemBuilder: (context, index) => Row(children: [
                Flexible(
                  child: DropdownSearch<Requestee>(
                    items: pickups,
                    itemAsString: (pickups) => pickups.name,
                    popupProps: PopupProps.modalBottomSheet(
                      itemBuilder: (context, requestee, isSelected) {
                        return CustomBox(children: [
                          UserProfilePic(name: requestee.name),
                          UserNameBox(name: requestee.name)
                        ]);
                      },
                    ),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Menu mode",
                        hintText: "country in menu mode",
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        infoJson[index.toString()]?["pickup"] =
                            value?.name ?? "";
                      });
                    },
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      var time = await showTimePicker(
                        initialEntryMode: TimePickerEntryMode.inputOnly,
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final now = DateTime.now();
                        setState(() {
                          infoJson[index.toString()]?["time"] = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            time.hour,
                            time.minute,
                          ).millisecondsSinceEpoch.toString();
                        });
                      }
                    },
                    child: Text(
                        "Selected time: ${infoJson[index.toString()]?['time']}"),
                  ),
                ),
                Flexible(
                  child: DropdownSearch<Car>(
                    items: cars,
                    itemAsString: (car) => car.name,
                    popupProps: PopupProps.menu(
                      itemBuilder: (context, car, isSelected) {
                        return CustomBox(
                            children: [UserNameBox(name: car.name)]);
                      },
                    ),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Menu mode",
                        hintText: "country in menu mode",
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        infoJson[index.toString()]?["vehicle"] =
                            value?.name ?? "";
                      });
                      print(infoJson);
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ),
              ]));
    }));
  }
}

Map<String, String> Function(String, String) emptyMap =
    (String driverName, String dateInMilliseconds) => {
          "date": dateInMilliseconds,
          "time": "",
          "driver": driverName,
          "vehicle": "",
          "pickup": "",
          "purpose": "",
        };
