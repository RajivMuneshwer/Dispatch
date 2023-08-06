import 'package:dispatch/cubit/user_view/user_view_cubit.dart';
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
              userViewCubit.initialize(loadUserData);
              return loading();
            } else if (state is UserViewWithData) {
              return UserList(
                userList: state.users,
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
  const UserList({
    super.key,
    required this.userList,
  });

  @override
  Widget build(BuildContext context) {
    final List<User?> orderedUserList =
        ObjectListSorter(objectList: userList).sort();

    print(orderedUserList[0]?.name);

    return ListView.builder(
      itemCount: orderedUserList.length,
      itemBuilder: (context, index) {
        return UserProfileRow(
            name: orderedUserList[index]?.name ?? "Error_Loading");
      },
    );
  }
}

class UserProfileRow extends StatelessWidget {
  final String name;
  const UserProfileRow({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("hello");
      },
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
            children: [
              UserProfilePic(name: name),
              UserNameBox(name: name),
            ],
          ),
        ),
      ),
    );
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
