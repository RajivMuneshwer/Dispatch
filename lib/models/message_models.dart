import 'dart:async';
import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/rnd_message_generator.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:dispatch/models/user_objects.dart';
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
      var state_ = state;
      Future<void> submit(String text) async {
        var user = state_.user;
        bool isDispatch = switch (user) {
          Dispatcher() => true,
          _ => false,
        };
        print(isDispatch);
        Message newMessage = MessageAdaptor.adaptText(text, isDispatch);
        context.read<MessagesViewCubit>().add(newMessage);
        await state_.database.addMessage(newMessage);
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
                        messagesState: state_,
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
    itemBuilder: (BuildContext context, Message element) =>
        renderItem(context: context, element: element, state: state),
    elements: state.messages,
    groupBy: (message) =>
        DateTime(message.date.year, message.date.month, message.date.day),
  );
}

Widget renderItem({
  required BuildContext context,
  required Message element,
  required MessagesViewState state,
}) {
  var user = state.user;
  bool isSender_ = switch (user) {
    Dispatcher() => (element.isDispatch),
    _ => (!element.isDispatch),
  };

  return (element.isTicket)
      ? ticketRendered(
          context: context,
          ticket: element,
          isSender: isSender_,
          messageState: state)
      : messageRendered(
          context: context, message: element, isSender: isSender_);
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
          return RefreshIndicator(
            controller: controller,
          );
        },
      ),
      onRefresh: context.read<MessagesViewCubit>().loadPreviousMessages,
      offsetToArmed: 100.0,
      child: groupListView(context, state, controller),
    ),
  );
}

class RefreshIndicator extends StatelessWidget {
  final IndicatorController controller;
  const RefreshIndicator({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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

Widget messageRendered({
  required BuildContext context,
  required Message message,
  required bool isSender,
}) =>
    TextBubble(
      date: message.date,
      text: message.text,
      color: (isSender)
          ? Color.fromRGBO(220, 220, 220, 1)
          : Color.fromRGBO(200, 200, 200, 1),
      tail: true,
      sent: message.sent,
      isSender: isSender,
    );

Widget ticketRendered({
  required BuildContext context,
  required Message ticket,
  required bool isSender,
  required MessagesViewState messageState,
}) {
  bool isDispatch = switch (messageState.user) {
    Dispatcher() => true,
    _ => false,
  };
  return TicketBubble(
    onPressed: () {
      final List<List<String>> formLayoutList =
          FormLayoutEncoder.decode(ticket.text);
      Navigator.pushNamed(
        context,
        '/ticket',
        arguments: ticketTypeToState(
          formLayoutList: formLayoutList,
          ticketTypes: ticket.ticketType,
          id: ticket.id,
          messageState: messageState,
        ),
      );
    },
    isSender: isSender,
    date: ticket.date,
    text: MessageGenerator.generate(
      number: ticket.text.length,
      isDispatch: isDispatch,
    ),
    iconColor: ticketTypeToColor[ticket.ticketType] ?? Colors.blue,
    ticketTypes: ticket.ticketType,
    color: (isSender)
        ? Color.fromRGBO(220, 220, 220, 1)
        : Color.fromRGBO(200, 200, 200, 1),
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
  static Message adaptText(String text, bool isDispatch) {
    return Message(
      text: text,
      date: DateTime.now(),
      isDispatch: isDispatch,
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

  static Message adaptTicketState(
      TicketViewWithData ticketState, bool isDispatch) {
    String encodedFormLayout =
        FormLayoutEncoder.encode(ticketState.formLayoutList);
    return Message(
      text: encodedFormLayout,
      date: DateTime.now(),
      isDispatch: isDispatch,
      sent: false,
      isTicket: true,
      ticketType: TicketTypes.submitted,
    );
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
  required MessagesViewState messageState,
  required int id,
}) {
  var ticketTypeToStateMap = {
    TicketTypes.submitted: TicketViewSubmitted(
      formLayoutList: formLayoutList,
      id: id,
      messagesState: messageState,
    ),
    TicketTypes.cancelled: TicketViewCanceled(
      formLayoutList: formLayoutList,
      id: id,
      messagesState: messageState,
    ),
    TicketTypes.confirmed: TicketViewConfirmed(
      formLayoutList: formLayoutList,
      id: id,
      messagesState: messageState,
    ),
  };

  TicketViewWithData defaultTicket = TicketViewSubmitted(
      formLayoutList: formLayoutList, id: id, messagesState: messageState);

  return ticketTypeToStateMap[ticketTypes] ?? defaultTicket;
}
