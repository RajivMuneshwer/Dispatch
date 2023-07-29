import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:dispatch/screens/ticket_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dispatch/models/message_bubble.dart';
import 'package:page_transition/page_transition.dart';

class NewMessageWidget extends StatelessWidget {
  final ScrollController controller;
  const NewMessageWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesViewCubit, MessagesViewState>(
        builder: (context, state) {
      Future<void> submit(String text) async {
        Message newMessage = MessageAdaptor.adaptText(text);
        context.read<MessagesViewCubit>().add(newMessage);
        await FirebaseUserMessagesDatabase("test").addMessage(newMessage);
        scrollDown(controller);
      }

      return MessageBar(
        onSend: (String text) async {
          if (text.isEmpty) return;
          await submit(text);
        },
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const TicketScreen(newFormLayoutList: []),
                      type: PageTransitionType.bottomToTop,
                      duration: const Duration(milliseconds: 300),
                      childCurrent: this,
                    ),
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.ticket,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}

GroupedListView<Message, DateTime> groupListView(BuildContext context,
    MessagesViewLoaded state, ScrollController controller) {
  return GroupedListView<Message, DateTime>(
    physics: const AlwaysScrollableScrollPhysics(),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
    controller: controller,
    groupHeaderBuilder: (element) => Center(
      child: Card(
        child: Text(DateFormat.yMMMd().format(element.date)),
      ),
    ),
    itemBuilder: (context, element) => (element.isTicket)
        ? ticketRendered(context, element)
        : messageRendered(context, element),
    elements: state.messages,
    groupBy: (message) =>
        DateTime(message.date.year, message.date.month, message.date.day),
  );
}

void scrollDown(ScrollController controller) {
  controller.animateTo(
    controller.position.maxScrollExtent,
    duration: const Duration(milliseconds: 500),
    curve: Curves.fastOutSlowIn,
  );
}

Widget emptyBody() {
  return Expanded(
    child: Column(
      children: [
        Container(),
      ],
    ),
  );
}

Widget loadingBody() => const Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

Widget messageBody(BuildContext context, ScrollController controller,
    MessagesViewLoaded state) {
  return Expanded(
    child: CustomRefreshIndicator(
      builder: MaterialIndicatorDelegate(
        builder: (context, controller) {
          return refreshIndicator(context, controller);
        },
      ),
      onRefresh: context.read<MessagesViewCubit>().loadPreviousMessages,
      offsetToArmed: 100.0,
      child: groupListView(context, state, controller),
    ),
  );
}

Widget refreshIndicator(BuildContext context, IndicatorController controller) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.blue,
      shape: BoxShape.circle,
    ),
    child: SizedBox(
      height: 30,
      width: 30,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: const AlwaysStoppedAnimation(Colors.white),
        value: controller.isDragging || controller.isArmed
            ? controller.value.clamp(0.0, 1.0)
            : null,
      ),
    ),
  );
}

Widget messageRendered(BuildContext context, Message element) => BubbleCustom(
      date: element.date,
      text: element.text,
      color: Colors.white,
      tail: true,
      textStyle: const TextStyle(color: Colors.black),
      sent: element.sent,
    );

Widget ticketRendered(BuildContext context, Message message) {
  List<List<String>> newFormLayoutList =
      FormLayoutEncoder().decode(message.text);
  return BubbleCustom(
    onPressed: () {
      Navigator.push(
        context,
        PageTransition(
          child: TicketScreen(
            newFormLayoutList: newFormLayoutList,
          ),
          type: PageTransitionType.bottomToTop,
        ),
      );
    },
    date: message.date,
    text: message.text,
    isTicket: true,
    textStyle: const TextStyle(
      fontSize: 12,
    ),
  );
}

class Message {
  final String text;
  final DateTime date;
  final bool isDispatch;
  final bool isTicket;
  bool sent;

  Message({
    required this.text,
    required this.date,
    required this.isDispatch,
    required this.sent,
    required this.isTicket,
  });
}

class FirebaseObject extends Object {
  final String text;
  final int date;
  final bool isDispatch;
  final bool isTicket;
  final bool sent;

  FirebaseObject(
    this.text,
    this.date,
    this.isDispatch,
    this.sent,
    this.isTicket,
  );
}

class MessageAdaptor {
  static Message adaptText(String text) {
    return Message(
      text: text,
      date: DateTime.now(),
      isDispatch: false,
      sent: false,
      isTicket: false,
    );
  }

  static Message adaptFirebaseObject(FirebaseObject firebaseObject) {
    return Message(
      text: firebaseObject.text,
      date: DateTime.fromMillisecondsSinceEpoch(firebaseObject.date),
      isDispatch: firebaseObject.isDispatch,
      sent: firebaseObject.sent,
      isTicket: firebaseObject.isTicket,
    );
  }

  static Message adaptSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> objectMap = snapshot.value as Map<dynamic, dynamic>;
    return Message(
      text: objectMap["text"] as String,
      date: DateTime.fromMillisecondsSinceEpoch(objectMap["date"] as int),
      isDispatch: objectMap["isDispatch"] as bool,
      sent: objectMap["sent"] as bool,
      isTicket: objectMap["isTicket"] as bool,
    );
  }

  static Message adaptFormLayoutList(List<List<String>> formLayoutList) {
    String encodedFormLayout = FormLayoutEncoder().encode(formLayoutList);
    return Message(
      text: encodedFormLayout,
      date: DateTime.now(),
      isDispatch: false,
      sent: false,
      isTicket: true,
    );
  }
}

class FirebaseObjectAdaptor {
  static FirebaseObject adaptMessage(Message message) {
    return FirebaseObject(
      message.text,
      message.date.millisecondsSinceEpoch,
      message.isDispatch,
      message.sent,
      message.isTicket,
    );
  }

  static FirebaseObject adaptSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> objectMap = snapshot.value as Map<dynamic, dynamic>;
    return FirebaseObject(
      objectMap["text"] as String,
      objectMap["date"] as int,
      objectMap["isDispatch"] as bool,
      objectMap["sent"] as bool,
      objectMap["isTicket"] as bool,
    );
  }
}

class FirebaseUserMessagesDatabase {
  final String user;
  FirebaseUserMessagesDatabase(this.user);

  DatabaseReference get ref =>
      FirebaseDatabase.instance.ref("users/$user/messages");

  Future<void> addMessage(Message message) async {
    final firebaseObject = FirebaseObjectAdaptor.adaptMessage(message);
    await ref.push().set({
      "text": firebaseObject.text,
      "date": firebaseObject.date,
      "isDispatch": false,
      "sent": firebaseObject.sent,
      "isTicket": firebaseObject.isTicket,
    });
  }
}
