import 'package:dispatch/cubit/user_view/user_view_cubit.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:dispatch/utils/object_list_sorter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

abstract class UserListScreen<T extends User> extends StatelessWidget {
  final String title;
  const UserListScreen({
    super.key,
    required this.title,
  });

  Future<List<T>> initUsers();
  Future<List<T>?> Function() loadUsers(T lastUsers);
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
        create: (context) => UserViewCubit<List<T>>(data: []),
        child: BlocBuilder<UserViewCubit<List<T>>, UserViewState>(
          builder: (context, state) {
            if (state is UserViewInitial) {
              context.read<UserViewCubit<List<T>>>().init(func: initUsers);
              return loading();
            } else if (state is UserViewWithData<List<T>>) {
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification.metrics.pixels ==
                      notification.metrics.maxScrollExtent) {
                    if (state.canUpdate) {
                      context.read<UserViewCubit<List<T>>>().update(
                            downloadfunc: loadUsers(state.data.last),
                            combine: (newdata, olddata) {
                              olddata.addAll(newdata);
                              return olddata;
                            },
                          );
                    }
                  }

                  return true;
                },
                child: RefreshIndicator(
                  onRefresh: () async => context
                      .read<UserViewCubit<List<T>>>()
                      .init(func: initUsers),
                  child: UserList<T>(
                    initUsers: state.data,
                    rowFactory: userRowFactory,
                    onTap: onTap,
                  ),
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
  Future<List<M>?> Function() loadData(M lastUsers);
  void Function() onUserTap(M user, BuildContext context);
  void Function() onEditTap(T user, BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.name}'s info"),
      ),
      body: BlocProvider(
        create: (context) => UserViewCubit<List<M>>(data: []),
        child: BlocBuilder<UserViewCubit<List<M>>, UserViewState>(
          builder: (context, state) {
            switch (state) {
              case UserViewInitial():
                {
                  var cubit = context.read<UserViewCubit<List<M>>>();
                  cubit.init(func: additionData);
                  return loading();
                }
              case UserViewWithData<List<M>>():
                {
                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification.metrics.pixels ==
                          notification.metrics.maxScrollExtent) {
                        if (state.canUpdate) {
                          context.read<UserViewCubit<List<M>>>().update(
                                downloadfunc: loadData(state.data.last),
                                combine: (newdata, olddata) {
                                  olddata.addAll(newdata);
                                  return olddata;
                                },
                              );
                        }
                      }

                      return true;
                    },
                    child: RefreshIndicator(
                      onRefresh: () async => context
                          .read<UserViewCubit<List<M>>>()
                          .init(func: additionData),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40.0),
                          NameInfoBox(user: user),
                          const SizedBox(height: 20.0),
                          HeaderText<M>(),
                          Expanded(
                            flex: 2,
                            child: UserList<M>(
                              initUsers: state.data,
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
                    ),
                  );
                }
              case UserViewWithData<dynamic>():
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
  final List<T> initUsers;
  final void Function() Function(T, BuildContext) onTap;
  final UserRowFactory rowFactory;
  const UserList({
    super.key,
    required this.initUsers,
    required this.onTap,
    required this.rowFactory,
  });

  @override
  Widget build(BuildContext context) {
    List<T?> orderedUserList = ObjectListSorter(objectList: initUsers).sort();
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

class RequesteeMessagesRowFactory extends UserRowFactory<Requestee> {
  @override
  List<Widget> make(Requestee? user) {
    if (user == null) return [];
    return [
      UserProfilePic(name: user.name),
      UserNameBox(name: user.name),
      UserMessageInfo(
        numOfUnreadMessages: user.numOfUnreadMessages ?? 2,
        time: user.lastMessageTime ?? DateTime.now().millisecondsSinceEpoch,
      ),
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

class UserMessageInfo extends StatelessWidget {
  final int numOfUnreadMessages;
  final int? time;
  const UserMessageInfo({
    super.key,
    required this.numOfUnreadMessages,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MessageTimeTextWidget(time: time),
            MessageNumberWidget(numOfUnreadMessages: numOfUnreadMessages)
          ],
        ));
  }
}

class MessageNumberWidget extends StatelessWidget {
  final int numOfUnreadMessages;
  const MessageNumberWidget({super.key, required this.numOfUnreadMessages});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (numOfUnreadMessages > 0) ? Colors.red : Colors.transparent,
      ),
      child: Center(
          child: Text(
        (numOfUnreadMessages > 0) ? numOfUnreadMessages.toString() : "",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      )),
    );
  }
}

class MessageTimeTextWidget extends StatelessWidget {
  final int? time;
  const MessageTimeTextWidget({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime todayDateTime = DateTime(now.year, now.month, now.day);
    int today = todayDateTime.millisecondsSinceEpoch;
    String text = "";
    var time_ = time;
    if (time_ == null) return Text(text);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time_);
    if (time_ >= today) {
      text = DateFormat.jm().format(dateTime);
    } else {
      Duration difference = todayDateTime.difference(dateTime);
      if (difference.inDays == 0) {
        text = "Yesterday";
      } else if (difference.inDays >= 7) {
        text = "${difference.inDays} days ago";
      } else {
        text = DateFormat.yMd().format(dateTime);
      }
    }
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 15,
      ),
    );
  }
}

abstract class UserEditScreen<T extends User> extends StatelessWidget {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final T? user;

  UserEditScreen({
    super.key,
    required this.user,
  });

  Future<Widget> addWidgets();
  Future<void> updateUser({
    required FormBuilderState state,
    required T user,
  });
  Future<void> createUser({required FormBuilderState state});
  Future<void> deleteUser({required T user});

  Text title() {
    T? user_ = user;
    if (user_ case User()) {
      return Text(user_.name);
    }
    String text = switch (T) {
      Requestee => 'Requestee',
      Dispatcher => 'Dispatcher',
      Admin => 'Admin',
      _ => '',
    };
    return Text("Create new $text");
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserViewCubit<Widget>(data: Container()),
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
                  await showDialog<void>(
                    context: context,
                    builder: (context) => DeleteConfirmationBox(
                      user: user_,
                      deleteuser: deleteUser,
                    ),
                  );
                  int count = 0;
                  Navigator.popUntil(context, (route) => ++count > 2);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ))
          ],
        ),
        body: BlocBuilder<UserViewCubit<Widget>, UserViewState>(
          builder: (context, state) {
            if (state is UserViewInitial) {
              context.read<UserViewCubit<Widget>>().init(func: addWidgets);
              return loading();
            } else if (state is UserViewWithData<Widget>) {
              return SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      state.data,
                      const SizedBox(height: 40),
                      EditSubmitButton(
                        formKey: _formKey,
                        user: user,
                        createUser: createUser,
                        updateUser: updateUser,
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

class EditSubmitButton<T extends User> extends StatelessWidget {
  final T? user;
  final GlobalKey<FormBuilderState> formKey;
  final Future<void> Function({required FormBuilderState state}) createUser;
  final Future<void> Function(
      {required FormBuilderState state, required T user}) updateUser;
  const EditSubmitButton({
    super.key,
    required this.formKey,
    required this.user,
    required this.createUser,
    required this.updateUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () async {
          var state = formKey.currentState;
          var user_ = user;
          if (state!.validate() == true) {
            (user_ == null)
                ? await createUser(state: state)
                : await updateUser(state: state, user: user_);
          }
          int count = 0;
          Navigator.popUntil(
              context, (route) => (user_ == null) ? ++count > 1 : ++count > 2);
        },
        child: Text(
          (user != null) ? "Update" : "Create",
        ),
      ),
    );
  }
}

class EditTextFormField extends StatelessWidget {
  final String name;
  final String? initial;
  const EditTextFormField(
      {super.key, required this.name, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FormBuilderTextField(
        name: name,
        autocorrect: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        initialValue: initial,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          labelText: "Name",
          labelStyle: const TextStyle(fontWeight: FontWeight.normal),
          border: UnderlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
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
    );
  }
}

class ExceptionAlertBox extends StatelessWidget {
  final String errorString;
  const ExceptionAlertBox({super.key, required this.errorString});

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

class DeleteConfirmationBox<T extends User> extends StatelessWidget {
  final T user;
  final Future<void> Function({required T user}) deleteuser;
  const DeleteConfirmationBox(
      {super.key, required this.user, required this.deleteuser});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm delete'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("Are you sure you wish to delete user?"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            var user_ = user;
            try {
              Navigator.of(context).pop();
              await deleteuser(user: user_);
            } catch (e) {
              await showDialog<void>(
                context: context,
                builder: (context) => ExceptionAlertBox(errorString: "$e"),
              );
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

Widget loading() => const Center(
      child: CircularProgressIndicator(),
    );
