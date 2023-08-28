import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/user_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:phone_form_field/phone_form_field.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page"),
      ),
      body: const UserChoicesColumn(),
    );
  }
}

class UserChoicesColumn extends StatelessWidget {
  const UserChoicesColumn({super.key});

  @override
  Widget build(BuildContext context) {
    AppDatabase adminDatabase = AdminDatabase();
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          UserChoiceBubble<Requestee>(
            database: adminDatabase,
          ),
          const SizedBox(height: 40),
          UserChoiceBubble<Dispatcher>(
            database: adminDatabase,
          ),
          const SizedBox(height: 40),
          UserChoiceBubble<Admin>(
            database: adminDatabase,
          ),
          const SizedBox(height: 40),
          UserChoiceBubble<Driver>(
            database: adminDatabase,
          )
        ],
      ),
    );
  }
}

class UserChoiceBubble<T extends User> extends StatelessWidget {
  final AppDatabase database;
  const UserChoiceBubble({
    super.key,
    required this.database,
  });

  String bubbleText() {
    return switch (T) {
      Requestee => "Requestee",
      Dispatcher => "Dispatcher",
      Admin => "Admin",
      Driver => "Driver",
      _ => "",
    };
  }

  @override
  Widget build(BuildContext context) {
    String text = bubbleText();
    return Center(
      child: ChoiceBubble(
        text: text,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AllUserListScreen<T>(
                    title: "All $text",
                    database: database,
                  )),
        ),
      ),
    );
  }
}

class AllUserListScreen<T extends User> extends UserListScreen<T> {
  final AppDatabase database;
  final int limit = 15;
  final String orderBy = "name";
  const AllUserListScreen({
    super.key,
    required super.title,
    required this.database,
  });

  @override
  Future<List<T>> initUsers() async => (await database.getSome<T>(
          limit: limit, lastUser: null, orderBy: orderBy))
      .map((snapshot) => UserAdaptor<T>().adaptSnapshot(snapshot))
      .toList();

  @override
  void Function() onTap(T user, BuildContext context) {
    return () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserInfoScreenFactory().make<T>(
              user: user,
              database: database,
            ),
          ),
        );
  }

  @override
  UserRowFactory<User> rowFactory() => const GenericUserRowFactory();

  @override
  Widget? floatingActionButton() => AddFloatButton(
        onPressed: (BuildContext context) => () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditScreenFactory().make<T>(user: null, database: database),
            )),
      );

  @override
  Future<List<T>?> Function() loadUsers(T lastUsers) {
    return () async {
      List<T> newUsers = (await database.getSome<T>(
              limit: limit, lastUser: lastUsers, orderBy: orderBy))
          .map((snapshot) => UserAdaptor<T>().adaptSnapshot(snapshot))
          .toList();
      if (newUsers.isEmpty) return null;
      return newUsers;
    };
  }
}

class UserInfoScreenFactory {
  Widget make<T extends User>({
    required T user,
    required AppDatabase database,
  }) {
    return switch (user) {
      Requestee() => RequesteeInfoScreen(user: user, database: database),
      Dispatcher() => DispatcherInfoScreen(user: user, database: database),
      Admin() => AdminInfoScreen(user: user, database: database),
      Driver() => DriverInfoScreen(user: user, database: database),
    };
  }
}

class DriverInfoScreen extends UserInfoScreen<Driver, Dispatcher> {
  final AppDatabase database;
  const DriverInfoScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<List<Dispatcher>> additionData() async {
    int? id = user.dispatcherid;
    if (id == null) {
      return [];
    }
    return (await database.getOne<Dispatcher>(id))
        .map((snapshot) => UserAdaptor<Dispatcher>().adaptSnapshot(snapshot))
        .toList();
  }

  @override
  Future<List<Dispatcher>?> Function() loadData(Dispatcher lastUsers) =>
      () async => null;

  @override
  void Function() onEditTap(Driver user, BuildContext context) => () =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditScreenFactory().make<Driver>(database: database, user: user),
        ),
      );

  @override
  void Function() onUserTap(Dispatcher user, BuildContext context) {
    return () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DispatcherInfoScreen(
            user: user,
            database: database,
          ),
        ));
  }
}

class AdminInfoScreen extends UserInfoScreen<Admin, User> {
  final AppDatabase database;
  const AdminInfoScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<List<User>> additionData() async => [];

  @override
  void Function() onUserTap(User user, BuildContext context) {
    return () => {};
  }

  @override
  void Function() onEditTap(Admin user, BuildContext context) =>
      () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditScreenFactory()
                    .make<Admin>(database: database, user: user)),
          );

  @override
  Future<List<User>?> Function() loadData(User lastUsers) => () async => null;
}

class RequesteeInfoScreen extends UserInfoScreen<Requestee, Dispatcher> {
  final AppDatabase database;
  const RequesteeInfoScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<List<Dispatcher>> additionData() async {
    int? id = user.dispatcherid;
    if (id == null) {
      return [];
    }
    return (await database.getOne<Dispatcher>(id))
        .map((snapshot) => UserAdaptor<Dispatcher>().adaptSnapshot(snapshot))
        .toList();
  }

  @override
  void Function() onUserTap(Dispatcher user, BuildContext context) {
    return () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DispatcherInfoScreen(
            user: user,
            database: database,
          ),
        ));
  }

  @override
  void Function() onEditTap(Requestee user, BuildContext context) =>
      () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditScreenFactory()
                    .make<Requestee>(database: database, user: user)),
          );

  @override
  Future<List<Dispatcher>?> Function() loadData(Dispatcher lastUsers) =>
      () async => null;
}

class DispatcherInfoScreen extends UserInfoScreen<Dispatcher, Requestee> {
  final AppDatabase database;
  const DispatcherInfoScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<List<Requestee>> additionData() async {
    List<int>? ids = user.requesteesid;
    if (ids == null) {
      return [];
    }
    List<Requestee> requestees = [];
    for (final id in ids) {
      requestees.addAll((await database.getOne<Requestee>(id))
          .map((snapshot) => UserAdaptor<Requestee>().adaptSnapshot(snapshot))
          .toList());
    }
    return requestees;
  }

  @override
  void Function() onUserTap(Requestee user, BuildContext context) {
    return () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequesteeInfoScreen(
              user: user,
              database: database,
            ),
          ),
        );
  }

  @override
  void Function() onEditTap(Dispatcher user, BuildContext context) =>
      () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditScreenFactory()
                    .make<Dispatcher>(database: database, user: user)),
          );

  @override
  Future<List<Requestee>?> Function() loadData(Requestee lastUsers) =>
      () async => null;
}

class UserErrorScreen extends UserInfoScreen<User, User> {
  const UserErrorScreen({super.key, required super.user});

  @override
  Widget build(BuildContext context) {
    return errorScreen(context);
  }

  @override
  Future<List<User>> additionData() {
    throw UnimplementedError();
  }

  @override
  void Function() onUserTap(User user, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  void Function() onEditTap(User user, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Future<List<User>?> Function() loadData(User lastUsers) {
    // TODO: implement loadData
    throw UnimplementedError();
  }
}

class EditScreenFactory {
  Widget make<T extends User>(
      {required AppDatabase database, required T? user}) {
    return switch (T) {
      Requestee =>
        RequesteeEditScreen(user: user as Requestee?, database: database),
      Dispatcher =>
        DispatchEditScreen(user: user as Dispatcher?, database: database),
      Admin => AdminEditScreen(user: user as Admin?, database: database),
      Driver => DriverEditScreen(user: user as Driver?, database: database),
      _ => ErrorEditScreen(),
    };
  }
}

class DriverEditScreen extends UserEditScreen<Driver> {
  final AppDatabase database;
  static const textName = "name";
  static const dropdownName = "dispatcherid";
  static const telName = "tel";
  DriverEditScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<Widget> addWidgets() async {
    List<Dispatcher> dispatchers = (await database.getAll<Dispatcher>())
        .map(
          (e) => UserAdaptor<Dispatcher>().adaptSnapshot(e),
        )
        .toList();
    var user_ = user;
    return Column(
      children: [
        const SizedBox(height: 20),
        EditNameField(name: textName, initial: user?.name),
        const SizedBox(height: 20),
        EditTelField(name: telName, initialTel: user?.tel),
        const SizedBox(height: 20),
        EditDropdownFormField(
          dropdownOptions: dispatchers,
          initialId: (user_ != null) ? user_.dispatcherid : null,
          name: dropdownName,
        ),
      ],
    );
  }

  @override
  Future<void> createUser({required FormBuilderState state}) async {
    if (state.fields
        case {
          textName: var textField,
          dropdownName: var dropdownField,
          telName: var telField,
        }) {
      final newDriver = Driver(
        id: getUniqueid(),
        name: textField.value,
        sortBy: textField.value,
        dispatcherid: dropdownField.value,
        tel: telField.value,
      );
      await AllDatabase().create<Driver>(newDriver);
      return;
    }
  }

  @override
  Future<void> deleteUser({required Driver user}) async {
    try {
      await AllDatabase().delete<Driver>(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUser({
    required FormBuilderState state,
    required Driver user,
  }) async {
    if (state.fields
        case {
          textName: var textField,
          dropdownName: var dropdownField,
          telName: var telField,
        }) {
      await AllDatabase().update(user, {
        "name": textField.value,
        "dispatcherid": dropdownField.value,
        "tel": (telField.value as PhoneNumber).toJson(),
      });
    }
  }
}

class RequesteeEditScreen extends UserEditScreen<Requestee> {
  final AppDatabase database;
  static const textName = "name";
  static const dropdownName = "dispatcherid";
  static const telName = "tel";
  RequesteeEditScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<Widget> addWidgets() async {
    List<Dispatcher> dispatchers = (await database.getAll<Dispatcher>())
        .map(
          (e) => UserAdaptor<Dispatcher>().adaptSnapshot(e),
        )
        .toList();
    var user_ = user;
    return Column(
      children: [
        const SizedBox(height: 20),
        EditNameField(name: textName, initial: user?.name),
        const SizedBox(height: 20),
        EditTelField(name: telName, initialTel: user?.tel),
        const SizedBox(height: 20),
        EditDropdownFormField(
          dropdownOptions: dispatchers,
          initialId: (user_ != null) ? user_.dispatcherid : null,
          name: dropdownName,
        ),
      ],
    );
  }

  @override
  Future<void> createUser({
    required FormBuilderState state,
  }) async {
    if (state.fields
        case {
          textName: var textField,
          dropdownName: var dropdownField,
          telName: var telField,
        }) {
      final newRequestee = Requestee(
          id: getUniqueid(),
          name: textField.value,
          sortBy: textField.value,
          dispatcherid: dropdownField.value,
          tel: telField.value);
      await AllDatabase().create<Requestee>(newRequestee);
      return;
    }
  }

  @override
  Future<void> updateUser({
    required FormBuilderState state,
    required Requestee user,
  }) async {
    if (state.fields
        case {
          textName: var textField,
          dropdownName: var dropdownField,
          telName: var telField,
        }) {
      await AllDatabase().update(user, {
        "name": textField.value,
        "dispatcherid": dropdownField.value,
        "tel": (telField.value as PhoneNumber).toJson(),
      });
    }
  }

  @override
  Future<void> deleteUser({required Requestee user}) async {
    try {
      await AllDatabase().delete<Requestee>(user);
    } catch (e) {
      rethrow;
    }
  }
}

class DispatchEditScreen extends UserEditScreen<Dispatcher> {
  final AppDatabase database;
  static const textName = "name";
  static const telName = "tel";
  DispatchEditScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<Widget> addWidgets() async => Column(
        children: [
          const SizedBox(height: 20),
          EditNameField(name: textName, initial: user?.name),
          const SizedBox(height: 20),
          EditTelField(name: telName, initialTel: user?.tel),
          const SizedBox(height: 20),
        ],
      );

  @override
  Future<void> createUser({required FormBuilderState state}) async {
    if (state.fields
        case {
          textName: var textField,
          telName: var telField,
        }) {
      final newDispatcher = Dispatcher(
          id: getUniqueid(),
          name: textField.value,
          sortBy: textField.value,
          requesteesid: [],
          tel: telField.value);
      await AllDatabase().create<Dispatcher>(newDispatcher);
    }
  }

  @override
  Future<void> updateUser({
    required FormBuilderState state,
    required Dispatcher user,
  }) async {
    if (state.fields
        case {
          textName: var textField,
          telName: var telField,
        }) {
      await AllDatabase().update(user, {
        "name": textField.value,
        "tel": (telField.value as PhoneNumber).toJson(),
      });
    }
  }

  @override
  Future<void> deleteUser({required Dispatcher user}) async {
    try {
      await AllDatabase().delete<Dispatcher>(user);
    } catch (e) {
      rethrow;
    }
  }
}

class AdminEditScreen extends UserEditScreen<Admin> {
  final AppDatabase database;
  static const textName = "name";
  static const telName = "tel";
  AdminEditScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<Widget> addWidgets() async => Column(
        children: [
          const SizedBox(height: 20),
          EditTelField(name: telName, initialTel: user?.tel),
          const SizedBox(height: 20),
          EditNameField(
            name: textName,
            initial: user?.name,
          )
        ],
      );

  @override
  Future<void> createUser({required FormBuilderState state}) async {
    if (state.fields
        case {
          textName: var textField,
          telName: var telField,
        }) {
      final newAdmin = Admin(
        id: getUniqueid(),
        name: textField.value,
        sortBy: textField.value,
        tel: telField.value,
      );
      await AllDatabase().create<Admin>(newAdmin);
    }
  }

  @override
  Future<void> updateUser({
    required FormBuilderState state,
    required Admin user,
  }) async {
    if (state.fields
        case {
          textName: var textField,
          telName: var telField,
        }) {
      await AllDatabase().update(user, {
        "name": textField,
        "tel": telField,
      });
      return;
    }
  }

  @override
  Future<void> deleteUser({required Admin user}) async {
    try {
      await AllDatabase().delete<Admin>(user);
    } catch (e) {
      rethrow;
    }
  }
}

class ErrorEditScreen extends UserEditScreen<User> {
  ErrorEditScreen({
    super.key,
    super.user,
  });

  @override
  Future<Widget> addWidgets() {
    throw UnimplementedError();
  }

  @override
  Future<void> createUser({required FormBuilderState state}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUser(
      {required FormBuilderState state, required User user}) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return errorScreen(context);
  }

  @override
  Future<void> deleteUser({required User user}) {
    throw UnimplementedError();
  }
}

Widget errorScreen(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Error Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );

class EditDropdownFormField extends StatelessWidget {
  final String name;
  final List<User> dropdownOptions;
  final int? initialId;
  const EditDropdownFormField({
    super.key,
    required this.dropdownOptions,
    required this.initialId,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderDropdown<int>(
        decoration: const InputDecoration(
          labelText: "Dispatcher",
          labelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
        name: name,
        initialValue: initialId,
        items: dropdownOptions
            .map((dispatcher) => DropdownMenuItem(
                  value: dispatcher.id,
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

class EditTelField extends StatelessWidget {
  final String name;
  final PhoneNumber? initialTel;
  const EditTelField({
    super.key,
    required this.name,
    this.initialTel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderField<PhoneNumber>(
        name: name,
        validator: FormBuilderValidators.required(),
        builder: (field) => PhoneFormField(
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: const InputDecoration(
              labelText: 'Phone', border: UnderlineInputBorder()),
          validator: PhoneValidator.validMobile(
            errorText: "invalid phone number",
            allowEmpty: false,
          ),
          initialValue: initialTel,
          onChanged: (value) {
            if (value!.isValid(type: PhoneNumberType.mobile)) {
              field.didChange(value);
            }
          },
        ),
      ),
    );
  }
}

class EditNameField extends StatelessWidget {
  final String name;
  final String? initial;
  const EditNameField({super.key, required this.name, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        name: name,
        autocorrect: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        initialValue: initial,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: "Name",
          labelStyle: const TextStyle(fontWeight: FontWeight.normal),
          border: UnderlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.match(r'^[a-zA-Z0-9_\s]+$')
        ]),
      ),
    );
  }
}

class ChoiceBubble extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const ChoiceBubble({
    super.key,
    required this.text,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth * 2 / 3;
    double screenHeight = MediaQuery.of(context).size.height;
    double widgetHeight = screenHeight * 1 / 6;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: widgetWidth,
        height: widgetHeight,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 33, 96, 243),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(100),
            right: Radius.circular(100),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class AddFloatButton extends StatelessWidget {
  final void Function()? Function(BuildContext context) onPressed;
  const AddFloatButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed(context),
      backgroundColor: Colors.blue,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}

enum UserType {
  requestee,
  dispatcher,
  admin,
  driver,
  error,
}

UserType typeToUserType<T extends User>() => switch (T) {
      Requestee => UserType.requestee,
      Dispatcher => UserType.dispatcher,
      Admin => UserType.admin,
      Driver => UserType.driver,
      _ => UserType.error,
    };

////TODO
///make it so that I do not download all the user data at once
///sense how far the user is scrolled down an then call the function to grab more 
///from the database
///
///This will be useful for the dispatcher screen and the catalogue in the future.
///
