import 'package:dispatch/objects/car_objects.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:firebase_database/firebase_database.dart';

class CarDatabase {
  DatabaseReference ref =
      FirebaseDatabase.instance.ref('${Settings.companyid.toString()}/cars');

  Future<Iterable<DataSnapshot>> getAll() async {
    return (await ref.get()).children;
  }

  Future<void> delete(Car? car) async {
    if (car == null) {
      return;
    }
    int dispatcherid = car.dispatcher.id;
    Future<void> removeCarFromCarDB() async {
      await ref.child("${car.id}").remove();
    }

    Future<void> removeCarFromDispatchDB() async {
      await ref.root
          .child(
              "${Settings.companyid}/dispatchers/$dispatcherid/carsid/${car.id}")
          .remove();

      return;
    }

    Future<void> removeCarFromAdminDB() async {
      ref.root
          .child(
              "${Settings.companyid}/admin/dispatchers/$dispatcherid/carsid/${car.id}")
          .remove();
    }

    await Future.wait([
      removeCarFromCarDB(),
      removeCarFromDispatchDB(),
      removeCarFromAdminDB(),
    ]);
  }

  Future<void> add(Car? car) async {
    if (car == null) {
      return;
    }
    int dispatcherid = car.dispatcher.id;
    Future<void> addCarToCarDB() async {
      await ref.child("${car.id}").set(car.toMap());
    }

    Future<void> addCarToDispatchDB() async {
      await ref.root
          .child(
              "${Settings.companyid}/dispatchers/$dispatcherid/carsid/${car.id}")
          .set(car.id);
    }

    Future<void> addCarToAdminDB() async {
      ref.root
          .child(
              "${Settings.companyid}/admin/dispatchers/$dispatcherid/carsid/${car.id}")
          .set(car.id);
    }

    await Future.wait([
      addCarToCarDB(),
      addCarToDispatchDB(),
      addCarToAdminDB(),
    ]);
  }
}
