import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/rnd_message_generator.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:dispatch/models/message_bubble.dart';

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
        await UserDatabase().addMessage(newMessage);
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
                  Navigator.pushNamed(context, '/ticket',
                      arguments: TicketViewWithData(
                        formLayoutList: getNewTicketLayout(),
                        id: generateNewTicketID(),
                        color: Colors.blue,
                        animate: true,
                        enabled: true,
                        bottomButtonType: BottomButtonType.submit,
                      ));
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
    itemBuilder: (BuildContext context, Message element) => (element.isTicket)
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

Widget messageEmptyBody() {
  return Expanded(
    child: Column(
      children: [
        Container(),
      ],
    ),
  );
}

Widget messageLoadingBody() => const Expanded(
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

Widget messageRendered(BuildContext context, Message element) => TextBubble(
      date: element.date,
      text: element.text,
      color: Colors.white,
      tail: true,
      sent: element.sent,
    );

Widget ticketRendered(BuildContext context, Message message) {
  return TicketBubble(
    onPressed: () {
      final List<List<String>> formLayoutList =
          FormLayoutEncoder.decode(message.text);
      Navigator.pushNamed(
        context,
        '/ticket',
        arguments: ticketTypeToState(
          formLayoutList: formLayoutList,
          ticketTypes: message.ticketType,
          id: message.id,
        ),
      );
    },
    date: message.date,
    text: RndMessageGenerator.generate(),
    iconColor: ticketTypeToColor[message.ticketType] ?? Colors.blue,
    ticketTypes: message.ticketType,
  );
}

class Message {
  final String text;
  final DateTime date;
  final bool isDispatch;
  final bool isTicket;
  final TicketTypes ticketType;
  bool sent;

  Message({
    required this.text,
    required this.date,
    required this.isDispatch,
    required this.sent,
    required this.isTicket,
    required this.ticketType,
  });

  int get id => dateToInt();

  int dateToInt() {
    return date.millisecondsSinceEpoch;
  }
}

class MessageAdaptor {
  static Message adaptText(String text) {
    return Message(
      text: text,
      date: DateTime.now(),
      isDispatch: false,
      sent: false,
      isTicket: false,
      ticketType: TicketTypes.submitted,
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
      ticketType: stringToticketType[objectMap["ticketType"] as String] ??
          TicketTypes.submitted,
    );
  }

  static Message adaptTicketState(TicketViewWithData state) {
    String encodedFormLayout = FormLayoutEncoder.encode(state.formLayoutList);
    return Message(
      text: encodedFormLayout,
      date: DateTime.now(),
      isDispatch: false,
      sent: false,
      isTicket: true,
      ticketType: TicketTypes.submitted,
    );
  }
}

class UserDatabase {
  static String user = "test";
  static DatabaseReference ref =
      FirebaseDatabase.instance.ref("users/$user/messages");

  Future<void> addMessage(Message message) async {
    await ref.update({
      message.id.toString(): {
        "text": message.text,
        "date": message.dateToInt(),
        "isDispatch": false,
        "sent": message.sent,
        "isTicket": message.isTicket,
        "ticketType": message.ticketType.name,
      }
    });
  }

  Future<void> updateTicketType(
      String messageID, TicketTypes ticketType) async {
    await ref.child(messageID).update({"ticketType": ticketType.name});
    return;
  }

  Future<void> updateTicketMessage(
      String messageID, String encodedTicket) async {
    await ref.child(messageID).update({"text": encodedTicket});
  }

  Future<DatabaseEvent> loadMessagesBeforeTime(int time, int numOfMessage) {
    return ref.orderByChild("date").endBefore(time).limitToLast(2).once();
  }

  Stream<DatabaseEvent> onChildAddedStream(int messageLimit) {
    return ref.orderByChild("date").limitToLast(messageLimit).onChildAdded;
  }

  Stream<DatabaseEvent> onChildChanged() {
    return ref.onChildChanged;
  }
}

enum TicketTypes {
  submitted,
  cancelled,
  confirmed,
}

const stringToticketType = {
  'submitted': TicketTypes.submitted,
  'cancelled': TicketTypes.cancelled,
  'confirmed': TicketTypes.confirmed,
};

const ticketTypeToColor = {
  TicketTypes.submitted: Colors.blue,
  TicketTypes.confirmed: Colors.green,
  TicketTypes.cancelled: Colors.red
};

TicketViewWithData ticketTypeToState({
  required TicketTypes ticketTypes,
  required List<List<String>> formLayoutList,
  required int id,
}) {
  var ticketTypeToStateMap = {
    TicketTypes.submitted:
        TicketViewSubmitted(formLayoutList: formLayoutList, id: id),
    TicketTypes.cancelled:
        TicketViewCanceled(formLayoutList: formLayoutList, id: id),
    TicketTypes.confirmed:
        TicketViewConfirmed(formLayoutList: formLayoutList, id: id),
  };

  TicketViewWithData defaultTicket =
      TicketViewSubmitted(formLayoutList: formLayoutList, id: id);

  return ticketTypeToStateMap[ticketTypes] ?? defaultTicket;
}
