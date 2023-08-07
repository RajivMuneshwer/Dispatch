import 'package:dispatch/cubit/user_view/user_view_cubit.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/utils/object_list_sorter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

abstract class UserListScreen extends StatelessWidget {
  final String title;
  const UserListScreen({
    super.key,
    required this.title,
  });

  Future<List<User>> loadUserData();
  void onTap();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocProvider(
        create: (context) => UserViewCubit(),
        child: BlocBuilder<UserViewCubit, UserViewState>(
          builder: (context, state) {
            if (state is UserViewInitial) {
              var userViewCubit = context.read<UserViewCubit>();
              userViewCubit.initialize(
                loadData: loadUserData,
              );
              return loading();
            } else if (state is UserViewWithData) {
              return UserList(
                userList: state.users,
                onTap: onTap,
              );
            } else {
              return loading();
            }
          },
        ),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  final List<User> userList;
  final void Function() onTap;
  const UserList({
    super.key,
    required this.userList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<User?> orderedUserList =
        ObjectListSorter(objectList: userList).sort();

    return ListView.builder(
      itemCount: orderedUserList.length,
      itemBuilder: (context, index) {
        return UserProfileRow(
          user: orderedUserList[index],
          onTap: onTap,
        );
      },
    );
  }
}

class UserProfileRow extends StatelessWidget {
  final User? user;
  final void Function() onTap;
  const UserProfileRow({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            children: UserRowFactory(user: user).make(),
          ),
        ),
      ),
    );
  }
}

class UserRowFactory {
  final User? user;
  const UserRowFactory({required this.user});

  List<Widget> make() {
    var user_ = user;
    if (user_ == null) {
      return [];
    } else if (user_ is Requestee) {
      return [
        UserProfilePic(name: user_.name),
        UserNameBox(name: user_.name),
      ];
    } else {
      return [
        UserProfilePic(name: user_.name),
        UserNameBox(name: user_.name),
      ];
    }
  }
}

class UserProfilePic extends StatelessWidget {
  final String name;
  const UserProfilePic({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: ProfilePicture(
        name: name,
        radius: 25,
        fontsize: 21,
      ),
    );
  }
}

class UserNameBox extends StatelessWidget {
  final String name;
  const UserNameBox({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 6,
      child: Container(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 10.0,
          ),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

Widget loading() => const Center(
      child: CircularProgressIndicator(),
    );
