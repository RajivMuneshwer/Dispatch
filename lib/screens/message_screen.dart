import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/database/requestee_database.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import '../models/message_models.dart';

class DriverMessageScreen extends StatelessWidget {
  final Driver user;
  final Dispatcher dispatcher;
  const DriverMessageScreen({
    super.key,
    required this.user,
    required this.dispatcher,
  });

  @override
  Widget build(BuildContext context) {
    return MessageScreen<Driver>(
      user: user,
      database: DriverMessageDatabase(user: user),
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
  }
}

class RequesteeMessageScreen extends StatelessWidget {
  final Requestee user;
  final Dispatcher dispatcher;
  const RequesteeMessageScreen({
    super.key,
    required this.user,
    required this.dispatcher,
  });

  @override
  Widget build(BuildContext context) {
    return MessageScreen<Requestee>(
      user: user,
      database: RequesteesMessageDatabase(user: user),
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
  }
}

class DispatcherMessageScreen<T extends User> extends StatelessWidget {
  final Dispatcher dispatcher;
  final T receiver;
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

    return MessageScreen<Dispatcher>(
      user: dispatcher,
      database: MessageDatabaseFactory<T>().create(user: receiver),
      appBar: appBar,
    );
  }
}

class MessageScreen<T extends User> extends StatefulWidget {
  final T user;
  final MessageDatabase database;
  final AppBar appBar;
  const MessageScreen({
    super.key,
    required this.user,
    required this.database,
    required this.appBar,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ScrollController controller = ScrollController();

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
          widget.user,
          widget.database,
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

class _DisplayMessagesWidgetState extends State<DisplayMessagesWidget> {
  List<StreamSubscription<DatabaseEvent>> subscriptions = [];

  @override
  void dispose() async {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
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

////TODO

////log the user in with firebase auth see  https://github.com/simonbengtsson/airdash/blob/main/lib/interface/setup_screen.dart
////change the status of delivered and read
