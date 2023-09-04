import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/user_screens.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class DispatcherHomeScreen extends StatefulWidget {
  final Dispatcher dispatcher;
  const DispatcherHomeScreen({
    super.key,
    required this.dispatcher,
  });

  @override
  State<DispatcherHomeScreen> createState() => _DispatcherHomeScreenState();
}

class _DispatcherHomeScreenState extends State<DispatcherHomeScreen> {
  final DispatcherDatabase database = DispatcherDatabase();
  int currentIndex = 0;
  List<Widget> screens = [];

  @override
  void initState() {
    screens = [
      RequesteeMessageListScreen(
          database: database, dispatcher: widget.dispatcher),
      DriverMessageListScreen(dispatcher: widget.dispatcher, database: database)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: StyleProvider(
        style: NavStyle(),
        child: ConvexAppBar(
          curveSize: 75,
          top: -20,
          style: TabStyle.react,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            TabItem(
              icon: FontAwesomeIcons.user,
              title: 'Requestees',
            ),
            TabItem(
              icon: FontAwesomeIcons.carSide,
              title: 'Drivers',
            ),
          ],
        ),
      ),
    );
  }
}

class NavStyle extends StyleHook {
  @override
  double get activeIconMargin => 0;

  @override
  double get activeIconSize => 30;

  @override
  double? get iconSize => 20;

  @override
  TextStyle textStyle(Color color, String? fontFamily) {
    return TextStyle(fontSize: 14, color: color);
  }
}

class DriverMessageListScreen extends UserListScreen<Driver> {
  final Dispatcher dispatcher;
  final DispatcherDatabase database;
  const DriverMessageListScreen({
    super.key,
    super.title = "Driver Messages",
    required this.dispatcher,
    required this.database,
  });

  @override
  Widget? floatingActionButton() => null;

  @override
  Future<List<Driver>> initUsers() async =>
      (await database.getDrivers(id: dispatcher.id))
          .map((snapshot) => UserAdaptor<Driver>().adaptSnapshot(snapshot))
          .toList();

  @override
  Future<List<Driver>?> Function() loadUsers(Driver lastUsers) =>
      () async => [];

  @override
  void Function() onTap(Driver user, BuildContext context) {
    return () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DispatcherMessageScreen<Driver>(
              dispatcher: dispatcher,
              receiver: user,
            ),
          ),
        );
  }

  @override
  UserRowFactory<User> rowFactory() => MessageInfoRowFactory();
}

class RequesteeMessageListScreen extends UserListScreen<Requestee> {
  final DispatcherDatabase database;
  final Dispatcher dispatcher;
  const RequesteeMessageListScreen({
    super.key,
    super.title = "Requestee Messages",
    required this.database,
    required this.dispatcher,
  });

  @override
  Future<List<Requestee>> initUsers() async =>
      (await database.getRequestees(id: dispatcher.id))
          .map((snapshot) => UserAdaptor<Requestee>().adaptSnapshot(snapshot))
          .toList();

  @override
  UserRowFactory<Requestee> rowFactory() => MessageInfoRowFactory();

  @override
  void Function() onTap(Requestee user, BuildContext context) {
    return () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DispatcherMessageScreen<Requestee>(
              dispatcher: dispatcher,
              receiver: user,
            ),
          ),
        );
  }

  @override
  Widget? floatingActionButton() => null;

  @override
  Future<List<Requestee>> Function() loadUsers(User lastUsers) =>
      () async => [];
}

const duration = Duration(microseconds: 100);
