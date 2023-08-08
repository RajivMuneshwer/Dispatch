import 'package:dispatch/database/admin_database.dart';
import 'package:dispatch/database/database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/user_list_screen.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page"),
      ),
      body: const UserChoicesColumn(),
    );
  }
}

class UserChoiceBubble extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const UserChoiceBubble({
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
          border: Border.all(
            color: Colors.blue,
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
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class UserChoicesColumn extends StatelessWidget {
  const UserChoicesColumn({super.key});

  @override
  Widget build(BuildContext context) {
    AdminDatabase adminDatabase = AdminDatabase();
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(
            child: UserChoiceBubble(
              text: "Requestees",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllUserListScreen<Requestee>(
                    title: 'All Requestees',
                    database: adminDatabase,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: UserChoiceBubble(
              text: "Dispatchers",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllUserListScreen<Dispatcher>(
                    title: 'All Dispatchers',
                    database: adminDatabase,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: UserChoiceBubble(
              text: "Admins",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllUserListScreen<Admin>(
                    title: 'All Admin',
                    database: adminDatabase,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AllUserListScreen<T extends User> extends UserListScreen<T> {
  final Database database;

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
}

class UserInfoScreenFactory {
  UserInfoScreen make<T extends User>({
    required T user,
    required Database database,
  }) {
    if (user is Requestee) {
      return RequesteeInfoScreen(user: user, database: database);
    } else if (user is Dispatcher) {
      return DispatcherInfoScreen(user: user, database: database);
    } else if (user is Admin) {
      return AdminInfoScreen(user: user);
    } else {
      return UserErrorScreen(
        user: user,
      );
    }
  }
}

class AdminInfoScreen extends UserInfoScreen<Admin, User> {
  const AdminInfoScreen({super.key, required super.user});

  @override
  Future<List<User>> data() async => [];

  @override
  void Function() onTap(User user, BuildContext context) {
    return () => {};
  }
}

class RequesteeInfoScreen extends UserInfoScreen<Requestee, Dispatcher> {
  final Database database;
  const RequesteeInfoScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<List<Dispatcher>> data() async {
    int? id = user.dispatcherid;
    if (id == null) {
      return [];
    }
    return (await database.getOne<Dispatcher>(id))
        .map((snapshot) => UserAdaptor<Dispatcher>().adaptSnapshot(snapshot))
        .toList();
  }

  @override
  void Function() onTap(Dispatcher user, BuildContext context) {
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

class DispatcherInfoScreen extends UserInfoScreen<Dispatcher, Requestee> {
  final Database database;
  const DispatcherInfoScreen({
    super.key,
    required super.user,
    required this.database,
  });

  @override
  Future<List<Requestee>> data() async {
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
  void Function() onTap(Requestee user, BuildContext context) {
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
}

class UserErrorScreen extends UserInfoScreen<User, User> {
  const UserErrorScreen({super.key, required super.user});

  @override
  Widget build(BuildContext context) {
    return errorScreen(context);
  }

  @override
  Future<List<User>> data() {
    throw UnimplementedError();
  }

  @override
  void Function() onTap(User user, BuildContext context) {
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


////TODO
///Make edit button that takes to update page to update / delete user info
///use an absract update page to make
///
///Make an addition floating action button to add more of those kinds of users
