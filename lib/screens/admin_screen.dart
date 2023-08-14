import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
    String text = "";
    if (T == Requestee) {
      text = "Requestees";
    } else if (T == Dispatcher) {
      text = "Dispatchers";
    } else if (T == Admin) {
      text = "Admin";
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    String text = bubbleText();
    return Center(
      child: ChoiceBubble(
        text: text,
        onPressed: () => Navigator.pushNamed(
          context,
          '/all',
          arguments: {
            "type": typeToUserType<T>(),
            "database": database,
            "title": "All $text",
          },
        ),
      ),
    );
  }
}

class AllUserListScreen<T extends User> extends UserListScreen<T> {
  final AppDatabase database;

  const AllUserListScreen({
    super.key,
    required super.title,
    required this.database,
  });

  @override
  Future<List<T>> data() async => (await database.getAll<T>())
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
}

class UserInfoScreenFactory {
  Widget make<T extends User>({
    required T user,
    required AppDatabase database,
  }) {
    return switch (user) {
      Requestee() => RequesteeInfoScreen(user: user, database: database),
      Dispatcher() => DispatcherInfoScreen(user: user, database: database),
      Admin() => AdminInfoScreen(
          user: user,
          database: database,
        )
    };
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
      _ => ErrorEditScreen(),
    };
  }
}

class RequesteeEditScreen extends UserEditScreen<Requestee> {
  final AppDatabase database;
  static const textName = "requesteename";
  static const dropdownName = "requesteedispatch";
  RequesteeEditScreen({
    super.key,
    required super.user,
    super.textFieldName = textName,
    required this.database,
  });

  @override
  Future<Widget> addChild() async {
    List<Dispatcher> dispatchers = (await database.getAll<Dispatcher>())
        .map(
          (e) => UserAdaptor<Dispatcher>().adaptSnapshot(e),
        )
        .toList();
    var user_ = user;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderDropdown<int>(
        decoration: const InputDecoration(
          labelText: "Dispatcher",
          labelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
        name: dropdownName,
        initialValue: (user_ != null) ? user_.dispatcherid : null,
        items: dispatchers
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

  @override
  Future<void> createuser({required FormBuilderState currentState}) async {
    var textField = currentState.fields[textName];
    var dropdownField = currentState.fields[dropdownName];
    if (textField == null || dropdownField == null) {
      return;
    }

    final newRequestee = Requestee(
      id: getUniqueid(),
      name: textField.value,
      sortBy: textField.value,
      dispatcherid: dropdownField.value,
    );
    await AllDatabase().create<Requestee>(newRequestee);
    return;
  }

  @override
  Future<void> updateuser(
      {required FormBuilderState currentState, required Requestee user}) async {
    var textField = currentState.fields[textName];
    var dropdownField = currentState.fields[dropdownName];
    if (textField == null || dropdownField == null) {
      return;
    }

    Map<String, Object?> updatemap = {
      "name": textField.value,
      "dispatcherid": dropdownField.value
    };

    await AllDatabase().update(user, updatemap);
  }

  @override
  Future<void> deleteuser({required Requestee user}) async {
    try {
      await AllDatabase().delete<Requestee>(user);
    } catch (e) {
      rethrow;
    }
  }
}

class DispatchEditScreen extends UserEditScreen<Dispatcher> {
  final AppDatabase database;
  static const textName = "dispatchername";

  DispatchEditScreen({
    super.key,
    required super.user,
    super.textFieldName = textName,
    required this.database,
  });

  @override
  Future<Widget> addChild() async => Container();

  @override
  Future<void> createuser({required FormBuilderState currentState}) async {
    var textField = currentState.fields[textName];
    if (textField == null) {
      return;
    }
    final newDispatcher = Dispatcher(
      id: getUniqueid(),
      name: textField.value,
      sortBy: textField.value,
      requesteesid: [],
    );

    await AllDatabase().create<Dispatcher>(newDispatcher);
  }

  @override
  Future<void> updateuser(
      {required FormBuilderState currentState,
      required Dispatcher user}) async {
    var textField = currentState.fields[textName];
    if (textField == null) {
      return;
    }
    Map<String, Object?> updateMap = {"name": textField.value};
    await AllDatabase().update(user, updateMap);
  }

  @override
  Future<void> deleteuser({required Dispatcher user}) async {
    try {
      await AllDatabase().delete<Dispatcher>(user);
    } catch (e) {
      rethrow;
    }
  }
}

class AdminEditScreen extends UserEditScreen<Admin> {
  final AppDatabase database;
  static const textName = "adminname";

  AdminEditScreen({
    super.key,
    required super.user,
    super.textFieldName = textName,
    required this.database,
  });

  @override
  Future<Widget> addChild() async => Container();

  @override
  Future<void> createuser({required FormBuilderState currentState}) async {
    var textField = currentState.fields[textName];
    if (textField == null) {
      return;
    }
    final newAdmin = Admin(
      id: getUniqueid(),
      name: textField.value,
      sortBy: textField.value,
    );

    await AllDatabase().create<Admin>(newAdmin);
  }

  @override
  Future<void> updateuser(
      {required FormBuilderState currentState, required Admin user}) async {
    var textField = currentState.fields[textName];
    if (textField == null) {
      return;
    }
    Map<String, Object?> updateMap = {"name": textField.value};
    await AllDatabase().update(user, updateMap);
  }

  @override
  Future<void> deleteuser({required Admin user}) async {
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
    super.textFieldName = "error",
  });

  @override
  Future<Widget> addChild() {
    throw UnimplementedError();
  }

  @override
  Future<void> createuser({required FormBuilderState currentState}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateuser(
      {required FormBuilderState currentState, required User user}) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return errorScreen(context);
  }

  @override
  Future<void> deleteuser({required User user}) {
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
  error,
}

UserType typeToUserType<T extends User>() => switch (T) {
      Requestee => UserType.requestee,
      Dispatcher => UserType.dispatcher,
      Admin => UserType.admin,
      _ => UserType.error,
    };

////TODO
///make it so that I do not download all the user data at once
///sense how far the user is scrolled down an then call the function to grab more 
///from the database
///
///This will be useful for the dispatcher screen and the catalogue in the future.
///
