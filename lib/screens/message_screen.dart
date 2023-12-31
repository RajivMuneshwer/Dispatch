import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/database/message_database.dart';
import 'package:dispatch/database/user_database.dart';
import 'package:dispatch/objects/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import '../models/message_models.dart';

class DriverMessageScreen extends StatelessWidget {
  final Driver user;
  const DriverMessageScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    var dispatchid = user.dispatcherid;
    if (dispatchid == null) return Container();
    return FutureBuilder(
      future: AdminDatabase().getOne<Dispatcher>(dispatchid),
      builder: (context, snapshot) {
        var snapshot_ = snapshot;
        var data_ = snapshot_.data;
        if (snapshot_.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot_.hasError) {
          return Container();
        } else if (!snapshot_.hasData || data_ == null) {
          return Container();
        }
        final Dispatcher dispatcher = UserAdaptor<Dispatcher>().adaptSnapshot(
          data_.first,
        );
        return MessageScreen<Driver, Dispatcher>(
          user: user,
          database: DriverMessageDatabase(user: user),
          other: dispatcher,
          appBar: AppBar(
            title: Row(
              children: [
                ProfilePicture(name: dispatcher.name, radius: 22, fontsize: 20),
                const SizedBox(width: 15),
                Text(
                  dispatcher.name,
                  style: const TextStyle(fontSize: 17.5),
                )
              ],
            ),
            actions: [
              CallButton(
                user: dispatcher,
              ),
              const SizedBox(
                width: 15,
              )
            ],
          ),
        );
      },
    );
  }
}

class RequesteeMessageScreen extends StatelessWidget {
  final Requestee user;
  const RequesteeMessageScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    var dispatchid = user.dispatcherid;
    if (dispatchid == null) return Container();
    return FutureBuilder(
      future: AdminDatabase().getOne<Dispatcher>(dispatchid),
      builder: (context, snapshot) {
        var snapshot_ = snapshot;
        var data_ = snapshot_.data;
        if (snapshot_.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot_.hasError) {
          return Container();
        } else if (!snapshot_.hasData || data_ == null) {
          return Container();
        }

        final Dispatcher dispatcher = UserAdaptor<Dispatcher>().adaptSnapshot(
          data_.first,
        );
        return MessageScreen<Requestee, Dispatcher>(
          user: user,
          database: RequesteesMessageDatabase(user: user),
          other: dispatcher,
          appBar: AppBar(
            title: Row(
              children: [
                ProfilePicture(name: dispatcher.name, radius: 22, fontsize: 20),
                const SizedBox(width: 15),
                Text(
                  dispatcher.name,
                  style: const TextStyle(fontSize: 17.5),
                )
              ],
            ),
            actions: [
              CallButton(
                user: dispatcher,
              ),
              const SizedBox(
                width: 15,
              )
            ],
          ),
        );
      },
    );
  }
}

class DispatcherMessageScreen<M extends User> extends StatelessWidget {
  final Dispatcher dispatcher;
  final M receiver;
  const DispatcherMessageScreen({
    super.key,
    required this.dispatcher,
    required this.receiver,
  });

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Row(
        children: [
          ProfilePicture(name: receiver.name, radius: 22, fontsize: 20),
          const SizedBox(width: 15),
          Text(
            receiver.name,
            style: const TextStyle(fontSize: 17.5),
          )
        ],
      ),
      actions: [CallButton(user: receiver)],
    );

    return MessageScreen<Dispatcher, M>(
      user: dispatcher,
      database: MessageDatabaseFactory<M>().create(user: receiver),
      appBar: appBar,
      other: receiver,
    );
  }
}

class MessageScreen<T extends User, M extends User> extends StatefulWidget {
  final T user;
  final M other;
  final MessageDatabase database;
  final AppBar appBar;
  const MessageScreen({
    super.key,
    required this.user,
    required this.database,
    required this.appBar,
    required this.other,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    widget.database.sync();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: BlocProvider(
        create: (context) => MessagesViewCubit(
          widget.other,
          widget.user,
          widget.database,
          widget.other,
        ),
        child: Column(
          children: [
            DisplayMessagesWidget(
              controller: controller,
            ),
            NewMessageWidget(
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayMessagesWidget extends StatefulWidget {
  final ScrollController controller;

  const DisplayMessagesWidget({super.key, required this.controller});

  @override
  State<DisplayMessagesWidget> createState() => _DisplayMessagesWidgetState();
}

class _DisplayMessagesWidgetState extends State<DisplayMessagesWidget>
    with WidgetsBindingObserver {
  List<StreamSubscription<DatabaseEvent>> subscriptions = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        {
          for (var sub in subscriptions) {
            sub.resume();
          }
          break;
        }
      case AppLifecycleState.paused:
        {
          for (var sub in subscriptions) {
            sub.pause();
          }
          break;
        }
      case AppLifecycleState.inactive:
        {
          print("inactive");
          break;
        }
      case AppLifecycleState.detached:
        {
          print("detached");
          break;
        }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesViewCubit, MessagesViewState>(
      builder: (context, state) {
        if (state is MessagesViewInitial) {
          subscriptions = context.read<MessagesViewCubit>().loadMessages();
          return messageEmptyBody();
        } else if (state is MessagesViewLoaded) {
          return messageBody(context, widget.controller, state);
        } else if (state is MessagesViewLoading) {
          return messageLoadingBody();
        } else {
          return messageEmptyBody();
        }
      },
    );
  }
}
