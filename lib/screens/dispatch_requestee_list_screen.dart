import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/screens/message_screen.dart';
import 'package:dispatch/screens/user_list_screen.dart';
import 'package:flutter/material.dart';

class DispatchRequesteeListScreen extends UserListScreen {
  const DispatchRequesteeListScreen({
    super.key,
    super.title = "Requestee Messages",
  });

  @override
  Future<List<User>> initUsers() {
    return Future.delayed(duration, () {
      List<Requestee> requestees = [
        Requestee(id: 1, name: 'test', sortBy: 'test'),
        Requestee(id: 2, name: 'daniel', sortBy: 'daniel'),
        Requestee(id: 3, name: 'valeria', sortBy: 'valeria'),
        Requestee(id: 4, name: 'tommy', sortBy: 'tommy'),
        Requestee(id: 5, name: 'jay', sortBy: 'jay'),
        Requestee(id: 6, name: 'rajiv', sortBy: 'rajiv'),
        Requestee(id: 7, name: 'rust', sortBy: 'rust'),
      ];
      return requestees;
    });
  }

  @override
  UserRowFactory<User> rowFactory() => const GenericUserRowFactory();

  @override
  void Function() onTap(User user, BuildContext context) {
    return () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessageScreen(),
          ),
        );
  }

  @override
  Widget? floatingActionButton() {
    throw UnimplementedError();
  }

  @override
  Future<List<User>> Function() loadUsers(User lastUsers) {
    // TODO: implement loadMoreUsers
    throw UnimplementedError();
  }
}

const duration = Duration(microseconds: 100);
