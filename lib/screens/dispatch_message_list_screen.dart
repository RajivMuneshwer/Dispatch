import 'package:dispatch/cubit/dispatch_message_list/dispatch_message_list_cubit.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class DispatchUsersListScreen extends StatelessWidget {
  const DispatchUsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => DispatchUsersListCubit(),
        child: const DispatchUsersList(),
      ),
    );
  }
}

class DispatchUsersList extends StatelessWidget {
  const DispatchUsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DispatchUsersListCubit, DispatchUserListState>(
      builder: (context, state) {
        if (state is DispatchUserListInitial) {
          final dispatchMessageListCubit =
              context.read<DispatchUsersListCubit>();
          dispatchMessageListCubit.initialize();
          return loading();
        } else if (state is DispatchUserListWithNames) {
          return const UserNameList();
        } else {
          return loading();
        }
      },
    );
  }
}

class UserNameList extends StatelessWidget {
  const UserNameList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DispatchUsersListCubit, DispatchUserListState>(
      builder: (context, state) {
        if (state is! DispatchUserListWithNames) {
          return Container();
        }
        List<String> names = state.names;
        return ListView.builder(
          itemCount: names.length,
          itemBuilder: (context, index) {
            return UserProfileRow(name: names[index]);
          },
        );
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
