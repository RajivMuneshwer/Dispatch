import 'package:dispatch/cubit/message/messages_view_cubit.dart';
import 'package:dispatch/cubit/ticket/ticket_view_cubit.dart';
import 'package:dispatch/models/message_models.dart';
import 'package:dispatch/models/rnd_message_generator.dart';
import 'package:dispatch/models/ticket_models.dart';
import 'package:dispatch/models/user_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TextMessage extends Message {
  TextMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required super.messagesViewState,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
      };

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.left,
      );
}

class ErrorMessage extends Message {
  ErrorMessage({
    super.text = "Error",
    required super.date,
    super.isDispatch = false,
    super.sent = false,
    required super.messagesViewState,
  });

  @override
  // TODO: implement id
  int get id => throw UnimplementedError();

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) => const Text(
        "Error! Please contact Admin",
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.left,
      );
}

class TicketConfirmedMessage extends TicketMessage {
  final int confirmedTime;
  final int driverid;
  TicketConfirmedMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    super.ticketTypes = TicketTypes.confirmed,
    super.iconColor = Colors.green,
    super.ticketDetails = const Text(
      "Confirmed",
      style: TextStyle(
        color: Colors.green,
      ),
    ),
    required super.messagesViewState,
    required this.confirmedTime,
    required this.driverid,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "ticketType": ticketTypes.name,
        "confirmedTime": confirmedTime,
        "driver": driverid,
      };
}

class TicketCancelledMessage extends TicketMessage {
  final int cancelledTime;
  TicketCancelledMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    super.ticketTypes = TicketTypes.cancelled,
    super.iconColor = Colors.red,
    super.ticketDetails = const Text(
      "Cancelled",
      style: TextStyle(
        color: Colors.red,
      ),
    ),
    required super.messagesViewState,
    required this.cancelledTime,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "ticketType": ticketTypes.name,
        "cancelledTime": cancelledTime,
      };
}

class TicketSubmittedMessage extends TicketMessage {
  TicketSubmittedMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    super.ticketTypes = TicketTypes.submitted,
    super.iconColor = Colors.blue,
    super.ticketDetails = const Text(
      "Submitted",
      style: TextStyle(
        color: Colors.blue,
      ),
    ),
    required super.messagesViewState,
  });

  @override
  Map<String, dynamic> toMap() => {
        "text": text,
        "date": date.millisecondsSinceEpoch,
        "isDispatch": isDispatch,
        "sent": sent,
        "ticketType": ticketTypes.name
      };
}

sealed class TicketMessage extends Message {
  final Color iconColor;
  final TicketTypes ticketTypes;
  final Text ticketDetails;
  TicketMessage({
    required super.text,
    required super.date,
    required super.isDispatch,
    required super.sent,
    required this.ticketTypes,
    required this.iconColor,
    required this.ticketDetails,
    required super.messagesViewState,
  });

  @override
  int get id => dateToInt();

  @override
  Map<String, dynamic> toMap();

  void Function() onPressedCurry(BuildContext context) => () {
        final List<List<String>> formLayoutList =
            FormLayoutEncoder.decode(text);
        Navigator.pushNamed(
          context,
          '/ticket',
          arguments: ticketTypeToState(
            formLayoutList: formLayoutList,
            ticketTypes: ticketTypes,
            id: id,
            messageState: messagesViewState,
            ticketMessage: this,
          ),
        );
      };

  @override
  Widget build(BuildContext context) => Column(children: [
        MaterialButton(
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minWidth: 80,
          onPressed: onPressedCurry(context),
          child: FaIcon(
            FontAwesomeIcons.ticket,
            color: iconColor,
            size: 30,
          ),
        ),
        ticketDetails,
        Text(
          MessageGenerator.generate(
            number: text.length,
            isDispatch: isDispatch,
          ),
          textAlign: TextAlign.end,
        ),
      ]);
}

sealed class Message {
  final String text;
  final DateTime date;
  final bool isDispatch;
  final MessagesViewState messagesViewState;
  bool sent;

  Message({
    required this.text,
    required this.date,
    required this.isDispatch,
    required this.sent,
    required this.messagesViewState,
  });

  int get id => dateToInt();

  int dateToInt() {
    return date.millisecondsSinceEpoch;
  }

  Map<String, dynamic> toMap();

  Widget build(BuildContext context);
}

class MessageAdaptor {
  MessagesViewState messagesViewState;
  MessageAdaptor({
    required this.messagesViewState,
  });
  Message adaptText(String text, bool isDispatch) {
    return TextMessage(
      text: text,
      date: DateTime.now(),
      isDispatch: isDispatch,
      sent: false,
      messagesViewState: messagesViewState,
    );
  }

  Message adaptSnapshot(DataSnapshot snapshot) {
    var objectMap = snapshot.value;
    switch (objectMap) {
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "ticketType": "submitted",
        }:
        {
          return TicketSubmittedMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "ticketType": "cancelled",
          "cancelledTime": int cancelledTime,
        }:
        {
          return TicketCancelledMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
            cancelledTime: cancelledTime,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
          "ticketType": "confirmed",
          "confirmedTime": int confirmedTime,
          "driver": int driverid
        }:
        {
          return TicketConfirmedMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
            confirmedTime: confirmedTime,
            driverid: driverid,
          );
        }
      case {
          "text": String text,
          "date": int date,
          "isDispatch": bool isDispatch,
          "sent": bool sent,
        }:
        {
          return TextMessage(
            text: text,
            date: DateTime.fromMillisecondsSinceEpoch(date),
            isDispatch: isDispatch,
            sent: sent,
            messagesViewState: messagesViewState,
          );
        }
      case _:
        return ErrorMessage(
          date: DateTime.now(),
          messagesViewState: messagesViewState,
        );
    }
  }

  Message adaptNewTicket(TicketViewWithData ticketState) {
    String encodedFormLayout =
        FormLayoutEncoder.encode(ticketState.formLayoutList);
    final bool isDispatch = switch (ticketState.messagesState.user) {
      Dispatcher() => true,
      _ => false,
    };
    return TicketSubmittedMessage(
      text: encodedFormLayout,
      date: DateTime.now(),
      isDispatch: isDispatch,
      sent: false,
      ticketTypes: TicketTypes.submitted,
      messagesViewState: ticketState.messagesState,
    );
  }
}
