import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/user_screens.dart';
import 'package:flutter/material.dart';

class RequesteeMessageListScreen extends UserListScreen<Requestee> {
  final DispatcherDatabase database = DispatcherDatabase();
  final Dispatcher dispatcher = Dispatcher(
      id: 1691793507356,
      name: "Tasha",
      sortBy: "Tasha",
      driversid: [1692736506506]);
  RequesteeMessageListScreen({
    super.key,
    super.title = "Requestee Messages",
  });

  @override
  Future<List<Requestee>> initUsers() async =>
      (await database.getRequestees(id: dispatcher.id))
          .map((snapshot) => UserAdaptor<Requestee>().adaptSnapshot(snapshot))
          .toList();

  @override
  UserRowFactory<Requestee> rowFactory() => RequesteeMessagesRowFactory();

  @override
  void Function() onTap(Requestee user, BuildContext context) {
    return () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DispatcherMessageScreen(
              user: dispatcher,
              requestee: user,
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
