import 'package:dispatch/database/car_database.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/objects/car_objects.dart';
import 'package:dispatch/objects/settings_object.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:dispatch/screens/admin_screen.dart';
import 'package:dispatch/screens/user_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CarChoiceBubble extends StatelessWidget {
  const CarChoiceBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChoiceBubble(
        text: "Cars",
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarListScreen(),
          ),
        ),
      ),
    );
  }
}

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  CarDatabase carDatabase = CarDatabase();
  List<Car> cars = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Cars"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarEditScreen(car: null),
          ),
        ),
        backgroundColor: Settings.primaryColor,
        child: Icon(
          Icons.add,
          color: Settings.onPrimary,
        ),
      ),
      body: FutureBuilder(
        future: () async {
          CarAdaptor carAdaptor = CarAdaptor();
          setState(() async {
            cars = (await carDatabase.getAll())
                .map((carSnap) => carAdaptor.adaptSnapshot(carSnap))
                .toList();
          });
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          return RefreshIndicator(
            onRefresh: () async {
              var caradaptor = CarAdaptor();
              //add the call to refresh
              List<Car> refreshCars = (await carDatabase.getAll())
                  .map(
                    (carSnap) => caradaptor.adaptSnapshot(carSnap),
                  )
                  .toList();
              setState(() {
                cars = refreshCars;
              });
            },
            child: ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                Car car = cars[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarInfoScreen(car: car),
                    ),
                  ),
                  child: CustomBox(
                    children: [
                      UserProfilePic(name: car.name),
                      UserNameBox(name: car.name)
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CustomBox extends StatelessWidget {
  final List<Widget> children;
  const CustomBox({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            width: 1.5,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      height: 95,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: children,
        ),
      ),
    );
  }
}

class CarInfoScreen extends StatelessWidget {
  final Car car;
  const CarInfoScreen({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${car.name}'s info")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          TextInfoBox(text: "Name: ${car.name}"),
          const SizedBox(height: 40),
          TextInfoBox(text: "License: ${car.licensePlate}"),
          const SizedBox(height: 40),
          const HeaderText<Dispatcher>(),
          CarDispatcherBox(
            dispatcher: car.dispatcher,
          ),
          const SizedBox(height: 20),
          EditCarButton(car: car),
        ],
      ),
    );
  }
}

class CarDispatcherBox extends StatelessWidget {
  final Dispatcher dispatcher;
  const CarDispatcherBox({
    super.key,
    required this.dispatcher,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DispatcherInfoScreen(
              user: dispatcher,
              database: AdminDatabase(),
            ),
          )),
      child: CustomBox(children: [
        UserProfilePic(name: dispatcher.name),
        UserNameBox(name: dispatcher.name)
      ]),
    );
  }
}

class EditCarButton extends StatelessWidget {
  final Car car;
  const EditCarButton({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarEditScreen(car: car),
                  )),
              child: const Text("Edit")),
        ),
      ),
    );
  }
}

class CarEditScreen extends StatelessWidget {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final Car? car;
  final CarDatabase carDatabase = CarDatabase();
  CarEditScreen({
    super.key,
    required this.car,
  });

  @override
  Widget build(BuildContext context) {
    bool isCarNull = (car == null);

    String title = isCarNull ? "Create new car" : "Update car info";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              onPressed: (isCarNull)
                  ? () {}
                  : () async {
                      await showDialog<void>(
                        context: context,
                        builder: (context) => DeleteCarConfirmationBox(
                          car: car,
                          carDatabase: carDatabase,
                        ),
                      );
                      int count = 0;
                      Navigator.popUntil(context, (route) => ++count > 2);
                    },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: () async {
            AdminDatabase adminDatabase = AdminDatabase();
            UserAdaptor<Dispatcher> userAdaptor = UserAdaptor<Dispatcher>();
            List<Dispatcher> dispatchers = (await adminDatabase
                    .getAll<Dispatcher>())
                .map((dispatchSnap) => userAdaptor.adaptSnapshot(dispatchSnap))
                .toList();
            return dispatchers;
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container();
            }
            List<Dispatcher> dropdownOptions = snapshot.data ?? [];
            return FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  EditNameField(
                    name: "name",
                    initial: isCarNull ? null : car!.name,
                    labelText: "Name",
                  ),
                  const SizedBox(height: 20),
                  EditNameField(
                    name: "license",
                    initial: isCarNull ? null : car!.licensePlate,
                    labelText: "License",
                  ),
                  const SizedBox(height: 40),
                  CarDropdownDispatchFormField(
                    dropdownOptions: dropdownOptions,
                    initial: (isCarNull) ? null : car!.dispatcher,
                    name: "dispatcher",
                  ),
                  const SizedBox(height: 40),
                  CreateCarButton(
                    car: car,
                    formKey: _formKey,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DeleteCarConfirmationBox extends StatelessWidget {
  final Car? car;
  final CarDatabase carDatabase;
  const DeleteCarConfirmationBox({
    super.key,
    required this.car,
    required this.carDatabase,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm delete'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("Are you sure you wish to delete the car?"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              Navigator.of(context).pop();
              await carDatabase.delete(car);
            } catch (e) {
              await showDialog<void>(
                context: context,
                builder: (context) => ExceptionAlertBox(errorString: "$e"),
              );
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class CarDropdownDispatchFormField extends StatelessWidget {
  final String name;
  final List<Dispatcher> dropdownOptions;
  final Dispatcher? initial;
  final String labelText;
  const CarDropdownDispatchFormField({
    super.key,
    required this.dropdownOptions,
    required this.initial,
    required this.name,
    this.labelText = "Dispatcher",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderDropdown<Dispatcher>(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
        name: name,
        initialValue: initial,
        items: dropdownOptions
            .map((dispatcher) => DropdownMenuItem(
                  value: dispatcher,
                  child: Text(dispatcher.name),
                ))
            .toList(),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
      ),
    );
  }
}

class CreateCarButton extends StatefulWidget {
  final Car? car;
  final GlobalKey<FormBuilderState> formKey;
  const CreateCarButton({
    super.key,
    required this.car,
    required this.formKey,
  });

  @override
  State<CreateCarButton> createState() => _CreateCarButtonState();
}

class _CreateCarButtonState extends State<CreateCarButton> {
  bool free = true;

  createCar({required FormBuilderState formState}) {
    CarDatabase carDatabase = CarDatabase();
    if (formState.fields
        case {
          "name": var nameField,
          "license": var licenseField,
          "dispatcher": var dispatcherField,
        }) {
      Car car = Car(
        id: (widget.car == null) ? getUniqueid() : widget.car!.id,
        licensePlate: (licenseField.value as String).trim(),
        name: (nameField.value as String).trim(),
        dispatcher: dispatcherField.value as Dispatcher,
      );
      carDatabase.add(car);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: (free) ? Colors.blue : Colors.grey,
        ),
        onPressed: (free)
            ? () async {
                setState(() {
                  free = false;
                });
                var formState = widget.formKey.currentState;
                var car_ = widget.car;
                if (formState!.validate() == true) {
                  await createCar(formState: formState);
                  int count = 0;
                  Navigator.popUntil(context,
                      (route) => (car_ == null) ? ++count > 1 : ++count > 2);
                }
              }
            : () {},
        child: (free)
            ? Text(
                (widget.car != null) ? "Update" : "Create",
              )
            : const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
      ),
    );
  }
}
