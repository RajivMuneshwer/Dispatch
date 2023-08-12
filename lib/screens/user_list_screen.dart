import 'package:dispatch/cubit/user_view/user_view_cubit.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/utils/object_list_sorter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

abstract class UserListScreen<T extends User> extends StatelessWidget {
  final String title;
  const UserListScreen({
    super.key,
    required this.title,
  });

  Future<List<T>> data();
  UserRowFactory rowFactory();
  void Function() onTap(T user, BuildContext context);
  Widget? floatingActionButton();

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
              userViewCubit.initusers<T>(
                data: data,
              );
              return loading();
            } else if (state is UserViewWithUsers<T>) {
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<UserViewCubit>().initusers(data: data),
                child: UserList<T>(
                  userList: state.users,
                  rowFactory: userRowFactory,
                  onTap: onTap,
                ),
              );
            } else {
              return loading();
            }
          },
        ),
      ),
      floatingActionButton: floatingActionButton(),
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

  Future<List<M>> additionData();
  void Function() onUserTap(M user, BuildContext context);
  void Function() onEditTap(T user, BuildContext context);

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
              userViewCubit.initusers<M>(data: additionData);
              return loading();
            } else if (state is UserViewWithUsers<M>) {
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<UserViewCubit>().initusers(data: additionData),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40.0),
                    NameInfoBox(user: user),
                    const SizedBox(height: 20.0),
                    HeaderText<M>(),
                    Expanded(
                      flex: 1,
                      child: UserList<M>(
                        userList: state.users,
                        onTap: onUserTap,
                        rowFactory: const GenericUserRowFactory(),
                      ),
                    ),
                    EditUserButton<T>(
                      user: user,
                      onEditTap: onEditTap,
                    ),
                  ],
                ),
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

class EditUserButton<T extends User> extends StatelessWidget {
  final T user;
  final void Function() Function(T user, BuildContext context) onEditTap;
  const EditUserButton({
    super.key,
    required this.onEditTap,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: onEditTap(user, context),
          child: const Text("Edit"),
        ),
      )),
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

abstract class UserEditScreen<T extends User> extends StatelessWidget {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final T? user;
  final String textFieldName;
  UserEditScreen({
    super.key,
    required this.user,
    required this.textFieldName,
  });

  Future<Widget> addChild();
  Future<void> updateuser({
    required FormBuilderState currentState,
    required T user,
  });
  Future<void> createuser({required FormBuilderState currentState});
  Future<void> deleteuser({required T user});

  Text title() {
    T? user_ = user;
    if (user_ != null) {
      return Text("Edit ${user_.name}");
    }
    String userTypeName = "";
    if (T == Requestee) {
      userTypeName = "Requestee";
    } else if (T == Dispatcher) {
      userTypeName = "Dispatcher";
    } else if (T == Admin) {
      userTypeName = "Admin";
    }
    return Text("Create New $userTypeName");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserViewCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: title(),
          actions: [
            IconButton(
                onPressed: () async {
                  var user_ = user;
                  if (user_ == null) {
                    return;
                  }
                  try {
                    await deleteuser(user: user_);
                  } catch (e) {
                    await showDialog<void>(
                      context: context,
                      builder: (context) => AlertBox(errorString: "$e"),
                    );
                  }
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ))
          ],
        ),
        body: BlocBuilder<UserViewCubit, UserViewState>(
          builder: (context, state) {
            if (state is UserViewInitial) {
              context.read<UserViewCubit>().initwidget(futwidget: addChild());
              return loading();
            } else if (state is UserViewWithWidget) {
              return SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilderTextField(
                          name: textFieldName,
                          autocorrect: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          initialValue: user?.name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.normal),
                            border: UnderlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
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
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      state.widget,
                      const SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            var currentState = _formKey.currentState;
                            var user_ = user;
                            if (currentState == null) {
                              return;
                            }
                            if (!currentState.validate()) {
                              return;
                            }
                            if (user_ != null) {
                              updateuser(
                                  currentState: currentState, user: user_);
                            } else {
                              createuser(currentState: currentState);
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            (user != null) ? "Update" : "Create",
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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

class AlertBox extends StatelessWidget {
  final String errorString;
  const AlertBox({super.key, required this.errorString});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cannot Delete'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(errorString),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

Widget loading() => const Center(
      child: CircularProgressIndicator(),
    );
