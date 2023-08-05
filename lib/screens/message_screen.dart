import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/message_models.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

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
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => MessagesViewCubit("test"),
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
  late final List<StreamSubscription<DatabaseEvent>> subscriptions;

  @override
  void dispose() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
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