import 'package:dispatch/cubit/user_view/user_view_cubit.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/utils/object_list_sorter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

abstract class UserListScreen<T extends User> extends StatelessWidget {
  final String title;
  const UserListScreen({
    super.key,
    required this.title,
  });

  Future<List<T>> data();
  UserRowFactory rowFactory();
  void Function() onTap(T user, BuildContext context);

  @override
  Widget build(BuildContext context) {
    var userRowFactory = rowFactory();
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
              userViewCubit.initialize<T>(
                loadData: data,
              );
              return loading();
            } else if (state is UserViewWithData<T>) {
              return UserList<T>(
                userList: state.users,
                rowFactory: userRowFactory,
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

abstract class UserInfoScreen<T extends User, M extends User>
    extends StatelessWidget {
  final T user;
  const UserInfoScreen({
    super.key,
    required this.user,
  });

  Future<List<M>> data();
  void Function() onTap(M user, BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.name}'s info"),
      ),
      body: BlocProvider(
        create: (context) => UserViewCubit(),
        child: BlocBuilder<UserViewCubit, UserViewState>(
          builder: (context, state) {
            if (state is UserViewInitial) {
              var userViewCubit = context.read<UserViewCubit>();
              userViewCubit.initialize<M>(loadData: data);
              return loading();
            } else if (state is UserViewWithData<M>) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40.0),
                  NameInfoBox(user: user),
                  const SizedBox(height: 20.0),
                  HeaderText<M>(),
                  Expanded(
                    child: UserList<M>(
                      userList: state.users,
                      onTap: onTap,
                      rowFactory: const GenericUserRowFactory(),
                    ),
                  )
                ],
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

class NameInfoBox extends StatelessWidget {
  final User user;
  const NameInfoBox({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            width: 1.5,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
          left: 16.0,
        ),
        child: Text(
          "Name: ${user.name}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class HeaderText<M extends User> extends StatelessWidget {
  const HeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    String header = "";
    if (M == Dispatcher) {
      header = "Dispatcher";
    } else if (M == Requestee) {
      header = "Requestees";
    }
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: 16.0,
      ),
      child: Text(
        header,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
          fontSize: 15,
        ),
      ),
    );
  }
}

class UserList<T extends User> extends StatelessWidget {
  final List<T> userList;
  final void Function() Function(T, BuildContext) onTap;
  final UserRowFactory rowFactory;
  const UserList({
    super.key,
    required this.userList,
    required this.onTap,
    required this.rowFactory,
  });

  @override
  Widget build(BuildContext context) {
    final List<T?> orderedUserList =
        ObjectListSorter(objectList: userList).sort();

    return ListView.builder(
      itemCount: orderedUserList.length,
      itemBuilder: (context, index) {
        return UserProfileRow<T>(
          user: orderedUserList[index],
          rowFactory: rowFactory,
          onTap: onTap,
        );
      },
    );
  }
}

class UserProfileRow<T extends User> extends StatelessWidget {
  final T? user;
  final void Function() Function(T, BuildContext) onTap;
  final UserRowFactory rowFactory;
  const UserProfileRow({
    super.key,
    required this.user,
    required this.onTap,
    required this.rowFactory,
  });

  @override
  Widget build(BuildContext context) {
    var user_ = user;
    if (user_ == null) {
      return loading();
    }
    return GestureDetector(
      onTap: onTap(user_, context),
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
            children: rowFactory.make(user),
          ),
        ),
      ),
    );
  }
}

abstract class UserRowFactory<T extends User> {
  const UserRowFactory();

  List<Widget> make(T? user);
}

class GenericUserRowFactory extends UserRowFactory<User> {
  const GenericUserRowFactory();
  @override
  List<Widget> make(user) {
    if (user == null) {
      return [];
    }
    return [
      UserProfilePic(name: user.name),
      UserNameBox(name: user.name),
    ];
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
